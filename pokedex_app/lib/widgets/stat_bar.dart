import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value;

  const StatBar({super.key, required this.label, required this.value});

  Color _color() {
    if (value < 50) return const Color(0xFFE57373);
    if (value < 80) return const Color(0xFFFFB74D);
    if (value < 110) return const Color(0xFF81C784);
    return const Color(0xFF4DB6AC);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label,
                style:
                    text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          SizedBox(
            width: 34,
            child: Text('$value',
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / 255).clamp(0.0, 1.0),
                minHeight: 8,
                color: _color(),
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
