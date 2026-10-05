import 'package:flutter/material.dart';
import '../../widgets/format.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/section_card.dart';

class GymLeaderDetailPage extends StatelessWidget {
  final Map<String, dynamic> gymLeader;
  final List<Map<String, dynamic>> team;

  const GymLeaderDetailPage({
    super.key,
    required this.gymLeader,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final name = '${gymLeader['trainer_name']}';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: text.headlineMedium
                          ?.copyWith(color: scheme.onPrimaryContainer)),
                  const SizedBox(height: 4),
                  Text(
                    [
                      gymLeader['trainer_gym_name'] ?? 'Unknown gym',
                      if (gymLeader['trainer_game'] != null)
                        prettyName(gymLeader['trainer_game']),
                      if (gymLeader['trainer_gen'] != null)
                        'Gen ${gymLeader['trainer_gen']}',
                    ].join(' · '),
                    style: text.bodyLarge
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Team', style: text.titleMedium),
          const SizedBox(height: 8),
          if (team.isEmpty)
            Text('No team listed.',
                style:
                    text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          for (final member in team) ...[
            SectionCard(
              title:
                  '${pokemonName(member['pok_name'])}  ·  Lv ${member['pok_lvl']}',
              trailing: PokemonArtwork(
                  id: member['pok_id'] as int, size: 56, cacheWidth: 150),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in const ['move1', 'move2', 'move3', 'move4'])
                    if (member[key] != null)
                      Chip(
                        label: Text(prettyName(member[key])),
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
