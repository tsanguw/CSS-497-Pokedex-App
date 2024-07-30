import 'package:flutter/material.dart';

class TeamPage extends StatefulWidget {
  final String teamName;
  final Function(String) onRename;
  final VoidCallback onDelete;

  const TeamPage({
    super.key,
    required this.teamName,
    required this.onRename,
    required this.onDelete,
  });

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final List<String> _teamMembers = [];
  final TextEditingController _pokemonNameController = TextEditingController();

  void _addPokemon() {
    if (_teamMembers.length < 6) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Pokémon'),
            content: TextField(
              controller: _pokemonNameController,
              decoration: const InputDecoration(hintText: "Enter Pokémon name"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  _pokemonNameController.clear();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  if (_pokemonNameController.text.isNotEmpty) {
                    setState(() {
                      _teamMembers.add(_pokemonNameController.text);
                    });
                    _pokemonNameController.clear();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A team can have up to 6 Pokémon only.')),
      );
    }
  }

  void _renameTeam(BuildContext context) {
    final TextEditingController renameController = TextEditingController();
    renameController.text = widget.teamName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Team'),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(hintText: "Enter new team name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                if (renameController.text.isNotEmpty) {
                  widget.onRename(renameController.text);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to the previous screen
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTeam(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Team'),
          content: const Text('Are you sure you want to delete this team?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                widget.onDelete();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Rename') {
                _renameTeam(context);
              } else if (value == 'Delete') {
                _deleteTeam(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Rename', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _teamMembers.isEmpty
          ? const Center(
              child: Text('No Pokémon in the team. Add some Pokémon!'),
            )
          : ListView.builder(
              itemCount: _teamMembers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_teamMembers[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _teamMembers.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPokemon,
        child: const Icon(Icons.add),
      ),
    );
  }
}
