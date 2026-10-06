import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/search_results.dart';
import 'pokemon_detail_page.dart';

class PokemonPage extends StatelessWidget {
  final String searchQuery;
  final bool gridView;

  const PokemonPage({
    super.key,
    required this.searchQuery,
    this.gridView = false,
  });

  Future<void> _openDetails(BuildContext context, int pokId) async {
    final pokemonDetails = await DatabaseHelper().getPokemonDetails(pokId);
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
  }

  @override
  Widget build(BuildContext context) {
    return SearchResults(
      searchQuery: searchQuery,
      load: (q) => DatabaseHelper().getAllPokemon(searchQuery: q),
      emptyMessage: 'No Pokémon found.',
      builder: (context, rows) {
        if (gridView) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.74,
            ),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final pokemon = rows[index];
              return PokemonCard(
                pokemon: pokemon,
                onTap: () => _openDetails(context, pokemon['pok_id']),
              );
            },
          );
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(indent: 88, endIndent: 16),
          itemBuilder: (context, index) {
            final pokemon = rows[index];
            return PokemonTile(
              pokemon: pokemon,
              onTap: () => _openDetails(context, pokemon['pok_id']),
            );
          },
        );
      },
    );
  }
}
