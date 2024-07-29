import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamBuilderPage extends StatefulWidget {
  const TeamBuilderPage({super.key});

  @override
  _TeamBuilderPageState createState() => _TeamBuilderPageState();
}

class _TeamBuilderPageState extends State<TeamBuilderPage> {
  final List<String> _teams = [];
  final TextEditingController _teamNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _teams.addAll(prefs.getStringList('teams') ?? []);
    });
  }

  Future<void> _saveTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('teams', _teams);
  }

  void _addTeam() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new team'),
          content: TextField(
            controller: _teamNameController,
            decoration: const InputDecoration(hintText: "Enter team name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _teamNameController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (_teamNameController.text.isNotEmpty) {
                  setState(() {
                    _teams.add(_teamNameController.text);
                    _saveTeams();
                  });
                  _teamNameController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _renameTeam(int index, String newName) {
    setState(() {
      _teams[index] = newName;
      _saveTeams();
    });
  }

  void _deleteTeam(int index) {
    setState(() {
      _teams.removeAt(index);
      _saveTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _teams.isEmpty
          ? const Center(
              child: Text(
                'Welcome to the Team Builder!',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_teams[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamPage(
                          teamName: _teams[index],
                          onRename: (newName) => _renameTeam(index, newName),
                          onDelete: () => _deleteTeam(index),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTeam,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TeamPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
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
      body: Center(
        child: Text('Welcome to $teamName team page!'),
      ),
    );
  }

  void _renameTeam(BuildContext context) {
    final TextEditingController renameController = TextEditingController();
    renameController.text = teamName;

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
                  onRename(renameController.text);
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
                onDelete();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }
}
