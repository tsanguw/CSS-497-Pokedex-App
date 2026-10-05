import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class MessageView extends StatelessWidget {
  final IconData icon;
  final String message;

  const MessageView({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView(this.message, {super.key});

  @override
  Widget build(BuildContext context) =>
      MessageView(icon: Icons.search_off, message: message);
}

class ErrorView extends StatelessWidget {
  final Object? error;
  const ErrorView(this.error, {super.key});

  @override
  Widget build(BuildContext context) => const MessageView(
        icon: Icons.error_outline,
        message: 'Something went wrong loading this. Try again.',
      );
}
