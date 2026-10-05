import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import 'legacy_team_import.dart' show maxTeamSize;
import 'user_database.dart';

class TeamSummary {
  final int id;
  final String name;

  const TeamSummary(this.id, this.name);
}

/// Looks up the names and stats for the IDs a saved team stores.
abstract class TeamLookups {
  Future<List<Map<String, dynamic>>> allPokemon();
  Future<List<Map<String, dynamic>>> allMoves();
  Future<List<Map<String, dynamic>>> allAbilities();
  Future<List<Map<String, dynamic>>> itemsByIds(List<int> ids);
}

/// Uses the cached lists in [DatabaseHelper], so showing a team costs one
/// small query (items) plus lookups in memory.
class BundledDatabaseLookups implements TeamLookups {
  final DatabaseHelper _db = DatabaseHelper();

  @override
  Future<List<Map<String, dynamic>>> allPokemon() => _db.getAllPokemon();

  @override
  Future<List<Map<String, dynamic>>> allMoves() => _db.getAllMoves();

  @override
  Future<List<Map<String, dynamic>>> allAbilities() => _db.getAllAbilities();

  @override
  Future<List<Map<String, dynamic>>> itemsByIds(List<int> ids) =>
      _db.getItemsByIds(ids);
}

/// Saved teams: create, rename, delete, and edit the Pokemon on a team.
///
/// Every edit is one small write by team ID, so renaming never moves data and
/// nothing is rewritten wholesale.
class TeamRepository {
  TeamRepository({
    Future<Database> Function()? openDatabase,
    TeamLookups? lookups,
  })  : _open = openDatabase ?? (() => UserDatabase.instance.database),
        _lookups = lookups ?? BundledDatabaseLookups();

  static final TeamRepository instance = TeamRepository();

  final Future<Database> Function() _open;
  final TeamLookups _lookups;

  // ---- teams ---------------------------------------------------------------

  Future<List<TeamSummary>> listTeams() async {
    final db = await _open();
    final rows = await db.query('team', orderBy: 'sort_order, team_id');
    return [
      for (final r in rows)
        TeamSummary(r['team_id'] as int, r['team_name'] as String),
    ];
  }

  /// Creates a team. Returns an error message to show the user, or null on
  /// success.
  Future<String?> createTeam(String name) async {
    final db = await _open();
    final trimmed = name.trim();
    final problem = await _nameProblem(db, trimmed);
    if (problem != null) return problem;

    final next = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COALESCE(MAX(sort_order), -1) + 1 FROM team')) ??
        0;
    try {
      await db.insert('team', {'team_name': trimmed, 'sort_order': next});
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return _duplicate;
      rethrow;
    }
    return null;
  }

  /// Renames a team; its Pokemon stay with it. Returns an error message, or
  /// null on success.
  Future<String?> renameTeam(int teamId, String name) async {
    final db = await _open();
    final trimmed = name.trim();
    final problem = await _nameProblem(db, trimmed, ignoreTeamId: teamId);
    if (problem != null) return problem;
    try {
      await db.update('team', {'team_name': trimmed},
          where: 'team_id = ?', whereArgs: [teamId]);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return _duplicate;
      rethrow;
    }
    return null;
  }

  /// Deletes a team and, through the foreign key, its Pokemon.
  Future<void> deleteTeam(int teamId) async {
    final db = await _open();
    await db.delete('team', where: 'team_id = ?', whereArgs: [teamId]);
  }

  static const _duplicate = 'You already have that team.';

  Future<String?> _nameProblem(Database db, String name,
      {int? ignoreTeamId}) async {
    if (name.isEmpty) return 'Enter a team name.';
    final clash = await db.query(
      'team',
      columns: ['team_id'],
      where: 'team_name = ?${ignoreTeamId == null ? '' : ' AND team_id != ?'}',
      whereArgs: [name, if (ignoreTeamId != null) ignoreTeamId],
    );
    return clash.isEmpty ? null : _duplicate;
  }

  // ---- members -------------------------------------------------------------

