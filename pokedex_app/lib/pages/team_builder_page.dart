import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'team_page.dart';

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
