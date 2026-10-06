// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
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
    return MaterialApp(
      title: 'LitWiki',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

enum Section {
  POKEMON('Pokemon', Icons.catching_pokemon_outlined, Icons.catching_pokemon),
  MOVES('Moves', Icons.flash_on_outlined, Icons.flash_on),
  ABILITIES('Abilities', Icons.star_outline, Icons.star),
  ITEMS('Items', Icons.backpack_outlined, Icons.backpack),
  NATURES(
      'Natures', Icons.energy_savings_leaf_outlined, Icons.energy_savings_leaf),
  LOCATIONS('Locations', Icons.map_outlined, Icons.map),
  GYMLEADERS('Gym Leaders', Icons.stadium_outlined, Icons.stadium),
  TEAMBUILDER('Team Builder', Icons.build_circle_outlined, Icons.build_circle),
  DAMAGECALCULATOR(
      'Damage Calculator', Icons.calculate_outlined, Icons.calculate);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const Section(this.label, this.icon, this.selectedIcon);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // How long typing must pause before the list re-queries the database.
  static const _searchDelay = Duration(milliseconds: 250);

  Section _selectedSection = Section.POKEMON;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (!mounted) return;
      setState(() {
        _searchQuery = query.trim();
      });
    });
  }

  void _selectSection(Section section) {
    // Each section starts with an empty search, so the box and the filter
    // can't disagree after switching.
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedSection = section;
      _searchQuery = '';
    });
  }

  bool get _hasSearch =>
      _selectedSection != Section.DAMAGECALCULATOR &&
      _selectedSection != Section.TEAMBUILDER &&
      _selectedSection != Section.LOCATIONS;

  Widget _buildBody() {
    switch (_selectedSection) {
      case Section.POKEMON:
        return PokemonPage(searchQuery: _searchQuery);
      case Section.MOVES:
        return MovesPage(searchQuery: _searchQuery);
      case Section.ABILITIES:
        return AbilitiesPage(searchQuery: _searchQuery);
      case Section.ITEMS:
        return ItemsPage(searchQuery: _searchQuery);
      case Section.NATURES:
        return NaturesPage(searchQuery: _searchQuery);
      case Section.LOCATIONS:
        return const LocationsPage();
      case Section.GYMLEADERS:
        return GymLeadersPage(searchQuery: _searchQuery);
      case Section.TEAMBUILDER:
        return const TeamBuilderPage();
      case Section.DAMAGECALCULATOR:
        return const DamageCalculatorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _hasSearch
            ? TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search ${_selectedSection.label.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              )
            : Text(_selectedSection.label),
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedSection.index,
        onDestinationSelected: (index) {
          _selectSection(Section.values[index]);
          Navigator.of(context).pop();
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
            child: Row(
              children: [
                Icon(Icons.catching_pokemon, color: scheme.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('LitWiki - The Pokémon Pokédex',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
          ),
          for (final s in Section.values)
            NavigationDrawerDestination(
              icon: Icon(s.icon),
              selectedIcon: Icon(s.selectedIcon),
              label: Text(s.label),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
