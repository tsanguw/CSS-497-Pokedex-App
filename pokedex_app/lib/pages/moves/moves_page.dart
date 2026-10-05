import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/move_tile.dart';
import '../../widgets/search_results.dart';
import 'move_detail_page.dart';

class MovesPage extends StatelessWidget {
  final String searchQuery;

  const MovesPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return SearchResults(
      searchQuery: searchQuery,
      load: (q) => DatabaseHelper().getAllMoves(searchQuery: q),
      emptyMessage: 'No moves found.',
      builder: (context, rows) => ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final move = rows[index];
          return MoveTile(
            move: move,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoveDetailPage(moveId: move['move_id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
