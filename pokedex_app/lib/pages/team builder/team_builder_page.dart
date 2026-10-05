import 'package:flutter/material.dart';
import '../../team_repository.dart';
import '../../widgets/state_views.dart';
import 'team_page.dart';

class TeamBuilderPage extends StatefulWidget {
  const TeamBuilderPage({super.key});

  @override
  State<TeamBuilderPage> createState() => _TeamBuilderPageState();
}

class _TeamBuilderPageState extends State<TeamBuilderPage> {
  final _repository = TeamRepository.instance;
  List<TeamSummary>? _teams; // null until the first load finishes
  Object? _loadError;
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
    try {
      final teams = await _repository.listTeams();
      if (!mounted) return;
      setState(() {
        _teams = teams;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e);
    }
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
                onPressed: () async {
                  final problem =
                      await _repository.createTeam(_teamNameController.text);
                  if (!context.mounted) return;
                  if (problem != null) {
                    setDialogState(() => error = problem);
                    return;
                  }
                  _teamNameController.clear();
                  Navigator.of(context).pop();
                  await _loadTeams();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns an error message, or null once renamed. The team's Pokemon are
  /// stored by team ID, so they stay with it.
  Future<String?> _renameTeam(TeamSummary team, String newName) async {
    final problem = await _repository.renameTeam(team.id, newName);
    if (problem == null) await _loadTeams();
    return problem;
  }

  Future<void> _deleteTeam(TeamSummary team) async {
    await _repository.deleteTeam(team.id);
    await _loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final teams = _teams;

    final Widget body;
    if (_loadError != null) {
      body = ErrorView(_loadError);
    } else if (teams == null) {
      body = const LoadingView();
    } else if (teams.isEmpty) {
      body = const MessageView(
        icon: Icons.groups_outlined,
        message: 'Build your first team. Tap New team to start.',
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: teams.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final team = teams[index];
          return Card(
            child: ListTile(
              minTileHeight: 64,
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(Icons.catching_pokemon),
              ),
              title: Text(team.name, style: text.titleMedium),
              trailing: Icon(Icons.chevron_right, color: scheme.outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamPage(
                      teamId: team.id,
                      teamName: team.name,
                      onRename: (newName) => _renameTeam(team, newName),
                      onDelete: () => _deleteTeam(team),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTeam,
        icon: const Icon(Icons.add),
        label: const Text('New team'),
      ),
    );
  }
}
