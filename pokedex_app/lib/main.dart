// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'pages/pokemon/pokemon_page.dart';
import 'pages/moves/moves_page.dart';
import 'pages/abilities/abilities_page.dart';
import 'pages/items/items_page.dart';
import 'pages/natures/natures_page.dart';
import 'pages/locations_page.dart';
import 'pages/gym leaders/gym_leaders_page.dart';
import 'pages/team builder/team_builder_page.dart';
import 'pages/damage_calculator_page.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  TEAMBUILDER,
  DAMAGECALCULATOR,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Section _selectedSection = Section.POKEMON;
  String _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_selectedSection) {
      case Section.POKEMON:
        body = PokemonPage(searchQuery: _searchQuery);
        break;
      case Section.MOVES:
        body = MovesPage(searchQuery: _searchQuery);
        break;
      case Section.ABILITIES:
        body = AbilitiesPage(searchQuery: _searchQuery);
        break;
      case Section.ITEMS:
        body = ItemsPage(searchQuery: _searchQuery);
        break;
      case Section.NATURES:
        body = NaturesPage(searchQuery: _searchQuery);
        break;
      case Section.LOCATIONS:
        body = const LocationsPage();
        break;
      case Section.GYMLEADERS:
        body = GymLeadersPage(searchQuery: _searchQuery);
        break;
      case Section.TEAMBUILDER:
        body = const TeamBuilderPage();
        break;
      case Section.DAMAGECALCULATOR:
        body = const DamageCalculatorPage();
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
        title: _selectedSection == Section.DAMAGECALCULATOR || _selectedSection == Section.TEAMBUILDER
            ? const Text('Pokedex', style: TextStyle(color: Colors.white))
            : TextField(
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildDrawerHeader(),
            ListTile(
              leading: const Icon(Icons.catching_pokemon),
              title: const Text('Pokemon'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.POKEMON;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Moves'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.MOVES;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Abilities'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.ABILITIES;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.backpack),
              title: const Text('Items'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.ITEMS;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.energy_savings_leaf),
              title: const Text('Natures'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.NATURES;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Locations'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.LOCATIONS;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.stadium),
              title: const Text('Gym Leaders'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.GYMLEADERS;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.build_circle),
              title: const Text('Team Builder'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.TEAMBUILDER;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Damage Calculator'),
              onTap: () {
                setState(() {
                  _selectedSection = Section.DAMAGECALCULATOR;
                });
                Navigator.of(context).pop();
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