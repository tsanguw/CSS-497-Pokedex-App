import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/search_results.dart';

class ItemsPage extends StatelessWidget {
  final String searchQuery;

  const ItemsPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SearchResults(
      searchQuery: searchQuery,
      load: (q) => DatabaseHelper().getAllItems(searchQuery: q),
      emptyMessage: 'No items found.',
      builder: (context, rows) => ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(indent: 88, endIndent: 16),
        itemBuilder: (context, index) {
          final item = rows[index];
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
            title: Text(prettyName(item['item_name']), style: text.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prettyName(item['item_cat_name']),
                    style: text.labelMedium?.copyWith(
                        color: scheme.primary, fontWeight: FontWeight.w600),
                  ),
                  if (item['item_desc'] != null)
                    Text(
                      '${item['item_desc']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
