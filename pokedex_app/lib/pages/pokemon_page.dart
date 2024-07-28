import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'pokemon_detail_page.dart';

class PokemonPage extends StatelessWidget {
  final String searchQuery;

  PokemonPage({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllPokemon(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Pokémon found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pokemon = snapshot.data![index];
              return ListTile(
                title: Text('${pokemon['pok_id']}. ${pokemon['pok_name']}'),
                subtitle: Text('Type: ${pokemon['types']} | Height: ${pokemon['pok_height']} | Weight: ${pokemon['pok_weight']}'),
                onTap: () async {
                  final pokemonDetails = await DatabaseHelper().getPokemonDetails(pokemon['pok_id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailPage(
                        pokemon: pokemonDetails['pokemon'],
                        evolutions: pokemonDetails['evolutions'],
                        abilities: pokemonDetails['abilities'],
                        resistances: pokemonDetails['resistances'],
                        weaknesses: pokemonDetails['weaknesses'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}