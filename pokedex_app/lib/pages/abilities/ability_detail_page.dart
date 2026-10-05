import 'package:flutter/material.dart';
import '../../database_helper.dart';
import '../../widgets/format.dart';
import '../../widgets/pokemon_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';

class AbilityDetailPage extends StatelessWidget {
  final int abilityId;

  const AbilityDetailPage({super.key, required this.abilityId});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper().getAbilityDetails(abilityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const LoadingView());
        } else if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: ErrorView(snapshot.error));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
              appBar: AppBar(),
              body: const EmptyView('Ability details not found.'));
        }
        final ability = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(prettyName(ability['abi_name']))),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper().getPokemonWithAbility(abilityId),
            builder: (context, bearers) {
              final list = bearers.data ?? const <Map<String, dynamic>>[];
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SectionCard(
                          title: prettyName(ability['abi_name']),
                          child: Text(
                            '${ability['abi_desc'] ?? 'No description available.'}',
                            style: text.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Pokémon with this ability',
                            style: text.titleMedium),
                      ]),
                    ),
                  ),
                  if (bearers.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                        hasScrollBody: false, child: LoadingView())
                  else if (list.isEmpty)
                    const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyView('No Pokémon found.'))
                  else
                    SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const Divider(indent: 88, endIndent: 16),
                      itemBuilder: (context, index) =>
                          PokemonTile(pokemon: list[index]),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
