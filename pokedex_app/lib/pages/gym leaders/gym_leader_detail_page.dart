import 'package:flutter/material.dart';

class GymLeaderDetailPage extends StatelessWidget {
  final Map<String, dynamic> gymLeader;
  final List<Map<String, dynamic>> team;

  const GymLeaderDetailPage({
    super.key,
    required this.gymLeader,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gymLeader['trainer_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${gymLeader['trainer_name']}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Gym: ${gymLeader['trainer_gym_name'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Game: ${gymLeader['trainer_game'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Generation: ${gymLeader['trainer_gen'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                'Team:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var member in team)
                Card(
                  child: ListTile(
                    leading: Image.asset(
                      'assets/sprites/pokemon/other/official-artwork/${member['pok_id']}.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    ),
                    title: Text(
                        '${member['pok_name']} (Lv. ${member['pok_lvl']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Position: ${member['position']}'),
                        if (member['move1'] != null)
                          Text('Move 1: ${member['move1']}'),
                        if (member['move2'] != null)
                          Text('Move 2: ${member['move2']}'),
                        if (member['move3'] != null)
                          Text('Move 3: ${member['move3']}'),
                        if (member['move4'] != null)
                          Text('Move 4: ${member['move4']}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