  /// The team's Pokemon in order, each as the map the team screen shows:
  /// the Pokemon row plus `slot`, `moves` (4 entries, null when empty),
  /// `ability` and `item`. A Pokemon that no longer exists in the bundled
  /// database is left out; a move, ability or item that no longer exists
  /// shows as an empty slot.
  Future<List<Map<String, dynamic>>> loadTeam(int teamId) async {
    final db = await _open();
    final rows = await db.query('team_member',
        where: 'team_id = ?', whereArgs: [teamId], orderBy: 'slot');
    if (rows.isEmpty) return [];

    final pokemon = _byId(await _lookups.allPokemon(), 'pok_id');
    final moves = _byId(await _lookups.allMoves(), 'move_id');
    final abilities = _byId(await _lookups.allAbilities(), 'abi_id');
    final itemIds = {
      for (final r in rows)
        if (r['item_id'] != null) r['item_id'] as int,
    }.toList();
    final items = itemIds.isEmpty
        ? <int, Map<String, dynamic>>{}
        : _byId(await _lookups.itemsByIds(itemIds), 'item_id');

    final members = <Map<String, dynamic>>[];
    for (final row in rows) {
      final base = pokemon[row['pok_id']];
      if (base == null) continue;
      members.add({
        ...base,
        'slot': row['slot'],
        'moves': [
          for (var i = 1; i <= 4; i++) moves[row['move${i}_id']],
        ],
        'ability': abilities[row['abi_id']],
        'item': items[row['item_id']],
      });
    }
    return members;
  }

  /// Adds a Pokemon to the first free slot. Returns the slot, or null when
  /// the team already has [maxTeamSize] Pokemon.
  Future<int?> addMember(int teamId, int pokId) async {
    final db = await _open();
    return db.transaction((txn) async {
      final used = {
        for (final r in await txn.query('team_member',
            columns: ['slot'], where: 'team_id = ?', whereArgs: [teamId]))
          r['slot'] as int,
      };
      final slot = [for (var s = 0; s < maxTeamSize; s++) s]
          .cast<int?>()
          .firstWhere((s) => !used.contains(s), orElse: () => null);
      if (slot == null) return null;
      await txn.insert(
          'team_member', {'team_id': teamId, 'slot': slot, 'pok_id': pokId});
      return slot;
    });
  }

  /// Swaps the Pokemon in [slot]; its moves, ability and item are cleared.
  Future<void> replaceMember(int teamId, int slot, int pokId) async {
    final db = await _open();
    await db.update(
      'team_member',
      {
        'pok_id': pokId,
        'move1_id': null,
        'move2_id': null,
        'move3_id': null,
        'move4_id': null,
        'abi_id': null,
        'item_id': null,
      },
      where: 'team_id = ? AND slot = ?',
      whereArgs: [teamId, slot],
    );
  }

  /// Removes the Pokemon in [slot] and moves later ones up to close the gap.
  Future<void> removeMember(int teamId, int slot) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('team_member',
          where: 'team_id = ? AND slot = ?', whereArgs: [teamId, slot]);
      // One row at a time, lowest first, so each move lands on a free slot
      // (a single UPDATE can trip the primary key halfway through).
      final later = await txn.query('team_member',
          columns: ['slot'],
          where: 'team_id = ? AND slot > ?',
          whereArgs: [teamId, slot],
          orderBy: 'slot');
      for (final r in later) {
        final s = r['slot'] as int;
        await txn.update('team_member', {'slot': s - 1},
            where: 'team_id = ? AND slot = ?', whereArgs: [teamId, s]);
      }
    });
  }

  /// Sets move number [moveIndex] (0 to 3) of the Pokemon in [slot].
  Future<void> setMove(int teamId, int slot, int moveIndex, int moveId) =>
      _setColumn(
          teamId, slot, 'move${_checkMoveIndex(moveIndex) + 1}_id', moveId);

  Future<void> setAbility(int teamId, int slot, int abilityId) =>
      _setColumn(teamId, slot, 'abi_id', abilityId);

  Future<void> setItem(int teamId, int slot, int itemId) =>
      _setColumn(teamId, slot, 'item_id', itemId);

  Future<void> _setColumn(
      int teamId, int slot, String column, int value) async {
    final db = await _open();
    await db.update('team_member', {column: value},
        where: 'team_id = ? AND slot = ?', whereArgs: [teamId, slot]);
  }

  int _checkMoveIndex(int i) {
    if (i < 0 || i > 3) throw RangeError.range(i, 0, 3, 'moveIndex');
    return i;
  }

  Map<int, Map<String, dynamic>> _byId(
          List<Map<String, dynamic>> rows, String key) =>
      {for (final r in rows) r[key] as int: r};
}
