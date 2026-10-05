import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/state_views.dart';

class PokemonAbilitiesPage extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonAbilitiesPage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  State<PokemonAbilitiesPage> createState() => _PokemonAbilitiesPageState();
}

class _PokemonAbilitiesPageState extends State<PokemonAbilitiesPage> {
  List<Map<String, dynamic>> _abilities = [];

  @override
  void initState() {
    super.initState();
    _fetchAbilities();
  }

  Future<void> _fetchAbilities() async {
    final abilities =
        await DatabaseHelper().getPokemonAbilities(widget.pokemonId);
    if (!mounted) return;
    setState(() {
      _abilities = abilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Ability - ${pokemonName(widget.pokemonName)}'),
      ),
      body: _abilities.isEmpty
          ? const LoadingView()
          : ListView.separated(
              itemCount: _abilities.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final ability = _abilities[index];
                final hidden = ability['is_hidden'] == 1;
                return ListTile(
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(prettyName(ability['abi_name']),
                            style: text.titleMedium),
                      ),
                      if (hidden) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text('Hidden'),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    ability['abi_desc'] ?? 'No description available',
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  onTap: () {
                    Navigator.pop(context, ability);
                  },
                );
              },
            ),
    );
  }
}
