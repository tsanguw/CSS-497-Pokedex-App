import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'legacy_team_import.dart';

/// The app's writable database for data the user creates (saved teams).
///
/// It is separate from the bundled, read-only `pokedex.db`: that file is
/// replaced whenever the bundled data changes, and user data must survive
/// that. A team stores only IDs; names and stats are looked up from the
/// bundled database when a team is shown.
class UserDatabase {
  UserDatabase._();
  static final UserDatabase instance = UserDatabase._();

  static const _fileName = 'user.db';

  // SharedPreferences keys used by older versions (see legacy_team_import).
  static const _legacyTeamsKey = 'teams';

  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _openOrReset();

  // If opening fails, forget it so the next call tries again.
  Future<Database> _openOrReset() async {
    try {
      return await _open();
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async =>
      openWith(databaseFactory, join(await getDatabasesPath(), _fileName));

  /// Opens (and creates, and imports old data into) a user database. Public
  /// so tests can use an in-memory database and a desktop SQLite factory.
  static Future<Database> openWith(DatabaseFactory factory, String path) async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => createSchema(db),
      ),
    );
    await importLegacyTeamsFromPreferences(
        db, await SharedPreferences.getInstance());
    return db;
  }

  /// Version 1 schema. Public so tests can build the same tables.
  static Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE team (
        team_id    INTEGER PRIMARY KEY AUTOINCREMENT,
        team_name  TEXT NOT NULL UNIQUE COLLATE NOCASE,
        sort_order INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE team_member (
        team_id  INTEGER NOT NULL REFERENCES team(team_id) ON DELETE CASCADE,
        slot     INTEGER NOT NULL CHECK (slot BETWEEN 0 AND 5),
        pok_id   INTEGER NOT NULL,
        move1_id INTEGER,
        move2_id INTEGER,
        move3_id INTEGER,
        move4_id INTEGER,
        abi_id   INTEGER,
        item_id  INTEGER,
        PRIMARY KEY (team_id, slot)
      )
    ''');
    await db.execute('''
      CREATE TABLE app_meta (
        meta_key   TEXT PRIMARY KEY,
        meta_value TEXT NOT NULL
      )
    ''');
  }

  // ---- one-time import of teams saved by older versions -------------------

  static const _importedKey = 'legacy_teams_imported';

  /// Moves teams saved by older versions from SharedPreferences into [db].
  ///
  /// The old copies are removed only after the import is committed (or was
  /// committed on an earlier run), so they are never deleted before the new
  /// ones exist. If the import fails nothing is removed and it is tried again
  /// on the next launch. [importer] exists so tests can make the import fail.
  static Future<void> importLegacyTeamsFromPreferences(
    Database db,
    SharedPreferences prefs, {
    Future<void> Function(Database db, List<LegacyTeam> teams) importer =
        importTeams,
  }) async {
    try {
      final names = prefs.getStringList(_legacyTeamsKey);
      if (names == null) return;

      final alreadyImported = (await db.query('app_meta',
              where: 'meta_key = ?', whereArgs: [_importedKey]))
          .isNotEmpty;

      if (!alreadyImported) {
        await importer(
          db,
          parseLegacyTeams(teamNames: names, readTeam: prefs.getString),
        );
      }

      for (final name in names) {
        await prefs.remove(name);
      }
      await prefs.remove(_legacyTeamsKey);
      if (kDebugMode) {
        debugPrint('[pokedex] imported ${names.length} saved teams into '
            '$_fileName and removed the old copies');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[pokedex] team import will retry: $e');
    }
  }

  /// Writes [teams] and the "imported" marker in one transaction: either all
  /// of it lands or none of it does. Team names that already exist in the
  /// database get a numeric suffix.
  static Future<void> importTeams(Database db, List<LegacyTeam> teams) {
    return db.transaction((txn) async {
      var order = Sqflite.firstIntValue(
              await txn.rawQuery('SELECT COALESCE(MAX(sort_order), -1) '
                  'FROM team')) ??
          -1;

      for (final team in teams) {
        var name = team.name;
        for (var n = 2; await _nameTaken(txn, name); n++) {
          name = '${team.name} ($n)';
        }
        final teamId = await txn.insert('team', {
          'team_name': name,
          'sort_order': ++order,
        });
        for (var slot = 0; slot < team.members.length; slot++) {
          final m = team.members[slot];
          await txn.insert('team_member', {
            'team_id': teamId,
            'slot': slot,
            'pok_id': m.pokId,
            'move1_id': m.moveIds[0],
            'move2_id': m.moveIds[1],
            'move3_id': m.moveIds[2],
            'move4_id': m.moveIds[3],
            'abi_id': m.abilityId,
            'item_id': m.itemId,
          });
        }
      }
      await txn.insert(
        'app_meta',
        {'meta_key': _importedKey, 'meta_value': 'done'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<bool> _nameTaken(DatabaseExecutor db, String name) async =>
      (await db.query('team',
              columns: ['team_id'], where: 'team_name = ?', whereArgs: [name]))
          .isNotEmpty;
}
