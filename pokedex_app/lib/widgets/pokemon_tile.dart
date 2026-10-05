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
