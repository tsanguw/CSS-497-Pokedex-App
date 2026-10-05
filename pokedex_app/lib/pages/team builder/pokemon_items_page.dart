import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/state_views.dart';

class PokemonItemsPage extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonItemsPage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  State<PokemonItemsPage> createState() => _PokemonItemsPageState();
}

class _PokemonItemsPageState extends State<PokemonItemsPage> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final items = await DatabaseHelper().getPokemonItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _filteredItems = items;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _items
          .where((item) =>
              item['item_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Item - ${pokemonName(widget.pokemonName)}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search items',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterItems,
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const EmptyView('No items found.')
                : ListView.separated(
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) =>
                        const Divider(indent: 88, endIndent: 16),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ListTile(
                        minTileHeight: 72,
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/sprites/items/${item['item_name']}.png',
                            cacheWidth: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image_not_supported_outlined,
                                color: scheme.outline),
                          ),
                        ),
                        title: Text(prettyName(item['item_name']),
                            style: text.titleMedium),
                        subtitle: Text(
                          '${item['item_desc'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
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
