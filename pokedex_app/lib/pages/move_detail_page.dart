import 'package:flutter/material.dart';
import '../database_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchPokemonList();
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
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper().getMoveDetails(widget.moveId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Move details not found.'));
        } else {
          final move = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(move['move_name']),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${move['move_name']}', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text('Type: ${move['type_name']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Power: ${move['move_power']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Accuracy: ${move['move_accuracy']}%', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('PP: ${move['move_pp']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Effect: ${move['move_effect'] ?? 'No effect description available'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Can be learned by:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          hint: const Text('Select Generation'),
                          value: _selectedGeneration,
                          items: List.generate(8, (index) => index + 1)
                              .map((gen) => DropdownMenuItem<int>(
                                    value: gen,
                                    child: Text('Generation $gen'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGeneration = value;
                              _fetchPokemonList();
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
                              _fetchPokemonList();
                            });
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
      },
    );
  }
}
