import 'package:flutter/material.dart';
import 'package:pokedex_app/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'pokemon_selector_page.dart';
import '../pokemon/pokemon_detail_page.dart';
import 'pokemon_moves_page.dart';

class TeamPage extends StatefulWidget {
  final String teamName;
  final Function(String) onRename;
  final VoidCallback onDelete;

  const TeamPage({
    super.key,
    required this.teamName,
    required this.onRename,
    required this.onDelete,
  });

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Map<String, dynamic>> _team = [];

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final teamString = prefs.getString(widget.teamName);
    if (teamString != null) {
      final teamList = json.decode(teamString) as List<dynamic>;
      setState(() {
        _team = teamList.map((pokemon) {
          return {
            ...pokemon as Map<String, dynamic>,
            'moves': (pokemon['moves'] as List<dynamic>)
                .map((move) => move == null ? null : move as Map<String, dynamic>)
                .toList()
          };
        }).toList();
      });
    }
  }

  Future<void> _saveTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final teamString = json.encode(_team);
    await prefs.setString(widget.teamName, teamString);
  }

  void _addPokemonToTeam(Map<String, dynamic> pokemon) {
    setState(() {
      if (_team.length < 6) {
        _team.add({
          ...pokemon,
          'moves': List<Map<String, dynamic>?>.filled(4, null),
        });
        _saveTeam();
      }
    });
  }

  void _removePokemonFromTeam(int index) {
    setState(() {
      _team.removeAt(index);
      _saveTeam();
    });
  }

  void _setPokemonMove(int pokemonIndex, int moveIndex, Map<String, dynamic> move) {
    setState(() {
      // Initialize the moves list if it is null
      if (_team[pokemonIndex]['moves'] == null) {
        _team[pokemonIndex]['moves'] = List<Map<String, dynamic>?>.filled(4, null);
      }
      _team[pokemonIndex]['moves'][moveIndex] = move;
      _saveTeam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Rename') {
                _renameTeam(context);
              } else if (value == 'Delete') {
                _deleteTeam(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Rename', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_team.isEmpty)
            const Center(
              child: Text('No Pokémon in the team. Add some!'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _team.length,
                itemBuilder: (context, index) {
                  final pokemon = _team[index];
                  return ExpansionTile(
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
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, moveIndex) {
                          final moves = pokemon['moves'] as List<Map<String, dynamic>?>?;
                          final move = moves?[moveIndex];
                          return GestureDetector(
                            onTap: () async {
                              final selectedMove = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PokemonMovesPage(
                                    pokemonId: pokemon['pok_id'],
                                    pokemonName: pokemon['pok_name'],
                                  ),
                                ),
                              );
                              if (selectedMove != null) {
                                _setPokemonMove(index, moveIndex, selectedMove);
                              }
                            },
                            child: Card(
                              color: Colors.grey[200],
                              child: Center(
                                child: move != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            move['move_name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'Power: ${move['move_power'] ?? 'N/A'} | '
                                            'Acc: ${move['move_accuracy'] ?? 'N/A'}% | '
                                            'PP: ${move['move_pp'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis, // Handle overflow
                                          ),
                                        ],
                                      )
                                    : const Text('Select Move',
                                        textAlign: TextAlign.center),
                              ),
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          _showOptionsDialog(context, index, pokemon);
                        },
                        child: const Text('Options'),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedPokemon = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonSelectorPage(teamName: widget.teamName),
            ),
          );

          if (selectedPokemon != null) {
            _addPokemonToTeam(selectedPokemon);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, int index, Map<String, dynamic> pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options for ${pokemon['pok_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final pokemonDetails = await DatabaseHelper().getPokemonDetails(pokemon['pok_id']);
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailPage(
                        pokemon: pokemonDetails['pokemon'],
                        evolutions: pokemonDetails['evolutions'],
                        abilities: pokemonDetails['abilities'],
                        resistances: pokemonDetails['resistances'],
                        weaknesses: pokemonDetails['weaknesses'],
                        immunities: pokemonDetails['immunities'],
                      ),
                    ),
                  );
                },
                child: const Text('View Pokémon Info'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final selectedPokemon = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonSelectorPage(teamName: widget.teamName),
                    ),
                  );
                  if (selectedPokemon != null) {
                    setState(() {
                      _team[index] = {
                        ...selectedPokemon,
                        'moves': List<Map<String, dynamic>?>.filled(4, null),
                      };
                      _saveTeam();
                    });
                  }
                },
                child: const Text('Replace Pokémon'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _removePokemonFromTeam(index);
                },
                child: const Text('Remove Pokémon'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _renameTeam(BuildContext context) {
    final TextEditingController renameController = TextEditingController();
    renameController.text = widget.teamName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Team'),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(hintText: "Enter new team name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                if (renameController.text.isNotEmpty) {
                  widget.onRename(renameController.text);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to the previous screen
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTeam(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Team'),
          content: const Text('Are you sure you want to delete this team?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(widget.teamName);
                widget.onDelete();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }
}
