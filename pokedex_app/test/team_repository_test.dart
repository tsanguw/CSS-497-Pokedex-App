import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/legacy_team_import.dart';
import 'package:pokedex_app/team_repository.dart';
import 'package:pokedex_app/user_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Stand-in for the bundled database: a few Pokemon, moves, abilities, items.
class FakeLookups implements TeamLookups {
  static final pokemon = [
    for (final p in [(1, 'bulbasaur'), (4, 'charmander'), (7, 'squirtle')])
      {'pok_id': p.$1, 'pok_name': p.$2, 'types': 'grass'},
  ];
  static final moves = [
    {'move_id': 33, 'move_name': 'tackle', 'move_power': 40},
    {'move_id': 71, 'move_name': 'absorb', 'move_power': 20},
  ];
  static final abilities = [
    {'abi_id': 65, 'abi_name': 'overgrow'},
  ];
  static final items = [
    {'item_id': 4, 'item_name': 'master-ball'},
  ];

  @override
  Future<List<Map<String, dynamic>>> allPokemon() async => pokemon;
  @override
  Future<List<Map<String, dynamic>>> allMoves() async => moves;
  @override
  Future<List<Map<String, dynamic>>> allAbilities() async => abilities;
  @override
  Future<List<Map<String, dynamic>>> itemsByIds(List<int> ids) async =>
      items.where((i) => ids.contains(i['item_id'])).toList();
}

Future<Database> openUserDb() =>
    UserDatabase.openWith(databaseFactoryFfi, inMemoryDatabasePath);

