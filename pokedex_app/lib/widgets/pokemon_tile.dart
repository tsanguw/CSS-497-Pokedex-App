import 'package:flutter/material.dart';
import '../theme/type_colors.dart';
import 'format.dart';
import 'type_chip.dart';

class PokemonArtwork extends StatelessWidget {
  final int id;
  final double size;
  final int? cacheWidth;

  const PokemonArtwork({
    super.key,
    required this.id,
    required this.size,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/sprites/pokemon/other/official-artwork/$id.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported_outlined,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

/// Grid version of [PokemonTile]: a box colored by the main type.
class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final VoidCallback? onTap;

  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final id = pokemon['pok_id'] as int;
    final types = splitTypes(pokemon['types']);
    final base = typeColor(types.isEmpty ? null : types.first);
    final fg = onTypeColor(base);
    final dark = Color.lerp(base, Colors.black, 0.18)!;
    final edge = Color.lerp(base, Colors.black, 0.4)!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // A deeper shade of the cell's own color outlines it.
          border: Border.all(color: edge, width: 5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, dark],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // The white circle keeps the artwork from blending into a
                // cell of a similar color (green Pokemon on a Grass cell).
                // It takes all the space the text below leaves free.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final d = box.biggest.shortestSide;
                      return Center(
                        child: Container(
                          key: const ValueKey('pokemon-card-halo'),
                          width: d,
                          height: d,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: PokemonArtwork(
                              id: id, size: d * 0.9, cacheWidth: 400),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pokemonName(pokemon['pok_name']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: text.titleLarge
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
                Text(
                  '#${id.toString().padLeft(3, '0')}',
                  textAlign: TextAlign.center,
                  style: text.titleSmall
                      ?.copyWith(color: fg.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 6),
                // Full-size chips; they shrink only if two don't fit.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TypeChips(
                    types: pokemon['types'],
                    alignment: WrapAlignment.center,
                    onBackground: base,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PokemonTile extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final VoidCallback? onTap;

  const PokemonTile({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final id = pokemon['pok_id'] as int;
    final types = splitTypes(pokemon['types']);
    final tint = typeColor(types.isEmpty ? null : types.first);

    return ListTile(
      minTileHeight: 72,
      onTap: onTap,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: PokemonArtwork(id: id, size: 48, cacheWidth: 150),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              pokemonName(pokemon['pok_name']),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text('#${id.toString().padLeft(3, '0')}',
              style: text.labelMedium?.copyWith(color: scheme.outline)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TypeChips(types: pokemon['types'], compact: true),
      ),
      trailing: Icon(Icons.chevron_right, color: scheme.outline),
    );
  }
}
