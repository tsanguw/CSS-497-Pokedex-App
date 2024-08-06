import 'package:flutter/material.dart';
import '../../database_helper.dart';

class PokemonItemsPage extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonItemsPage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  _PokemonItemsPageState createState() => _PokemonItemsPageState();
}

class _PokemonItemsPageState extends State<PokemonItemsPage> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final items = await DatabaseHelper().getPokemonItems();
    setState(() {
      _items = items;
      _filteredItems = items;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      _filteredItems = _items
          .where((item) =>
              item['item_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Item - ${widget.pokemonName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Items',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterItems,
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(child: Text('No items found.'))
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ListTile(
                        leading: Image.asset(
                          'assets/sprites/items/${item['item_name']}.png',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Image not available');
                          },
                        ),
                        title: Text(item['item_name']),
                        subtitle: Text(item['item_desc']),
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
