import 'package:flutter/material.dart';
import '../../database_helper.dart';

class MoveDetailPage extends StatefulWidget {
  final int moveId;

  const MoveDetailPage({super.key, required this.moveId});

  @override
  _MoveDetailPageState createState() => _MoveDetailPageState();
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
    setState(() {
      _pokemonList = pokemonList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_moveDetails?['move_name'] ?? 'Loading...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _moveDetails == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${_moveDetails!['move_name'] ?? 'Unknown'}', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text('Type: ${_moveDetails!['type_name'] ?? 'Unknown'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Power: ${_moveDetails!['move_power'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Accuracy: ${_moveDetails!['move_accuracy'] ?? 'N/A'}%', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('PP: ${_moveDetails!['move_pp'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Effect: ${_moveDetails!['move_effect'] ?? 'No effect description available'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Can be learned by:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
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
                            });
                            _fetchPokemonList(); // Fetch Pokémon list based on filters
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
                            });
                            _fetchPokemonList(); // Fetch Pokémon list based on filters
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _pokemonList.isEmpty
                        ? const Text('No Pokémon found for the selected filters.', style: TextStyle(fontSize: 18))
                        : ListView.builder(
                            itemCount: _pokemonList.length,
                            itemBuilder: (context, index) {
                              final pokemon = _pokemonList[index];
                              return ListTile(
                                leading: Image.asset(
                                  'assets/sprites/pokemon/other/official-artwork/${pokemon['pok_id']}.png',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Image not available');
                                  },
                                ),
                                title: Text('${pokemon['pok_id']}. ${pokemon['pok_name']}'),
                                subtitle: Text('Type: ${pokemon['types']}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
