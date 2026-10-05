import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/state_views.dart';
import 'gym_leader_detail_page.dart';

class GymLeadersPage extends StatelessWidget {
  final String searchQuery;

  const GymLeadersPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllGymLeaders(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        } else if (snapshot.hasError) {
          return ErrorView(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyView('No gym leaders found.');
        } else {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 80, endIndent: 16),
            itemBuilder: (context, index) {
              final gymLeader = snapshot.data![index];
              final name = '${gymLeader['trainer_name']}';
              return ListTile(
                minTileHeight: 72,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                ),
                title: Text(name, style: text.titleMedium),
                subtitle: Text(
                  [
                    if (gymLeader['trainer_gym_name'] != null)
                      '${gymLeader['trainer_gym_name']}',
                    if (gymLeader['trainer_game'] != null)
                      prettyName(gymLeader['trainer_game']),
                    if (gymLeader['trainer_gen'] != null)
                      'Gen ${gymLeader['trainer_gen']}',
                  ].join(' · '),
                  style:
                      text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                trailing: Icon(Icons.chevron_right, color: scheme.outline),
                onTap: () async {
                  final gymLeaderDetails = await DatabaseHelper()
                      .getGymLeaderDetails(gymLeader['trainer_id']);
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GymLeaderDetailPage(
                        gymLeader: gymLeaderDetails['gym_leader'],
                        team: gymLeaderDetails['team'],
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
