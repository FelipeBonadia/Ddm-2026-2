import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../shared/presentation/feature_frame.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _seedColors = [
    Color(0xFF9B7BFF),
    Color(0xFF37BFCF),
    Color(0xFF42A97B),
  ];
  static const _fontFamilies = ['Space Grotesk', 'DM Sans', 'Lato'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(interfacePreferencesProvider);
    final controller = ref.read(interfacePreferencesProvider.notifier);
    final soundService = ref.read(appSoundServiceProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);

    void playToggle({bool? enabled}) =>
        soundService.playToggle(enabled: enabled ?? soundEnabled);
    void playSelection() => soundService.playSelection(enabled: soundEnabled);
    void playControl() => soundService.playControl(enabled: soundEnabled);

    return AppFeatureFrame(
      title: l10n.settingsTitle,
      subtitle: l10n.settingsSubtitle,
      child: Column(
        children: [
          _SettingsGroup(
            title: l10n.settingsAppearance,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsDarkTheme),
              subtitle: Text(
                preferences.themeMode == ThemeMode.dark
                    ? l10n.settingsOn
                    : l10n.settingsOff,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              value: preferences.themeMode == ThemeMode.dark,
              onChanged: (enabled) {
                playToggle();
                controller.setThemeMode(
                  enabled ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _SettingsGroup(
            title: l10n.settingsReading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.settingsFontSize)),
                    Text(
                      '${(preferences.textScale * 100).round()}%',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Slider(
                  min: 0.85,
                  max: 1.15,
                  divisions: 6,
                  value: preferences.textScale,
                  label: '${(preferences.textScale * 100).round()}%',
                  onChanged: controller.setTextScale,
                  onChangeEnd: (_) => playControl(),
                ),
                const SizedBox(height: 6),
                Text(l10n.settingsFontFamily),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: preferences.fontFamily,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    for (final family in _fontFamilies)
                      DropdownMenuItem(value: family, child: Text(family)),
                  ],
                  onChanged: (family) {
                    if (family != null) {
                      playSelection();
                      controller.setFontFamily(family);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsGroup(
            title: l10n.settingsLanguageSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguageLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SegmentedButton<Locale>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<Locale>(
                      value: Locale('pt', 'BR'),
                      label: Text('🇧🇷 Português'),
                    ),
                    ButtonSegment<Locale>(
                      value: Locale('en'),
                      label: Text('🇺🇸 English'),
                    ),
                  ],
                  selected: {preferences.locale},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      playSelection();
                      controller.setLocale(selection.first);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsGroup(
            title: l10n.settingsAudioSection,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsSound),
              subtitle: Text(
                preferences.soundEnabled
                    ? l10n.settingsSoundEnabled
                    : l10n.settingsSoundDisabled,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              value: preferences.soundEnabled,
              onChanged: (enabled) {
                soundService.setSoundEnabled(enabled);
                playToggle(enabled: enabled);
                controller.setSoundEnabled(enabled);
              },
            ),
          ),
          const SizedBox(height: 14),
          _SettingsGroup(
            title: l10n.settingsAccentColor,
            child: Wrap(
              spacing: 14,
              children: [
                for (final color in _seedColors)
                  Tooltip(
                    message: l10n.settingsSelectAccentColor,
                    child: InkWell(
                      onTap: () {
                        playSelection();
                        controller.setSeedColor(color);
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: preferences.seedColor == color
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: preferences.seedColor == color
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.background,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}
