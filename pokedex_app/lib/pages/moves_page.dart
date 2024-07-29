import 'package:flutter/material.dart';
import '../database_helper.dart';

class MovesPage extends StatelessWidget {
  final String searchQuery;

  const MovesPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllMoves(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No moves found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final move = snapshot.data![index];
              return ListTile(
                title: Text('${move['move_name']}'),
                subtitle: Text('Type: ${move['type_name']} | Power: ${move['move_power']} | Accuracy: ${move['move_accuracy']}%'),
              );
            },
          );
        }
      },
    );
  }
}