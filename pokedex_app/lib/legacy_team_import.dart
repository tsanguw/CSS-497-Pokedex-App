// Reads teams saved by older versions of the app.
//
// Those versions kept a `teams` list of names in SharedPreferences and, for
// each team, a JSON string stored under a key equal to the team's name. Each
// member was a full copy of the Pokemon row plus `moves`, `ability` and
// `item` rows. Only the IDs are needed now; everything else is looked up
// from the bundled database when a team is shown.
//
// This file is pure Dart so the parsing can be tested without a database.

import 'dart:convert';

const int maxTeamSize = 6;

class LegacyMember {
  final int pokId;
  final List<int?> moveIds; // always 4 entries
  final int? abilityId;
  final int? itemId;

  const LegacyMember({
    required this.pokId,
    required this.moveIds,
    this.abilityId,
    this.itemId,
  });
}

class LegacyTeam {
  final String name;
  final List<LegacyMember> members;

  const LegacyTeam(this.name, this.members);
}

/// Parses every team in [teamNames]. [readTeam] returns the saved JSON for a
/// team name, or null if there is none.
///
/// Bad data is skipped rather than fatal: a team whose JSON can't be read
/// comes through with no members, and a member without a usable `pok_id` is
/// dropped. Blank names are skipped, names that repeat (ignoring case) get a
/// numeric suffix so they stay unique, and a team keeps at most
/// [maxTeamSize] members.
List<LegacyTeam> parseLegacyTeams({
  required List<String> teamNames,
  required String? Function(String teamName) readTeam,
}) {
  final used = <String>{};
  final teams = <LegacyTeam>[];

  for (final rawName in teamNames) {
    final name = rawName.trim();
    if (name.isEmpty) continue;

    var unique = name;
    for (var n = 2; used.contains(unique.toLowerCase()); n++) {
      unique = '$name ($n)';
    }
    used.add(unique.toLowerCase());

    teams.add(LegacyTeam(unique, _parseMembers(readTeam(rawName))));
  }
  return teams;
}

List<LegacyMember> _parseMembers(String? json) {
  if (json == null) return const [];
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } catch (_) {
    return const [];
  }
  if (decoded is! List) return const [];

  final members = <LegacyMember>[];
  for (final entry in decoded) {
    if (members.length == maxTeamSize) break;
    if (entry is! Map) continue;
    final pokId = _asInt(entry['pok_id']);
    if (pokId == null) continue;

    final rawMoves = entry['moves'];
    final moveIds = List<int?>.filled(4, null);
    if (rawMoves is List) {
      for (var i = 0; i < 4 && i < rawMoves.length; i++) {
        final move = rawMoves[i];
        if (move is Map) moveIds[i] = _asInt(move['move_id']);
      }
    }

    final ability = entry['ability'];
    final item = entry['item'];
    members.add(LegacyMember(
      pokId: pokId,
      moveIds: moveIds,
      abilityId: ability is Map ? _asInt(ability['abi_id']) : null,
      itemId: item is Map ? _asInt(item['item_id']) : null,
    ));
  }
  return members;
}

int? _asInt(Object? value) => value is num ? value.toInt() : null;
