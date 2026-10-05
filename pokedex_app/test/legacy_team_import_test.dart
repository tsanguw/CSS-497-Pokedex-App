import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/legacy_team_import.dart';

// What older versions of the app saved for one team member: the whole Pokemon
// row, plus full rows for each move, the ability and the item.
Map<String, dynamic> oldMember(
  int pokId, {
  List<int?> moves = const [null, null, null, null],
  int? ability,
  int? item,
}) =>
    {
      'pok_id': pokId,
      'pok_name': 'whatever',
      'types': 'grass, poison',
      'pok_height': 0.7,
      'b_hp': 45,
      'moves': [
        for (final m in moves)
          m == null ? null : {'move_id': m, 'move_name': 'x', 'move_pp': 15},
      ],
      'ability': ability == null ? null : {'abi_id': ability, 'abi_name': 'y'},
      'item': item == null ? null : {'item_id': item, 'item_name': 'z'},
    };

List<LegacyTeam> parse(Map<String, Object?> saved, {List<String>? names}) =>
    parseLegacyTeams(
      teamNames: names ?? saved.keys.toList(),
      readTeam: (name) {
        final v = saved[name];
        return v == null ? null : (v is String ? v : jsonEncode(v));
      },
    );

void main() {
  test('reads ids for pokemon, moves, ability and item', () {
    final teams = parse({
      'Rain Team': [
        oldMember(1, moves: [33, 71, null, 22], ability: 65, item: 4),
        oldMember(7),
      ],
    });

    expect(teams, hasLength(1));
    expect(teams.single.name, 'Rain Team');
    final first = teams.single.members[0];
    expect(first.pokId, 1);
    expect(first.moveIds, [33, 71, null, 22]);
    expect(first.abilityId, 65);
    expect(first.itemId, 4);
    final second = teams.single.members[1];
    expect(second.pokId, 7);
    expect(second.moveIds, [null, null, null, null]);
    expect(second.abilityId, isNull);
    expect(second.itemId, isNull);
  });

  test('keeps the order of the saved team list', () {
    final teams = parse({'B': [], 'A': [], 'C': []}, names: ['B', 'A', 'C']);
    expect(teams.map((t) => t.name), ['B', 'A', 'C']);
  });

  test('a team with no saved data, or empty data, has no members', () {
    final teams = parse({'Missing': null, 'Empty': []});
    expect(teams.map((t) => t.members.length), [0, 0]);
  });

  test('malformed JSON keeps the team but drops its members', () {
    final teams = parse({'Broken': '{not json', 'Wrong shape': '{"a": 1}'});
    expect(teams.map((t) => t.name), ['Broken', 'Wrong shape']);
    expect(teams.every((t) => t.members.isEmpty), isTrue);
  });

  test('skips members without a usable pok_id and keeps the rest', () {
    final teams = parse({
      'T': [
        oldMember(1),
        {'pok_name': 'no id'},
        {'pok_id': 'six'},
        'not a map',
        null,
        oldMember(4),
      ],
    });
    expect(teams.single.members.map((m) => m.pokId), [1, 4]);
  });

  test('tolerates odd moves, ability and item values', () {
    final teams = parse({
      'T': [
        {
          'pok_id': 25,
          'moves': [
            {'move_id': 'x'},
            3,
            {'move_id': 9.0},
          ],
          'ability': 'text',
          'item': {'item_id': null},
        },
        {'pok_id': 26, 'moves': 'nope'},
      ],
    });
    final a = teams.single.members[0];
    expect(a.moveIds, [null, null, 9, null]);
    expect(a.abilityId, isNull);
    expect(a.itemId, isNull);
    expect(teams.single.members[1].moveIds, [null, null, null, null]);
  });

  test('never reads more than $maxTeamSize members per team', () {
    final teams = parse({
      'Big': [for (var i = 1; i <= 9; i++) oldMember(i)],
    });
    expect(teams.single.members.map((m) => m.pokId), [1, 2, 3, 4, 5, 6]);
  });

  test('duplicate names, ignoring case, get a numeric suffix', () {
    final teams = parseLegacyTeams(
      teamNames: ['Team', 'team', 'TEAM', 'Other'],
      readTeam: (_) => null,
    );
    expect(teams.map((t) => t.name), ['Team', 'team (2)', 'TEAM (3)', 'Other']);
  });

  test('a duplicate keeps its own saved data, not the first copy', () {
    final teams = parseLegacyTeams(
      teamNames: ['Dup', 'Dup'],
      readTeam: (_) => jsonEncode([oldMember(5)]),
    );
    expect(teams.map((t) => t.name), ['Dup', 'Dup (2)']);
    expect(teams.every((t) => t.members.single.pokId == 5), isTrue);
  });

  test('skips blank names and trims the rest', () {
    final teams = parseLegacyTeams(
      teamNames: ['', '   ', '  Padded  '],
      readTeam: (name) =>
          name == '  Padded  ' ? jsonEncode([oldMember(3)]) : null,
    );
    expect(teams.map((t) => t.name), ['Padded']);
    expect(teams.single.members.single.pokId, 3);
  });
}
