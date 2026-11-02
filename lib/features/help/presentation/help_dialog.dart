import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class HelpDialog extends ConsumerWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      icon: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.cyan),
      title: Text(l10n.helpTitle),
      content: Text(l10n.helpMessage, style: const TextStyle(height: 1.5)),
      actions: [
        FilledButton(
          onPressed: () {
            final enabled = ref.read(soundEnabledProvider);
            ref.read(appSoundServiceProvider).playHelp(enabled: enabled);
            Navigator.of(context).pop();
          },
          child: Text(l10n.helpAction),
        ),
      ],
    );
  }
}
