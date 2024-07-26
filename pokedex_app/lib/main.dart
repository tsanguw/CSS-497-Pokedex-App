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
              title: const Text('Pokemon'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.POKEMON;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Moves'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.MOVES;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Abilities'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.ABILITIES;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Items'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.ITEMS;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Natures'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.NATURES;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Locations'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.LOCATIONS;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Gym Leaders'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.GYMLEADERS;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
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
                subtitle: Text('Type: ${pokemon['types']} | Height: ${pokemon['pok_height']} | Weight: ${pokemon['pok_weight']}'),
              );
            },
          );
        }
      },
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
                title: Text('${move['move_name'] ?? 'N/A'} | damage class - ${move['move_type'] ?? 'N/A'}'),
                subtitle: Text('Power: ${move['move_power'] ?? 'N/A'} | Accuracy: ${move['move_accuracy'] ?? 'N/A'}% | PP: ${move['move_pp'] ?? 'N/A'}'),
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
                subtitle: Text('+ ${nature['nat_increase'] ?? 'N/A'} | - ${nature['nat_decrease'] ?? 'N/A'}'),
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
              );
            },
          );
        }
      },
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