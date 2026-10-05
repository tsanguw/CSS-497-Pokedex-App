import 'dart:async';

import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/search_results.dart';
import '../pokemon/pokemon_detail_page.dart';

class PokemonSelectorPage extends StatefulWidget {
  final String teamName;

  const PokemonSelectorPage({super.key, required this.teamName});

  @override
  State<PokemonSelectorPage> createState() => _PokemonSelectorPageState();
}

class _PokemonSelectorPageState extends State<PokemonSelectorPage> {
  static const _searchDelay = Duration(milliseconds: 250);

  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String newQuery) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (!mounted) return;
      setState(() {
        searchQuery = newQuery.trim();
      });
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search Pokémon',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _updateSearchQuery,
            ),
          ),
          Expanded(
            child: SearchResults(
              searchQuery: searchQuery,
              load: (q) => DatabaseHelper().getAllPokemon(searchQuery: q),
              emptyMessage: 'No Pokémon found.',
              builder: (context, rows) => ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) =>
                    const Divider(indent: 88, endIndent: 16),
                itemBuilder: (context, index) {
                  final pokemon = rows[index];
                  return PokemonTile(
                    pokemon: pokemon,
                    onTap: () => _showAddOrViewDialog(context, pokemon),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrViewDialog(
      BuildContext context, Map<String, dynamic> pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Action'),
          content: Text(
            'Do you want to view or add ${pokemonName(pokemon['pok_name'])} to the team?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('View'),
              onPressed: () async {
                final pokemonDetails =
                    await DatabaseHelper().getPokemonDetails(pokemon['pok_id']);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
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
            ),
            FilledButton(
              child: const Text('Add to Team'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pop(context, pokemon);
              },
            ),
          ],
        );
      },
    );
  }
}
