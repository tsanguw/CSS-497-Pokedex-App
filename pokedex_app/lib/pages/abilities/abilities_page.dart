import 'package:flutter/material.dart';
import '../../database_helper.dart';
import 'ability_detail_page.dart';

class AbilitiesPage extends StatelessWidget {
  final String searchQuery;

  const AbilitiesPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllAbilities(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No abilities found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final ability = snapshot.data![index];
              return ListTile(
                title: Text('${ability['abi_name']}'),
                subtitle: Text('${ability['abi_desc']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AbilityDetailPage(abilityId: ability['abi_id']),
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
