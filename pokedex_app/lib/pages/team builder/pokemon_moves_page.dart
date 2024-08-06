import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../moves/move_detail_page.dart';

class PokemonMovesPage extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonMovesPage(
      {super.key, required this.pokemonId, required this.pokemonName});

  @override
  _PokemonMovesPageState createState() => _PokemonMovesPageState();
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
    setState(() {
      _moves = moves;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Move - ${widget.pokemonName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    hint: const Text('Select Generation'),
                    value: _selectedGeneration,
                    items: List.generate(9, (index) => index + 1)
                        .map((gen) => DropdownMenuItem<int>(
                              value: gen,
                              child: Text('Generation $gen'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGeneration = value;
                        _fetchMoves();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<int>(
                    hint: const Text('Select Method'),
                    value: _selectedMethod,
                    items: [
                      {'id': 1, 'name': 'Level Up'},
                      {'id': 2, 'name': 'Egg Move'},
                      {'id': 3, 'name': 'Tutor'},
                      {'id': 4, 'name': 'TM/HM'}
                    ].map<DropdownMenuItem<int>>((method) {
                      return DropdownMenuItem<int>(
                        value: method['id'] as int,
                        child: Text(method['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value;
                        _fetchMoves();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _moves.isEmpty
                ? const Center(
                    child: Text('No moves found for the selected filters.'))
                : ListView.builder(
                    itemCount: _moves.length,
                    itemBuilder: (context, index) {
                      final move = _moves[index];
                      return ListTile(
                        title: Text(
                            '${move['level_learned']} | ${move['move_name']}'),
                        subtitle: Text(
                            'Type: ${move['move_type']} | Power: ${move['move_power']} | Accuracy: ${move['move_accuracy']}% | PP: ${move['move_pp']}'),
                        onTap: () {
                          _showMoveOptionsDialog(context, move);
                        },
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action for ${move['move_name']}'),
          content: const Text('Do you want to view or select this move?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('View'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MoveDetailPage(moveId: move['move_id'] as int),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(move);
              },
            ),
          ],
        );
      },
    );
  }
}
