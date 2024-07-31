import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'pokemon_detail_page.dart';

class PokemonSelectorPage extends StatelessWidget {
  final String teamName;
  final String searchQuery;

  const PokemonSelectorPage({super.key, required this.teamName, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pokémon'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                  subtitle: Text('Type: ${pokemon['types']} | Height: ${pokemon['pok_height']} m | Weight: ${pokemon['pok_weight']} kg'),
                  onTap: () {
                    _showAddOrViewDialog(context, pokemon);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showAddOrViewDialog(BuildContext context, Map<String, dynamic> pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Action'),
          content: Text('Do you want to view or add ${pokemon['pok_name']} to the team?'),
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
                    builder: (context) => PokemonDetailPage(
                      pokemon: pokemon,
                      evolutions: const [], // Replace with actual data
                      abilities: const [], // Replace with actual data
                      weaknesses: const [], // Replace with actual data
                      resistances: const [], // Replace with actual data
                      immunities: const [], // Replace with actual data
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
