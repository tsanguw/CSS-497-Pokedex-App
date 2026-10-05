import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/move_tile.dart';
import '../../widgets/state_views.dart';
import 'move_detail_page.dart';

class MovesPage extends StatelessWidget {
  final String searchQuery;

  const MovesPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllMoves(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        } else if (snapshot.hasError) {
          return ErrorView(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyView('No moves found.');
        } else {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final move = snapshot.data![index];
              return MoveTile(
                move: move,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MoveDetailPage(moveId: move['move_id']),
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
