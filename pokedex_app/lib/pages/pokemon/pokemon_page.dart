import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/state_views.dart';
import 'pokemon_detail_page.dart';

class PokemonPage extends StatelessWidget {
  final String searchQuery;

  const PokemonPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllPokemon(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        } else if (snapshot.hasError) {
          return ErrorView(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyView('No Pokémon found.');
        } else {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 88, endIndent: 16),
            itemBuilder: (context, index) {
              final pokemon = snapshot.data![index];
              return PokemonTile(
                pokemon: pokemon,
                onTap: () async {
                  final pokemonDetails = await DatabaseHelper()
                      .getPokemonDetails(pokemon['pok_id']);
                  if (!context.mounted) return;
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
              );
            },
          );
        }
      },
    );
  }
}
