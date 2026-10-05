import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/state_views.dart';
import 'team_page.dart';

class TeamBuilderPage extends StatefulWidget {
  const TeamBuilderPage({super.key});

  @override
  State<TeamBuilderPage> createState() => _TeamBuilderPageState();
}

class _TeamBuilderPageState extends State<TeamBuilderPage> {
  final List<String> _teams = [];
  final TextEditingController _teamNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _teams.addAll(prefs.getStringList('teams') ?? []);
    });
  }

  Future<void> _saveTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('teams', _teams);
  }

  /// Team data is stored in SharedPreferences under the team's name, next to
  /// the 'teams' list itself, so a name must be unique and not 'teams'.
  String? _nameError(String name, {int? ignoreIndex}) {
    if (name.isEmpty) return 'Enter a team name.';
    if (name == 'teams') return 'That name is reserved.';
    for (var i = 0; i < _teams.length; i++) {
      if (i != ignoreIndex && _teams[i] == name) {
        return 'You already have that team.';
      }
    }
    return null;
  }

  void _addTeam() {
    String? error;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create a new team'),
            content: TextField(
              controller: _teamNameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Enter team name',
                errorText: error,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  _teamNameController.clear();
                  Navigator.of(context).pop();
                },
              ),
              FilledButton(
                child: const Text('Create'),
                onPressed: () {
                  final name = _teamNameController.text.trim();
                  final problem = _nameError(name);
                  if (problem != null) {
                    setDialogState(() => error = problem);
                    return;
                  }
                  setState(() {
                    _teams.add(name);
                    _saveTeams();
                  });
                  _teamNameController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns an error message, or null once renamed. Moves the team's saved
  /// Pokémon to the new name so renaming doesn't lose them.
  Future<String?> _renameTeam(int index, String newName) async {
    final name = newName.trim();
    final oldName = _teams[index];
    if (name == oldName) return null;
    final problem = _nameError(name, ignoreIndex: index);
    if (problem != null) return problem;

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(oldName);
    if (data != null) {
      await prefs.setString(name, data);
      await prefs.remove(oldName);
    }
    if (!mounted) return null;
    setState(() {
      _teams[index] = name;
    });
    await _saveTeams();
    return null;
  }

  void _deleteTeam(int index) {
    setState(() {
      _teams.removeAt(index);
      _saveTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _teams.isEmpty
          ? const MessageView(
              icon: Icons.groups_outlined,
              message: 'Build your first team. Tap New team to start.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: _teams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    minTileHeight: 64,
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: const Icon(Icons.catching_pokemon),
                    ),
                    title: Text(_teams[index], style: text.titleMedium),
                    trailing: Icon(Icons.chevron_right, color: scheme.outline),
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTeam,
        icon: const Icon(Icons.add),
        label: const Text('New team'),
      ),
    );
  }
}
