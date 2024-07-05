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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedTitle = 'Pokedex'; // Initial title

  @override
  Widget build(BuildContext context) {
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
        title: Text(_selectedTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text('Pokedex', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: const Text('Pokemon'),
              onTap: () {
                setState(() {
                  _selectedTitle = 'Pokemon';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Moves'),
              onTap: () {
                setState(() {
                  _selectedTitle = 'Moves';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Abilities'),
              onTap: () {
                setState(() {
                  _selectedTitle = 'Abilities';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Items'),
              onTap: () {
                setState(() {
                  _selectedTitle = 'Items';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Natures'),
              onTap: () {
                setState(() {
                  _selectedTitle = 'Natures';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Hello World!'),
      ),
    );
  }
}