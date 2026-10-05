import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/move_filters.dart';
import '../../widgets/move_tile.dart';
import '../../widgets/state_views.dart';
import '../moves/move_detail_page.dart';

class PokemonMovesPage extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonMovesPage(
      {super.key, required this.pokemonId, required this.pokemonName});

  @override
  State<PokemonMovesPage> createState() => _PokemonMovesPageState();
}

class _PokemonMovesPageState extends State<PokemonMovesPage> {
  int? _selectedGeneration;
  int? _selectedMethod;
  List<Map<String, dynamic>> _moves = [];

  @override
  void initState() {
    super.initState();
    _fetchMoves();
  }

  Future<void> _fetchMoves() async {
    final moves = await DatabaseHelper().getPokemonMoveset(
      widget.pokemonId,
      generation: _selectedGeneration,
      method: _selectedMethod,
    );
    if (!mounted) return;
    setState(() {
      _moves = moves;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Move - ${pokemonName(widget.pokemonName)}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: MoveFilters(
              generation: _selectedGeneration,
              method: _selectedMethod,
              onGeneration: (g) {
                setState(() => _selectedGeneration = g);
                _fetchMoves();
              },
              onMethod: (m) {
                setState(() => _selectedMethod = m);
                _fetchMoves();
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _moves.isEmpty
                ? const EmptyView('No moves found for these filters.')
                : ListView.separated(
                    itemCount: _moves.length,
                    separatorBuilder: (_, __) =>
                        const Divider(indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final move = _moves[index];
                      return MoveTile(
                        move: move,
                        showLevel: true,
                        onTap: () => _showMoveOptionsDialog(context, move),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showMoveOptionsDialog(BuildContext context, Map<String, dynamic> move) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Select Action for ${prettyName(move['move_name'])}'),
          content: const Text('Do you want to view or select this move?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('View'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MoveDetailPage(moveId: move['move_id'] as int),
                  ),
                );
              },
            ),
            FilledButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(move);
              },
            ),
          ],
        );
      },
    );
  }
}
