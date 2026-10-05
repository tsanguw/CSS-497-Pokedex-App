import 'package:flutter/material.dart';
import '../widgets/state_views.dart';

class DamageCalculatorPage extends StatelessWidget {
  const DamageCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageView(
      icon: Icons.calculate_outlined,
      message: 'The damage calculator is coming soon.',
    );
  }
}
