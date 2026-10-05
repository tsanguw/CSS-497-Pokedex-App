import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../theme/type_colors.dart';
import '../../widgets/fact_tile.dart';
import '../../widgets/format.dart';
import '../../widgets/move_filters.dart';
import '../../widgets/move_tile.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_bar.dart';
import '../../widgets/type_chip.dart';

class PokemonDetailPage extends StatefulWidget {
  final Map<String, dynamic> pokemon;
  final List<Map<String, dynamic>> evolutions;
  final List<Map<String, dynamic>> abilities;
  final List<Map<String, dynamic>> weaknesses;
  final List<Map<String, dynamic>> resistances;
  final List<Map<String, dynamic>> immunities;

  const PokemonDetailPage({
    super.key,
    required this.pokemon,
    required this.evolutions,
    required this.abilities,
    required this.weaknesses,
    required this.resistances,
    required this.immunities,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  int? _selectedGeneration;
  int? _selectedMethod;
  List<Map<String, dynamic>> _moveset = [];

  @override
  void initState() {
    super.initState();
    _fetchMoveset();
  }

  Future<void> _fetchMoveset() async {
    final moveset = await DatabaseHelper().getPokemonMoveset(
      widget.pokemon['pok_id'],
      generation: _selectedGeneration,
      method: _selectedMethod,
    );
    if (!mounted) return;
    setState(() {
      _moveset = moveset;
    });
  }

  String _fmt(Object? v) => fmtNum(v);

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final types = splitTypes(p['types']);
    final tint = typeColor(types.isEmpty ? null : types.first);
    final id = p['pok_id'] as int;

    final statValues = <String, int>{
      'HP': p['b_hp'] as int,
      'Attack': p['b_atk'] as int,
      'Defense': p['b_def'] as int,
      'Sp. Atk': p['b_sp_atk'] as int,
      'Sp. Def': p['b_sp_def'] as int,
      'Speed': p['b_speed'] as int,
    };
    final total = statValues.values.fold<int>(0, (a, b) => a + b);

    final evolutionRows = <String>{};
    final evolutionTiles = <Widget>[];
    for (final e in widget.evolutions) {
      if (e['evol_pok_name'] == null) continue;
      final key =
          '${e['current_pok_name']}>${e['evol_pok_name']}>${e['evol_method_name']}>${e['evol_min_lvl']}';
      if (!evolutionRows.add(key)) continue;
      final detail = [
        if (e['evol_min_lvl'] != null) 'Level ${e['evol_min_lvl']}',
        if (e['evol_method_name'] != null) prettyName(e['evol_method_name']),
      ].join(' · ');
      evolutionTiles.add(ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
            '${pokemonName(e['current_pok_name'])}  →  ${pokemonName(e['evol_pok_name'])}',
            style: text.bodyLarge),
        subtitle: detail.isEmpty ? null : Text(detail),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(pokemonName(p['pok_name']))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('#${id.toString().padLeft(3, '0')}',
                      style: text.titleMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                PokemonArtwork(id: id, size: 200),
                const SizedBox(height: 12),
                Text(pokemonName(p['pok_name']), style: text.headlineMedium),
                const SizedBox(height: 8),
                TypeChips(types: p['types'], alignment: WrapAlignment.center),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: FactTile(
                      label: 'Height', value: '${_fmt(p['pok_height'])} m')),
              const SizedBox(width: 12),
              Expanded(
                  child: FactTile(
                      label: 'Weight', value: '${_fmt(p['pok_weight'])} kg')),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Base stats',
            trailing: Text('Total $total',
                style:
                    text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            child: Column(
              children: [
                for (final s in statValues.entries)
                  StatBar(label: s.key, value: s.value),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Abilities',
            child: widget.abilities.isEmpty
                ? Text('No abilities listed.', style: text.bodyMedium)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in widget.abilities)
                        Chip(
                          label: Text(a['is_hidden'] == 1
                              ? '${prettyName(a['abi_name'])} (hidden)'
                              : prettyName(a['abi_name'])),
                          avatar: a['is_hidden'] == 1
                              ? const Icon(Icons.visibility_off_outlined,
                                  size: 16)
                              : null,
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Evolutions',
            child: evolutionTiles.isEmpty
                ? Text('Does not evolve.', style: text.bodyMedium)
                : Column(children: evolutionTiles),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Type matchups',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MatchupGroup(
                  label: 'Weak to',
                  entries: widget.weaknesses,
                ),
                _MatchupGroup(
                  label: 'Resists',
                  entries: widget.resistances,
                ),
                _MatchupGroup(
                  label: 'Immune to',
                  entries: widget.immunities,
                  immune: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Moveset',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoveFilters(
                  generation: _selectedGeneration,
                  method: _selectedMethod,
                  onGeneration: (g) {
                    setState(() => _selectedGeneration = g);
                    _fetchMoveset();
                  },
                  onMethod: (m) {
                    setState(() => _selectedMethod = m);
                    _fetchMoveset();
                  },
                ),
                const SizedBox(height: 8),
                if (_moveset.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No moves for these filters.',
                        style: text.bodyMedium),
                  )
                else
                  for (final move in _moveset) ...[
                    const Divider(),
                    MoveTile(
                      move: move,
                      showLevel: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchupGroup extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> entries;
  final bool immune;

  const _MatchupGroup({
    required this.label,
    required this.entries,
    this.immune = false,
  });

  String _multiplier(Object? v) {
    final d = (v as num).toDouble();
    if (d == d.roundToDouble()) return '×${d.toInt()}';
    return '×$d';
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in entries)
                TypeChip(
                  type: '${e['type_name']}',
                  suffix: immune ? null : _multiplier(e['effectiveness']),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
