import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/state_views.dart';
import '../pokemon/pokemon_detail_page.dart';

class PokemonSelectorPage extends StatefulWidget {
  final String teamName;

  const PokemonSelectorPage({super.key, required this.teamName});

  @override
  State<PokemonSelectorPage> createState() => _PokemonSelectorPageState();
}

class _PokemonSelectorPageState extends State<PokemonSelectorPage> {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                        onTap: () => _showAddOrViewDialog(context, pokemon),
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
