import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/search_results.dart';
import 'ability_detail_page.dart';

class AbilitiesPage extends StatelessWidget {
  final String searchQuery;

  const AbilitiesPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SearchResults(
      searchQuery: searchQuery,
      load: (q) => DatabaseHelper().getAllAbilities(searchQuery: q),
      emptyMessage: 'No abilities found.',
      builder: (context, rows) => ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final ability = rows[index];
          final desc = ability['abi_desc'];
          return ListTile(
            title:
                Text(prettyName(ability['abi_name']), style: text.titleMedium),
            subtitle: desc == null || '$desc'.trim().isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$desc',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
            trailing: Icon(Icons.chevron_right, color: scheme.outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AbilityDetailPage(abilityId: ability['abi_id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
