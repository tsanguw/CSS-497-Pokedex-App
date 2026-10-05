import 'package:flutter/material.dart';

/// Small labelled value card (Height, Power, PP, ...).
class FactTile extends StatelessWidget {
  final String label;
  final String value;

  const FactTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: text.titleMedium),
          ],
        ),
      ),
    );
  }
}
