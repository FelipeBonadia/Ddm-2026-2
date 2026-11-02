import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class AppFeatureFrame extends StatelessWidget {
  const AppFeatureFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.contentMaxWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    ),
  );
}
