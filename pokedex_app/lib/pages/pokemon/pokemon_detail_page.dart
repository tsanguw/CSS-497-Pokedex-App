import 'package:flutter/material.dart';
import '../../database_helper.dart';

class PokemonDetailPage extends StatefulWidget {
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
  _PokemonDetailPageState createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  int? _selectedGeneration;
  int? _selectedMethod;
  List<Map<String, dynamic>> _moveset = [];

  @override
  void initState() {
    super.initState();
    _fetchMoveset();
  }

  Future<void> _fetchMoveset() async {
    final moveset = await DatabaseHelper().getPokemonMoveset(
      widget.pokemon['pok_id'],
      generation: _selectedGeneration,
      method: _selectedMethod,
    );
    setState(() {
      _moveset = moveset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon['pok_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/sprites/pokemon/other/official-artwork/${widget.pokemon['pok_id']}.png',
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Image not available');
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Name: ${widget.pokemon['pok_name']}',
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('Type: ${widget.pokemon['types']}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Height: ${widget.pokemon['pok_height'].toString()} meters',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Weight: ${widget.pokemon['pok_weight'].toString()} kg',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Base Stats:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('HP: ${widget.pokemon['b_hp']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Attack: ${widget.pokemon['b_atk']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Defense: ${widget.pokemon['b_def']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Special Attack: ${widget.pokemon['b_sp_atk']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Special Defense: ${widget.pokemon['b_sp_def']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Speed: ${widget.pokemon['b_speed']}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Abilities:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var ability in widget.abilities)
                ListTile(
                  title: Text(
                    ability['abi_name'],
                    style: TextStyle(
                      fontWeight: ability['is_hidden'] == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color:
                          ability['is_hidden'] == 1 ? Colors.red : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    ability['is_hidden'] == 1
                        ? 'Hidden Ability'
                        : 'Normal Ability',
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Evolutions:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (widget.evolutions.isEmpty)
                const Text('No Evolutions Available')
              else
                Column(
                  children: [
                    for (var evolution in widget.evolutions)
                      Column(
                        children: [
                          // Current to evolution
                          if (evolution['evol_pok_name'] != null)
                            ListTile(
                              title: Text(
                                '${evolution['current_pok_name']} -> ${evolution['evol_pok_name']}',
                              ),
                              subtitle: Text(
                                'Min Level: ${evolution['evol_min_lvl'] ?? 'N/A'} | Method: ${evolution['evol_method_name'] ?? 'N/A'}',
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              const Text('Weaknesses:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var weakness in widget.weaknesses)
                Text('${weakness['type_name']} (x${weakness['effectiveness']})',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Resistances:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var resistance in widget.resistances)
                Text(
                    '${resistance['type_name']} (x${resistance['effectiveness']})',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Immunities:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var immunity in widget.immunities)
                Text('${immunity['type_name']}',
                    style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Moveset:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      hint: const Text('Select Generation'),
                      value: _selectedGeneration,
                      items: List.generate(9, (index) => index + 1)
                          .map((gen) => DropdownMenuItem<int>(
                                value: gen,
                                child: Text('Generation $gen'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGeneration = value;
                          _fetchMoveset();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      hint: const Text('Select Method'),
                      value: _selectedMethod,
                      items: [
                        {'id': 1, 'name': 'Level Up'},
                        {'id': 2, 'name': 'Egg Move'},
                        {'id': 3, 'name': 'Tutor'},
                        {'id': 4, 'name': 'TM/HM'}
                      ].map<DropdownMenuItem<int>>((method) {
                        return DropdownMenuItem<int>(
                          value: method['id'] as int,
                          child: Text(method['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value;
                          _fetchMoveset();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_moveset.isEmpty)
                const Text('No moves available for the selected filters.',
                    style: TextStyle(fontSize: 18))
              else
                for (var move in _moveset)
                  ListTile(
                    title:
                        Text('${move['level_learned']} | ${move['move_name']}'),
                    subtitle: Text(
                        'Type: ${move['move_type']} | Power: ${move['move_power'] ?? 'N/A'} | Accuracy: ${move['move_accuracy'] ?? 'N/A'} | PP: ${move['move_pp'] ?? 'N/A'}'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
