import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/interface_preferences.dart';
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

  // Faixa do tamanho da fonte: de 50% a 150%, em 20 passos de 5%.
  static const _minScale = 0.5;
  static const _maxScale = 1.5;
  static const _scaleDivisions = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(interfacePreferencesProvider);
    final controller = ref.read(interfacePreferencesProvider.notifier);
    final soundService = ref.read(appSoundServiceProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);

    const defaults = InterfacePreferences();
    final scaleIsDefault =
        (preferences.textScale * 100).round() ==
        (defaults.textScale * 100).round();

    void playToggle({bool? enabled}) =>
        soundService.playToggle(enabled: enabled ?? soundEnabled);
    void playSelection() => soundService.playSelection(enabled: soundEnabled);
    void playControl() => soundService.playControl(enabled: soundEnabled);

    final swatches = [
      (_seedColors[0], l10n.settingsColorViolet),
      (_seedColors[1], l10n.settingsColorCyan),
      (_seedColors[2], l10n.settingsColorGreen),
    ];

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
                Text(l10n.settingsFontSize),
                // Sem número: um "A" pequeno e um grande nas pontas indicam o
                // sentido do slider, que se arrasta com o dedo.
                Row(
                  children: [
                    const _ScaleLetter(size: 13),
                    Expanded(
                      child: Slider(
                        min: _minScale,
                        max: _maxScale,
                        divisions: _scaleDivisions,
                        value: preferences.textScale
                            .clamp(_minScale, _maxScale)
                            .toDouble(),
                        onChanged: (value) => controller.setTextScale(
                          (value * 100).round() / 100,
                        ),
                        onChangeEnd: (_) => playControl(),
                      ),
                    ),
                    const _ScaleLetter(size: 26),
                  ],
                ),
                if (!scaleIsDefault)
                  TextButton.icon(
                    onPressed: () {
                      playControl();
                      controller.setTextScale(defaults.textScale);
                    },
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(l10n.settingsFontReset),
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
                  expandedInsets: EdgeInsets.zero,
                  segments: [
                    ButtonSegment<Locale>(
                      value: const Locale('pt', 'BR'),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.localePortuguese,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                    ButtonSegment<Locale>(
                      value: const Locale('en'),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.localeEnglish,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
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
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (color, name) in swatches)
                  _AccentColorOption(
                    color: color,
                    name: name,
                    selected: preferences.seedColor == color,
                    onTap: () {
                      playSelection();
                      controller.setSeedColor(color);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _ResetAppearanceSection(),
        ],
      ),
    );
  }
}

/// Cor de destaque com nome visível, área de toque de pelo menos 48 px e
/// semântica de "botão selecionado" para leitores de tela.
class _AccentColorOption extends StatelessWidget {
  const _AccentColorOption({
    required this.color,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 72, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? onSurface : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppColors.background,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          // Título de seção maior (12 px, antes 10 px) e marcado como
          // cabeçalho para leitores de tela.
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.cyan,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}

/// "A" decorativo nas pontas do slider de tamanho da fonte. Não escala com a
/// configuração, para ficar sempre do mesmo tamanho.
class _ScaleLetter extends StatelessWidget {
  const _ScaleLetter({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Text(
      'A',
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w600),
    ),
  );
}

/// Botão "Restaurar aparência padrão" + aviso com "Desfazer".
///
/// O aviso aparece logo abaixo do botão, fica visível por 8 s e some com um
/// efeito de transparência de 1 s (cerca de 9 s no total).
class _ResetAppearanceSection extends ConsumerStatefulWidget {
  const _ResetAppearanceSection();

  @override
  ConsumerState<_ResetAppearanceSection> createState() =>
      _ResetAppearanceSectionState();
}

class _ResetAppearanceSectionState
    extends ConsumerState<_ResetAppearanceSection> {
  static const _visibleFor = Duration(seconds: 8);
  static const _fadeDuration = Duration(seconds: 1);

  Timer? _timer;
  InterfacePreferences? _previous;
  bool _showNotice = false;
  bool _opaque = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _apply(InterfacePreferences values) async {
    final controller = ref.read(interfacePreferencesProvider.notifier);
    await controller.setThemeMode(values.themeMode);
    await controller.setTextScale(values.textScale);
    await controller.setFontFamily(values.fontFamily);
    await controller.setSeedColor(values.seedColor);
  }

  Future<void> _reset() async {
    final previous = ref.read(interfacePreferencesProvider);
    ref
        .read(appSoundServiceProvider)
        .playControl(enabled: ref.read(soundEnabledProvider));
    _timer?.cancel();
    await _apply(const InterfacePreferences());
    if (!mounted) return;
    setState(() {
      _previous = previous;
      _showNotice = true;
      _opaque = true;
    });
    _timer = Timer(_visibleFor, _fadeOut);
    // Rola até o aviso (que fica no fim da página) para ele não ficar
    // cortado. Roda depois do quadro em que o aviso já foi medido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void _fadeOut() {
    if (mounted) setState(() => _opaque = false);
  }

  void _onFadeEnd() {
    if (!_opaque && mounted) {
      setState(() {
        _showNotice = false;
        _previous = null;
      });
    }
  }

  Future<void> _undo() async {
    final previous = _previous;
    if (previous == null) return;
    _timer?.cancel();
    setState(() => _opaque = false);
    await _apply(previous);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final preferences = ref.watch(interfacePreferencesProvider);
    const defaults = InterfacePreferences();
    final isDefault =
        preferences.themeMode == defaults.themeMode &&
        (preferences.textScale * 100).round() ==
            (defaults.textScale * 100).round() &&
        preferences.fontFamily == defaults.fontFamily &&
        preferences.seedColor == defaults.seedColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Desabilitado quando a aparência já está no padrão.
        OutlinedButton.icon(
          onPressed: isDefault ? null : _reset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(l10n.settingsResetAppearance),
        ),
        if (_showNotice)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AnimatedOpacity(
              opacity: _opaque ? 1 : 0,
              duration: _fadeDuration,
              curve: Curves.easeOut,
              onEnd: _onFadeEnd,
              child: Semantics(
                liveRegion: true,
                child: Material(
                  color: scheme.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.settingsResetDone,
                            style: TextStyle(color: scheme.onInverseSurface),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.inversePrimary,
                          ),
                          onPressed: _undo,
                          child: Text(l10n.settingsUndo),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
