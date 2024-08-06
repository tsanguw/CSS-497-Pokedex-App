import 'package:flutter/material.dart';
import '../../database_helper.dart';

class PokemonAbilitiesPage extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonAbilitiesPage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  _PokemonAbilitiesPageState createState() => _PokemonAbilitiesPageState();
}

class _PokemonAbilitiesPageState extends State<PokemonAbilitiesPage> {
  List<Map<String, dynamic>> _abilities = [];

  @override
  void initState() {
    super.initState();
    _fetchAbilities();
  }

  Future<void> _fetchAbilities() async {
    final abilities =
        await DatabaseHelper().getPokemonAbilities(widget.pokemonId);
    setState(() {
      _abilities = abilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Ability - ${widget.pokemonName}'),
      ),
      body: _abilities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _abilities.length,
              itemBuilder: (context, index) {
                final ability = _abilities[index];
                return ListTile(
                  title: Text(
                    ability['abi_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ability['abi_desc'] ?? 'No description available',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ability['is_hidden'] == 1
                            ? 'Hidden Ability'
                            : 'Normal Ability',
                        style: TextStyle(
                          color: ability['is_hidden'] == 1
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context, ability);
                  },
                );
              },
            ),
    );
  }
}