void main() {
  setUpAll(sqfliteFfiInit);

  late Database db;
  late TeamRepository repo;

  Future<void> start([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    db = await openUserDb();
    repo = TeamRepository(openDatabase: () async => db, lookups: FakeLookups());
  }

  tearDown(() => db.close());

  group('teams', () {
    setUp(start);

    test('create, list in creation order, delete', () async {
      expect(await repo.createTeam('Alpha'), isNull);
      expect(await repo.createTeam('Beta'), isNull);
      expect((await repo.listTeams()).map((t) => t.name), ['Alpha', 'Beta']);

      final alpha = (await repo.listTeams()).first;
      await repo.deleteTeam(alpha.id);
      expect((await repo.listTeams()).map((t) => t.name), ['Beta']);
    });

    test('rejects empty and duplicate names, ignoring case and spacing',
        () async {
      await repo.createTeam('Rain');
      expect(await repo.createTeam('   '), 'Enter a team name.');
      expect(await repo.createTeam('Rain'), 'You already have that team.');
      expect(await repo.createTeam(' rain '), 'You already have that team.');
      expect(await repo.listTeams(), hasLength(1));
    });

    test('"teams" is an ordinary name now', () async {
      expect(await repo.createTeam('teams'), isNull);
    });

    test('rename keeps the team id and its pokemon', () async {
      await repo.createTeam('Old');
      final team = (await repo.listTeams()).single;
      await repo.addMember(team.id, 1);
      await repo.setMove(team.id, 0, 2, 71);

      expect(await repo.renameTeam(team.id, 'New'), isNull);

      final after = (await repo.listTeams()).single;
      expect(after.id, team.id);
      expect(after.name, 'New');
      final members = await repo.loadTeam(team.id);
      expect(members.single['pok_name'], 'bulbasaur');
      expect((members.single['moves'] as List)[2]['move_name'], 'absorb');
    });

    test('rename to its own name, or a new case of it, is allowed', () async {
      await repo.createTeam('Rain');
      final id = (await repo.listTeams()).single.id;
      expect(await repo.renameTeam(id, 'Rain'), isNull);
      expect(await repo.renameTeam(id, 'RAIN'), isNull);
      expect((await repo.listTeams()).single.name, 'RAIN');
    });

    test('rename to another team\'s name is rejected and changes nothing',
        () async {
      await repo.createTeam('One');
      await repo.createTeam('Two');
      final two = (await repo.listTeams()).last;
      expect(
          await repo.renameTeam(two.id, 'one'), 'You already have that team.');
      expect((await repo.listTeams()).map((t) => t.name), ['One', 'Two']);
    });

    test('deleting a team deletes its members too', () async {
      await repo.createTeam('Gone');
      final id = (await repo.listTeams()).single.id;
      await repo.addMember(id, 1);
      await repo.addMember(id, 4);
      await repo.deleteTeam(id);

      expect(await db.query('team_member'), isEmpty);
    });
  });

  group('members', () {
    late int teamId;

    setUp(() async {
      await start();
      await repo.createTeam('Squad');
      teamId = (await repo.listTeams()).single.id;
    });

    test('add fills slots in order and stops at six', () async {
      for (var i = 0; i < 6; i++) {
        expect(await repo.addMember(teamId, 1), i);
      }
      expect(await repo.addMember(teamId, 4), isNull);
      expect(await repo.loadTeam(teamId), hasLength(6));
    });

    test('loadTeam resolves names, moves, ability and item from the IDs',
        () async {
      await repo.addMember(teamId, 4);
      await repo.setMove(teamId, 0, 0, 33);
      await repo.setMove(teamId, 0, 3, 71);
      await repo.setAbility(teamId, 0, 65);
      await repo.setItem(teamId, 0, 4);

      final m = (await repo.loadTeam(teamId)).single;
      expect(m['pok_name'], 'charmander');
      expect(m['slot'], 0);
      final moves = m['moves'] as List;
      expect(moves, hasLength(4));
      expect(moves[0]['move_name'], 'tackle');
      expect(moves[1], isNull);
      expect(moves[3]['move_name'], 'absorb');
      expect(m['ability']['abi_name'], 'overgrow');
      expect(m['item']['item_name'], 'master-ball');
    });

    test('a new member starts with no moves, ability or item', () async {
      await repo.addMember(teamId, 7);
      final m = (await repo.loadTeam(teamId)).single;
      expect(m['moves'], [null, null, null, null]);
      expect(m['ability'], isNull);
      expect(m['item'], isNull);
    });

    test('replace swaps the pokemon and clears its picks', () async {
      await repo.addMember(teamId, 1);
      await repo.setMove(teamId, 0, 0, 33);
      await repo.setAbility(teamId, 0, 65);
      await repo.setItem(teamId, 0, 4);

      await repo.replaceMember(teamId, 0, 7);

      final m = (await repo.loadTeam(teamId)).single;
      expect(m['pok_name'], 'squirtle');
      expect(m['moves'], [null, null, null, null]);
      expect(m['ability'], isNull);
      expect(m['item'], isNull);
    });

    test('remove closes the gap and keeps each pokemon\'s own picks', () async {
      await repo.addMember(teamId, 1);
      await repo.addMember(teamId, 4);
      await repo.addMember(teamId, 7);
      await repo.setMove(teamId, 2, 0, 71); // squirtle's move

      await repo.removeMember(teamId, 0);

      final members = await repo.loadTeam(teamId);
      expect(members.map((m) => m['pok_name']), ['charmander', 'squirtle']);
      expect(members.map((m) => m['slot']), [0, 1]);
      expect((members[1]['moves'] as List)[0]['move_name'], 'absorb');

      // The freed slot is reused, so the team still fills to six.
      expect(await repo.addMember(teamId, 1), 2);
    });

    test('a move index outside 0 to 3 is rejected', () async {
      await repo.addMember(teamId, 1);
      expect(() => repo.setMove(teamId, 0, 4, 33), throwsRangeError);
      expect(() => repo.setMove(teamId, 0, -1, 33), throwsRangeError);
    });

    test('ids that no longer exist show as empty slots, not a crash', () async {
      await repo.addMember(teamId, 1);
      await repo.setMove(teamId, 0, 1, 9999);
      await repo.setAbility(teamId, 0, 9999);
      await repo.setItem(teamId, 0, 9999);
      await db.insert('team_member',
          {'team_id': teamId, 'slot': 1, 'pok_id': 424242}); // gone Pokemon

      final members = await repo.loadTeam(teamId);
      expect(members, hasLength(1)); // the missing Pokemon is left out
      expect(members.single['moves'], [null, null, null, null]);
      expect(members.single['ability'], isNull);
      expect(members.single['item'], isNull);
    });

    test('foreign keys are on: members of a missing team are refused',
        () async {
      await expectLater(
          db.insert('team_member', {'team_id': 999, 'slot': 0, 'pok_id': 1}),
          throwsA(isA<DatabaseException>()));
    });
  });

  group('import from older versions', () {
    Map<String, Object> savedPrefs() => {
          'teams': ['Rain Team', 'Sun Team'],
          'Rain Team': jsonEncode([
            {
              'pok_id': 1,
              'pok_name': 'bulbasaur',
              'moves': [
                {'move_id': 33},
                null,
                {'move_id': 71},
                null
              ],
              'ability': {'abi_id': 65},
              'item': {'item_id': 4},
            },
            {
              'pok_id': 7,
              'moves': [null, null, null, null]
            },
          ]),
          'Sun Team': jsonEncode([
            {
              'pok_id': 4,
              'moves': [null, null, null, null]
            },
          ]),
          'assetDbVersion': 3, // unrelated key that must survive
        };

    test('imports teams, members and picks, then removes the old keys',
        () async {
      await start(savedPrefs());

      final teams = await repo.listTeams();
      expect(teams.map((t) => t.name), ['Rain Team', 'Sun Team']);

      final rain = await repo.loadTeam(teams[0].id);
      expect(rain.map((m) => m['pok_name']), ['bulbasaur', 'squirtle']);
      final moves = rain[0]['moves'] as List;
      expect(moves[0]['move_name'], 'tackle');
      expect(moves[1], isNull);
      expect(moves[2]['move_name'], 'absorb');
      expect(rain[0]['ability']['abi_name'], 'overgrow');
      expect(rain[0]['item']['item_name'], 'master-ball');
      expect(
          (await repo.loadTeam(teams[1].id)).single['pok_name'], 'charmander');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('teams'), isFalse);
      expect(prefs.containsKey('Rain Team'), isFalse);
      expect(prefs.containsKey('Sun Team'), isFalse);
      expect(prefs.getInt('assetDbVersion'), 3);
    });

    test('a fresh install has nothing to import and changes nothing', () async {
      await start({'assetDbVersion': 3});
      expect(await repo.listTeams(), isEmpty);
      expect(
          (await SharedPreferences.getInstance()).getInt('assetDbVersion'), 3);
    });

    test('importing twice does not duplicate teams', () async {
      await start(savedPrefs());
      final prefs = await SharedPreferences.getInstance();
      // The old keys reappear (for example a restored backup).
      await prefs.setStringList('teams', ['Rain Team']);
      await UserDatabase.importLegacyTeamsFromPreferences(db, prefs);

      expect((await repo.listTeams()).map((t) => t.name),
          ['Rain Team', 'Sun Team']);
      expect(prefs.containsKey('teams'), isFalse);
    });

    test('a failed import keeps every old key and retries next launch',
        () async {
      SharedPreferences.setMockInitialValues(savedPrefs());
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
            onCreate: (db, v) => UserDatabase.createSchema(db),
          ));
      repo =
          TeamRepository(openDatabase: () async => db, lookups: FakeLookups());
      final prefs = await SharedPreferences.getInstance();

      await UserDatabase.importLegacyTeamsFromPreferences(db, prefs,
          importer: (db, teams) async => throw StateError('disk full'));

      expect(prefs.getStringList('teams'), ['Rain Team', 'Sun Team']);
      expect(prefs.getString('Rain Team'), isNotNull);
      expect(prefs.getString('Sun Team'), isNotNull);
      expect(await repo.listTeams(), isEmpty);

      // Next launch: the real import runs and succeeds.
      await UserDatabase.importLegacyTeamsFromPreferences(db, prefs);
      expect((await repo.listTeams()).map((t) => t.name),
          ['Rain Team', 'Sun Team']);
      expect(prefs.containsKey('teams'), isFalse);
    });

    test('a half-finished import rolls back completely', () async {
      await start();
      // 7 members breaks the slot rule on the last one, after the first six
      // and the team row were already written inside the transaction.
      final tooBig = LegacyTeam('Too big', [
        for (var i = 0; i < 7; i++)
          const LegacyMember(pokId: 1, moveIds: [null, null, null, null]),
      ]);

      await expectLater(
          UserDatabase.importTeams(db, [tooBig]), throwsA(isA<Exception>()));

      expect(await db.query('team'), isEmpty);
      expect(await db.query('team_member'), isEmpty);
      expect(await db.query('app_meta'), isEmpty);
    });

    test('an imported name that already exists gets a suffix, not an error',
        () async {
      await start();
      await repo.createTeam('Rain Team');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('teams', ['Rain Team']);
      await prefs.setString(
          'Rain Team',
          jsonEncode([
            {'pok_id': 1}
          ]));

      await UserDatabase.importLegacyTeamsFromPreferences(db, prefs);

      expect((await repo.listTeams()).map((t) => t.name),
          ['Rain Team', 'Rain Team (2)']);
    });
  });
}
