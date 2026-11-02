import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import 'app_loading_indicator.dart';

class SolvedNumbersPanel extends ConsumerWidget {
  const SolvedNumbersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Set<int>>(
      future: ref.watch(solvedNumbersProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppLoadingIndicator();
        }
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        final numbers = snapshot.data ?? <int>{};
        if (numbers.isEmpty) {
          return const Center(child: Text('—'));
        }
        final sorted = numbers.toList()..sort();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in sorted)
              Chip(label: Text('$n')),
          ],
        );
      },
    );
  }
}