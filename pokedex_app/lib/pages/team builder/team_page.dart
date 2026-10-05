import 'package:flutter/material.dart';
import 'package:pokedex_app/database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/state_views.dart';
import '../../widgets/type_chip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'pokemon_selector_page.dart';
import '../pokemon/pokemon_detail_page.dart';
import 'pokemon_moves_page.dart';
import 'pokemon_abilities_page.dart';
import 'pokemon_items_page.dart';

/// Owns its text controller so it is disposed only after the dialog's exit
/// animation has finished. (Disposing it when showDialog completes is too
/// early: the field is still on screen and throws "used after being disposed".)
class _RenameTeamDialog extends StatefulWidget {
  final String currentName;
  final Future<String?> Function(String) onRename;

  const _RenameTeamDialog({required this.currentName, required this.onRename});

  @override
  State<_RenameTeamDialog> createState() => _RenameTeamDialogState();
}

class _RenameTeamDialogState extends State<_RenameTeamDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.currentName);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final problem = await widget.onRename(_controller.text);
    if (!mounted) return;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Team'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter new team name',
          errorText: _error,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(onPressed: _submit, child: const Text('Rename')),
      ],
    );
  }
}

class TeamPage extends StatefulWidget {
  final String teamName;

  /// Returns an error message to show in the dialog, or null on success.
  final Future<String?> Function(String) onRename;
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
                .map((move) =>
                    move == null ? null : move as Map<String, dynamic>)
                .toList(),
            'ability': pokemon['ability']
                as Map<String, dynamic>?, // Add ability field
            'item': pokemon['item'] as Map<String, dynamic>?, // Add item field
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
          'ability': null, // Initialize ability as null
          'item': null, // Initialize item as null
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

  void _setPokemonMove(
      int pokemonIndex, int moveIndex, Map<String, dynamic> move) {
    setState(() {
      if (_team[pokemonIndex]['moves'] == null) {
        _team[pokemonIndex]['moves'] =
            List<Map<String, dynamic>?>.filled(4, null);
      }
      _team[pokemonIndex]['moves'][moveIndex] = move;
      _saveTeam();
    });
  }

  void _setPokemonAbility(int pokemonIndex, Map<String, dynamic> ability) {
    setState(() {
      _team[pokemonIndex]['ability'] = ability;
      _saveTeam();
    });
  }

  void _setPokemonItem(int pokemonIndex, Map<String, dynamic> item) {
    setState(() {
      _team[pokemonIndex]['item'] = item;
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
            const Expanded(
              child: MessageView(
                icon: Icons.catching_pokemon,
                message:
                    'No Pokémon in this team yet. Tap Add Pokémon to pick some.',
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _team.length,
                itemBuilder: (context, index) {
                  final pokemon = _team[index];
                  return ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: PokemonArtwork(
                      id: pokemon['pok_id'] as int,
                      size: 56,
                      cacheWidth: 150,
                    ),
                    title: Text(
                      '${pokemonName(pokemon['pok_name'])}  #${(pokemon['pok_id'] as int).toString().padLeft(3, '0')}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: TypeChips(types: pokemon['types'], compact: true),
                    ),
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, moveIndex) {
                          final moves =
                              pokemon['moves'] as List<Map<String, dynamic>?>?;
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Center(
                                child: move != null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            prettyName(move['move_name']),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'Power ${fmtNum(move['move_power'])} · '
                                            'Acc ${fmtNum(move['move_accuracy'])} · '
                                            'PP ${fmtNum(move['move_pp'])}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final selectedAbility = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PokemonAbilitiesPage(
                                        pokemonId: pokemon['pok_id'],
                                        pokemonName: pokemon['pok_name'],
                                      ),
                                    ),
                                  );
                                  if (selectedAbility != null) {
                                    _setPokemonAbility(index, selectedAbility);
                                  }
                                },
                                child: SizedBox(
                                  height: 65,
                                  child: Card(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            pokemon['ability'] != null
                                                ? prettyName(pokemon[
                                                    'ability']!['abi_name'])
                                                : 'Select Ability',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final selectedItem = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PokemonItemsPage(
                                        pokemonId: pokemon['pok_id'],
                                        pokemonName: pokemon['pok_name'],
                                      ),
                                    ),
                                  );
                                  if (selectedItem != null) {
                                    _setPokemonItem(index, selectedItem);
                                  }
                                },
                                child: SizedBox(
                                  height: 65,
                                  child: Card(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            pokemon['item'] != null
                                                ? prettyName(pokemon['item']![
                                                    'item_name'])
                                                : 'Select Item',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final selectedPokemon = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PokemonSelectorPage(teamName: widget.teamName),
            ),
          );

          if (selectedPokemon != null) {
            _addPokemonToTeam(selectedPokemon);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Pokémon'),
      ),
    );
  }

  void _showOptionsDialog(
      BuildContext context, int index, Map<String, dynamic> pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options for ${pokemonName(pokemon['pok_name'])}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final pokemonDetails = await DatabaseHelper()
                      .getPokemonDetails(pokemon['pok_id']);
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
                      builder: (context) =>
                          PokemonSelectorPage(teamName: widget.teamName),
                    ),
                  );
                  if (selectedPokemon != null) {
                    setState(() {
                      _team[index] = {
                        ...selectedPokemon,
                        'moves': List<Map<String, dynamic>?>.filled(4, null),
                        'ability': null,
                        'item': null,
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
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => _RenameTeamDialog(
        currentName: widget.teamName,
        onRename: widget.onRename,
      ),
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
