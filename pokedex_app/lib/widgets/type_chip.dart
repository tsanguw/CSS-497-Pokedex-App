import 'package:flutter/material.dart';
import '../theme/type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final String? suffix;
  final bool compact;

  /// When set, the chip is drawn as a translucent pill that stays readable on
  /// this background (used on the type-colored Pokemon cards).
  final Color? onBackground;

  const TypeChip({
    super.key,
    required this.type,
    this.suffix,
    this.compact = false,
    this.onBackground,
  });

  @override
  Widget build(BuildContext context) {
    final onBg = onBackground;
    final fg = onBg == null ? onTypeColor(typeColor(type)) : onTypeColor(onBg);
    final bg = onBg == null
        ? typeColor(type)
        : fg.withValues(alpha: 0.18);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        suffix == null ? capitalize(type) : '${capitalize(type)} $suffix',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// A wrapped row of chips for a comma-joined `types` string.
class TypeChips extends StatelessWidget {
  final Object? types;
  final bool compact;
  final WrapAlignment alignment;
  final Color? onBackground;

  const TypeChips({
    super.key,
    required this.types,
    this.compact = false,
    this.alignment = WrapAlignment.start,
    this.onBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: alignment,
      children: [
        for (final t in splitTypes(types))
          TypeChip(type: t, compact: compact, onBackground: onBackground),
      ],
    );
  }
}
