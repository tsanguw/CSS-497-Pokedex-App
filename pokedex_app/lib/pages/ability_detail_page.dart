import 'package:flutter/material.dart';
import '../database_helper.dart';

class AbilityDetailPage extends StatelessWidget {
  final int abilityId;

  const AbilityDetailPage({super.key, required this.abilityId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper().getAbilityDetails(abilityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Ability details not found.'));
        } else {
          final ability = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(ability['abi_name']),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${ability['abi_name']}', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text('Description: ${ability['abi_desc'] ?? 'No description available'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Possible Bearers:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper().getPokemonWithAbility(abilityId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No Pokémon found.'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final pokemon = snapshot.data![index];
                              return ListTile(
                                leading: Image.asset(
                                  'assets/sprites/pokemon/other/official-artwork/${pokemon['pok_id']}.png',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Image not available');
                                  },
                                ),
                                title: Text('${pokemon['pok_id']}. ${pokemon['pok_name']}'),
                                subtitle: Text('Type: ${pokemon['types']}'),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
