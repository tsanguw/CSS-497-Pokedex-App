import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/state_views.dart';

class NaturesPage extends StatelessWidget {
  final String searchQuery;

  const NaturesPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllNatures(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        } else if (snapshot.hasError) {
          return ErrorView(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyView('No natures found.');
        } else {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final nature = snapshot.data![index];
              final up = nature['nat_increase'];
              final down = nature['nat_decrease'];
              final neutral = up == null || down == null || up == down;
              return ListTile(
                title: Text(prettyName(nature['nat_name']),
                    style: text.titleMedium),
                trailing: neutral
                    ? Text('Neutral',
                        style: text.labelLarge
                            ?.copyWith(color: scheme.onSurfaceVariant))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StatChange(
                              up: true, label: prettyName(up), text: text),
                          _StatChange(
                              up: false, label: prettyName(down), text: text),
                        ],
                      ),
              );
            },
          );
        }
      },
    );
  }
}

class _StatChange extends StatelessWidget {
  final bool up;
  final String label;
  final TextTheme text;

  const _StatChange({
    required this.up,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color = up ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(up ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: text.labelLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
