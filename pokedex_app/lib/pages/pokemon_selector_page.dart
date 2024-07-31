import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'pokemon_detail_page.dart';

class PokemonSelectorPage extends StatefulWidget {
  final String teamName;

  const PokemonSelectorPage({super.key, required this.teamName});

  @override
  _PokemonSelectorPageState createState() => _PokemonSelectorPageState();
}

class _PokemonSelectorPageState extends State<PokemonSelectorPage> {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  void _updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pokémon'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Pokémon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _updateSearchQuery,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper().getAllPokemon(searchQuery: searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Pokémon found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final pokemon = snapshot.data![index];
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
                        subtitle: Text(
                          'Type: ${pokemon['types']} | Height: ${pokemon['pok_height']} m | Weight: ${pokemon['pok_weight']} kg',
                        ),
                        onTap: () {
                          _showAddOrViewDialog(context, pokemon);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrViewDialog(BuildContext context, Map<String, dynamic> pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Action'),
          content: Text(
            'Do you want to view or add ${pokemon['pok_name']} to the team?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('View'),
              onPressed: () async {
                final pokemonDetails =
                    await DatabaseHelper().getPokemonDetails(pokemon['pok_id']);
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
            ),
            TextButton(
              child: const Text('Add to Team'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context, pokemon);
              },
            ),
          ],
        );
      },
    );
  }
}
