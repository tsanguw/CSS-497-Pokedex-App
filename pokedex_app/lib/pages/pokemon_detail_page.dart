import 'package:flutter/material.dart';

class PokemonDetailPage extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final List<Map<String, dynamic>> evolutions;
  final List<Map<String, dynamic>> abilities;
  final List<Map<String, dynamic>> weaknesses;
  final List<Map<String, dynamic>> resistances;
  final List<Map<String, dynamic>> immunities;

  const PokemonDetailPage({
    super.key, 
    required this.pokemon,
    required this.evolutions,
    required this.abilities,
    required this.weaknesses,
    required this.resistances,
    required this.immunities,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon['pok_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${pokemon['pok_name']}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('Type: ${pokemon['types']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Height: ${pokemon['pok_height'].toString()} meters', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Weight: ${pokemon['pok_weight'].toString()} kg', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Base Stats:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('HP: ${pokemon['b_hp']}', style: const TextStyle(fontSize: 18)),
              Text('Attack: ${pokemon['b_atk']}', style: const TextStyle(fontSize: 18)),
              Text('Defense: ${pokemon['b_def']}', style: const TextStyle(fontSize: 18)),
              Text('Special Attack: ${pokemon['b_sp_atk']}', style: const TextStyle(fontSize: 18)),
              Text('Special Defense: ${pokemon['b_sp_def']}', style: const TextStyle(fontSize: 18)),
              Text('Speed: ${pokemon['b_speed']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Abilities:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var ability in abilities)
                ListTile(
                  title: Text(
                    ability['abi_name'],
                    style: TextStyle(
                      fontWeight: ability['is_hidden'] == 1 ? FontWeight.bold : FontWeight.normal,
                      color: ability['is_hidden'] == 1 ? Colors.red : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    ability['is_hidden'] == 1 ? 'Hidden Ability' : 'Normal Ability',
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Evolutions:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var evolution in evolutions)
                ListTile(
                  title: Text(
                    '${evolution['pre_evol_pok_name'] ?? 'N/A'} -> ${evolution['evol_pok_name'] ?? 'N/A'}',
                  ),
                  subtitle: Text(
                    'Min Level: ${evolution['evol_min_lvl'] ?? 'N/A'} | Method: ${evolution['evol_method_name'] ?? 'N/A'}',
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Weaknesses:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var weakness in weaknesses)
                Text('${weakness['type_name']} (x${weakness['effectiveness']})', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Resistances:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var resistance in resistances)
                Text('${resistance['type_name']} (x${resistance['effectiveness']})', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Immunities:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var immunity in immunities)
                Text('${immunity['type_name']}', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
