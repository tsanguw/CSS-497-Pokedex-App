import 'package:flutter/material.dart';
import '../theme/type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final String? suffix;
  final bool compact;

  const TypeChip({
    super.key,
    required this.type,
    this.suffix,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = typeColor(type);
    final fg = onTypeColor(bg);
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

  const TypeChips({
    super.key,
    required this.types,
    this.compact = false,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: alignment,
      children: [
        for (final t in splitTypes(types)) TypeChip(type: t, compact: compact),
      ],
    );
  }
}
