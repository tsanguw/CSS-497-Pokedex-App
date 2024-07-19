import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

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
        body = Center(child: Text('Default Page!'));
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
        title: Text(
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

// Define separate pages as StatelessWidget or StatefulWidget classes
class PokemonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Pokemon Page!'),
    );
  }
}

class MovesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Moves Page!'),
    );
  }
}

class AbilitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Abilities Page!'),
    );
  }
}

class ItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Items Page!'),
    );
  }
}

class NaturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Natures Page!'),
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
    return Center(
      child: Text('Welcome to the Gym Leaders Page!'),
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
