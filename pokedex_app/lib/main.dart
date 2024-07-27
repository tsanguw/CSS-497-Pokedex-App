// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

enum Section {
  POKEMON,
  MOVES,
  ABILITIES,
  ITEMS,
  NATURES,
  LOCATIONS,
  GYMLEADERS,
  DAMAGECALCULATOR,
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Section _selectedSection = Section.POKEMON; // Set default page to Pokémon

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_selectedSection) {
      case Section.POKEMON:
        body = PokemonPage();
        break;
      case Section.MOVES:
        body = MovesPage();
        break;
      case Section.ABILITIES:
        body = AbilitiesPage();
        break;
      case Section.ITEMS:
        body = ItemsPage();
        break;
      case Section.NATURES:
        body = NaturesPage();
        break;
      case Section.LOCATIONS:
        body = LocationsPage();
        break;
      case Section.GYMLEADERS:
        body = GymLeadersPage();
        break;
      case Section.DAMAGECALCULATOR:
        body = DamageCalculatorPage();
        break;
      default:
        body = const Center(child: Text('Default Page!'));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Pokedex',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildDrawerHeader(),
            ListTile(
              leading: Icon(Icons.catching_pokemon),
              title: const Text('Pokemon'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.POKEMON;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.flash_on),
              title: const Text('Moves'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.MOVES;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: const Text('Abilities'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.ABILITIES;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.energy_savings_leaf),
              title: const Text('Natures'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.NATURES;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.backpack),
              title: const Text('Items'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.ITEMS;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: const Text('Locations'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.LOCATIONS;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.stadium),
              title: const Text('Gym Leaders'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.GYMLEADERS;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: const Text('Damage Calculator'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.DAMAGECALCULATOR;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: body,
      ),
    );
  }
}

// Define the custom DrawerHeader function
Widget buildDrawerHeader() {
  return const DrawerHeader(
    decoration: BoxDecoration(
      color: Colors.red,
    ),
    child: Text('Pokedex', style: TextStyle(color: Colors.white)),
  );
}

class PokemonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllPokemon(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Pokémon found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pokemon = snapshot.data![index];
              return ListTile(
                title: Text('${pokemon['pok_id']}. ${pokemon['pok_name']}'),
                subtitle: Text('Type: ${pokemon['types']} | Height: ${pokemon['pok_height']} m | Weight: ${pokemon['pok_weight']} kg'),
                onTap: () async {
                  final pokemonDetails = await DatabaseHelper().getPokemonDetails(pokemon['pok_id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailPage(
                        pokemon: pokemonDetails['pokemon'],
                        evolutions: pokemonDetails['evolutions'],
                        abilities: pokemonDetails['abilities'],
                        resistances: pokemonDetails['resistances'],
                        weaknesses: pokemonDetails['weaknesses'],
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

class PokemonDetailPage extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final List<Map<String, dynamic>> evolutions;
  final List<Map<String, dynamic>> abilities;
  final List<Map<String, dynamic>> weaknesses;
  final List<Map<String, dynamic>> resistances;

  PokemonDetailPage({
    required this.pokemon,
    required this.evolutions,
    required this.abilities,
    required this.weaknesses,
    required this.resistances,
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
              Text('Name: ${pokemon['pok_name']}', style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text('Type: ${pokemon['types']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Height: ${pokemon['pok_height'].toString()} meters', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Weight: ${pokemon['pok_weight'].toString()} kg', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text('Base Stats:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('HP: ${pokemon['b_hp']}', style: TextStyle(fontSize: 18)),
              Text('Attack: ${pokemon['b_atk']}', style: TextStyle(fontSize: 18)),
              Text('Defense: ${pokemon['b_def']}', style: TextStyle(fontSize: 18)),
              Text('Special Attack: ${pokemon['b_sp_atk']}', style: TextStyle(fontSize: 18)),
              Text('Special Defense: ${pokemon['b_sp_def']}', style: TextStyle(fontSize: 18)),
              Text('Speed: ${pokemon['b_speed']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text('Abilities:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
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
              SizedBox(height: 16),
              Text('Evolutions:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              for (var evolution in evolutions)
                ListTile(
                  title: Text(
                    '${evolution['pre_evol_pok_name'] ?? 'N/A'} -> ${evolution['evol_pok_name'] ?? 'N/A'}',
                  ),
                  subtitle: Text(
                    'Min Level: ${evolution['evol_min_lvl'] ?? 'N/A'} | Method: ${evolution['evol_method_name'] ?? 'N/A'}',
                  ),
                ),
              SizedBox(height: 16),
              Text('Weaknesses:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              for (var weakness in weaknesses)
                Text('${weakness['type_name']} (x${weakness['effectiveness']})', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text('Resistances:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              for (var resistance in resistances)
                Text('${resistance['type_name']} (x${resistance['effectiveness']})', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class MovesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllMoves(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No moves found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final move = snapshot.data![index];
              return ListTile(
                title: Text('${move['move_name'] ?? 'N/A'} | type - ${move['type_name'] ?? 'N/A'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Damage class - ${move['move_type'] ?? 'N/A'} | Power: ${move['move_power'] ?? 'N/A'} | Accuracy: ${move['move_accuracy'] ?? 'N/A'}% | PP: ${move['move_pp'] ?? 'N/A'}'),
                    Text('${move['move_effect'] ?? 'No description available'}'),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AbilitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllAbilities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No abilities found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final ability = snapshot.data![index];
              return ListTile(
                title: Text(ability['abi_name']),
                subtitle: Text(ability['abi_desc'] ?? 'No description available'),
              );
            },
          );
        }
      },
    );
  }
}

class ItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllItems(),
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
                title: Text('${item['item_name']} | category: ${item['item_cat_name']} '),
                subtitle: Text(
                  'Description: ${item['item_desc'] ?? 'No description available'}',
                ),
              );
            },
          );
        }
      },
    );
  }
}

class NaturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllNatures(),
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
                title: Text(nature['nat_name']),
                subtitle: Text('Increase: ${nature['nat_increase'] ?? 'N/A'} | Decrease: ${nature['nat_decrease'] ?? 'N/A'}'),
              );
            },
          );
        }
      },
    );
  }
}

class LocationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Locations Page!'),
    );
  }
}

class GymLeadersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getAllGymLeaders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No gym leaders found.'));
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
                      builder: (context) => GymLeaderDetailPage(gymLeader: gymLeaderDetails),
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

class GymLeaderDetailPage extends StatelessWidget {
  final Map<String, dynamic> gymLeader;

  GymLeaderDetailPage({required this.gymLeader});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gymLeader['trainer_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${gymLeader['trainer_name']}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'Gym: ${gymLeader['trainer_gym_name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Game: ${gymLeader['trainer_game'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Generation: ${gymLeader['trainer_gen'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class DamageCalculatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Damage Calculator Page!'),
    );
  }
}