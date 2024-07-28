import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'gym_leader_detail_page.dart';

class GymLeadersPage extends StatelessWidget {
  final String searchQuery;

  GymLeadersPage({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllGymLeaders(searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Gym Leaders found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final gymLeader = snapshot.data![index];
              return ListTile(
                title: Text(gymLeader['trainer_name']),
                subtitle: Text(
                  'Gym: ${gymLeader['trainer_gym_name']} | Game: ${gymLeader['trainer_game']} | Gen: ${gymLeader['trainer_gen']}',
                ),

                onTap: () async {
                  final gymLeaderDetails = await DatabaseHelper().getGymLeaderDetails(gymLeader['trainer_id']);
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