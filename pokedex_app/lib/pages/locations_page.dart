import 'package:flutter/material.dart';
import '../widgets/state_views.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageView(
      icon: Icons.map_outlined,
      message: 'Locations are coming soon.',
    );
  }
}
