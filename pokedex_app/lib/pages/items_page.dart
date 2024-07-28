import 'package:flutter/material.dart';
import '../database_helper.dart';

class ItemsPage extends StatelessWidget {
  final String searchQuery;

  ItemsPage({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllItems(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No items found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                title: Text('${item['item_name']}'),
                subtitle: Text('${item['item_desc']} | Category: ${item['item_cat_name']}'),
              );
            },
          );
        }
      },
    );
  }
}