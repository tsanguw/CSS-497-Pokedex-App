import 'package:flutter/material.dart';

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
        body = Center(child: Text('Welcome to the Pokemon Page!'));
        break;
      case Section.MOVES:
        body = Center(child: Text('Welcome to the Moves Page!'));
        break;
      case Section.ABILITIES:
        body = Center(child: Text('Welcome to the Abilities Page!'));
        break;
      case Section.ITEMS:
        body = Center(child: Text('Welcome to the Items Page!'));
        break;
      case Section.NATURES:
        body = Center(child: Text('Welcome to the Natures Page!'));
        break;
      default:
        body = Center(child: Text('Welcome to the Pokemon Page!'));
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
