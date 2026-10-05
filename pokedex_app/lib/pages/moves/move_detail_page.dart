import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/fact_tile.dart';
import '../../widgets/format.dart';
import '../../widgets/move_filters.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/type_chip.dart';

class MoveDetailPage extends StatefulWidget {
  final int moveId;

  const MoveDetailPage({super.key, required this.moveId});

  @override
  State<MoveDetailPage> createState() => _MoveDetailPageState();
}

class _MoveDetailPageState extends State<MoveDetailPage> {
  int? _selectedGeneration;
  int? _selectedMethod;
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _moveDetails;

  @override
  void initState() {
    super.initState();
    _fetchMoveDetails(); // Fetch move details only once
    _fetchPokemonList(); // Fetch Pokémon list based on filters
  }

  Future<void> _fetchMoveDetails() async {
    final moveDetails = await DatabaseHelper().getMoveDetails(widget.moveId);
    if (!mounted) return;
    setState(() {
      _moveDetails = moveDetails;
    });
  }

  Future<void> _fetchPokemonList() async {
    final pokemonList = await DatabaseHelper().getPokemonWithMove(
      widget.moveId,
      generation: _selectedGeneration,
      method: _selectedMethod,
    );
    if (!mounted) return;
    setState(() {
      _pokemonList = pokemonList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final move = _moveDetails;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(move == null ? 'Move' : prettyName(move['move_name'])),
      ),
      body: move == null
          ? const LoadingView()
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prettyName(move['move_name']),
                                  style: text.headlineMedium),
                              const SizedBox(height: 10),
                              if (move['type_name'] != null)
                                TypeChip(type: '${move['type_name']}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: FactTile(
                                  label: 'Power',
                                  value: fmtNum(move['move_power']))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: FactTile(
                                  label: 'Accuracy',
                                  value: move['move_accuracy'] == null
                                      ? '—'
                                      : '${fmtNum(move['move_accuracy'])}%')),
                          const SizedBox(width: 8),
                          Expanded(
                              child: FactTile(
                                  label: 'PP', value: fmtNum(move['move_pp']))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        title: 'Effect',
                        child: Text(
                          '${move['move_effect'] ?? 'No effect description available.'}',
                          style: text.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        title: 'Can be learned by',
                        child: MoveFilters(
                          generation: _selectedGeneration,
                          method: _selectedMethod,
                          onGeneration: (g) {
                            setState(() => _selectedGeneration = g);
                            _fetchPokemonList();
                          },
                          onMethod: (m) {
                            setState(() => _selectedMethod = m);
                            _fetchPokemonList();
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
                if (_pokemonList.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No Pokémon found for these filters.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: _pokemonList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(indent: 88, endIndent: 16),
                    itemBuilder: (context, index) =>
                        PokemonTile(pokemon: _pokemonList[index]),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }
}
