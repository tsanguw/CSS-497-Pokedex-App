import 'package:flutter/material.dart';
import '../theme/type_colors.dart';
import 'format.dart';
import 'type_chip.dart';

/// One move row: name, damage class and stats, with the move's element type
/// as a chip. Accepts rows from `getPokemonMoveset` / `getAllMoves`.
class MoveTile extends StatelessWidget {
  final Map<String, dynamic> move;
  final bool showLevel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const MoveTile({
    super.key,
    required this.move,
    this.showLevel = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final level = move['level_learned'];
    // getPokemonMoveset exposes move_type_name; getAllMoves exposes type_name.
    final moveType = move['move_type_name'] ?? move['type_name'];
    final damageClass = move['move_type'];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (showLevel)
              SizedBox(
                width: 44,
                child: Text(
                  level == null || level == 0 ? '—' : 'Lv $level',
                  style: text.labelMedium?.copyWith(color: scheme.outline),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prettyName(move['move_name']), style: text.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${damageClass == null ? '' : '${capitalize('$damageClass')} · '}'
                    'Power ${fmtNum(move['move_power'])} · '
                    'Acc ${fmtNum(move['move_accuracy'])} · '
                    'PP ${fmtNum(move['move_pp'])}',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (moveType != null && '$moveType'.isNotEmpty)
              TypeChip(type: '$moveType', compact: true),
          ],
        ),
      ),
    );
  }
}
