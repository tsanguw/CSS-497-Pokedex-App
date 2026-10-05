import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/search_results.dart';
import 'pokemon_detail_page.dart';

class PokemonPage extends StatelessWidget {
  final String searchQuery;

  const PokemonPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return SearchResults(
      searchQuery: searchQuery,
      load: (q) => DatabaseHelper().getAllPokemon(searchQuery: q),
      emptyMessage: 'No Pokémon found.',
      builder: (context, rows) => ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(indent: 88, endIndent: 16),
        itemBuilder: (context, index) {
          final pokemon = rows[index];
          return PokemonTile(
            pokemon: pokemon,
            onTap: () async {
              final pokemonDetails =
                  await DatabaseHelper().getPokemonDetails(pokemon['pok_id']);
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
      ),
    );
  }
}
