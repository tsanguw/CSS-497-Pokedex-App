import 'package:flutter/material.dart';

/// Generation (1-9) and learn-method filter chips. Tapping a selected chip
/// clears it (reports null).
class MoveFilters extends StatelessWidget {
  static const methods = {
    1: 'Level up',
    2: 'Egg',
    3: 'Tutor',
    4: 'TM/HM',
  };

  final int? generation;
  final int? method;
  final ValueChanged<int?> onGeneration;
  final ValueChanged<int?> onMethod;

  const MoveFilters({
    super.key,
    required this.generation,
    required this.method,
    required this.onGeneration,
    required this.onMethod,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Generation', style: text.labelLarge?.copyWith(color: muted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (var g = 1; g <= 9; g++)
              FilterChip(
                label: Text('$g'),
                selected: generation == g,
                onSelected: (on) => onGeneration(on ? g : null),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Learned by', style: text.labelLarge?.copyWith(color: muted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final m in methods.entries)
              FilterChip(
                label: Text(m.value),
                selected: method == m.key,
                onSelected: (on) => onMethod(on ? m.key : null),
              ),
          ],
        ),
      ],
    );
  }
}
