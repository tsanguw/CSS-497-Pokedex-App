import 'package:flutter/material.dart';
import '../database_helper.dart';

class NaturesPage extends StatelessWidget {
  final String searchQuery;

  NaturesPage({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllNatures(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No natures found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final nature = snapshot.data![index];
              return ListTile(
                title: Text('${nature['nat_name']}'),
              );
            },
          );
        }
      },
    );
  }
}