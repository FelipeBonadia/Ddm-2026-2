import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../features/help/presentation/help_dialog.dart';
import '../providers/app_providers.dart';
import '../services/sound_service.dart';

class AppNavigationBar extends ConsumerStatefulWidget {
  const AppNavigationBar({super.key});

  @override
  ConsumerState<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends ConsumerState<AppNavigationBar> {
  /// Permite devolver o destaque da barra para a página atual depois que o
  /// diálogo de ajuda fecha (a ajuda não é uma página).
  final _barKey = GlobalKey<CurvedNavigationBarState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <_NavigationDestination>[
      _NavigationDestination(
        l10n.navHome,
        Icons.grid_view_rounded,
        AppSection.home,
      ),
      _NavigationDestination(l10n.navGame, Icons.bolt_rounded, AppSection.game),
      _NavigationDestination(
        l10n.navProgress,
        Icons.insights_rounded,
        AppSection.progress,
      ),
      _NavigationDestination(l10n.navHelp, Icons.help_outline_rounded, null),
      _NavigationDestination(
        l10n.navSettings,
        // Ícone de engrenagem: o enunciado pede um ícone de configurações.
        Icons.settings_rounded,
        AppSection.settings,
      ),
    ];

    final location = GoRouterState.of(context).uri.path;
    final currentSection =
        sectionForLocation(location) ?? ref.watch(selectedSectionProvider);
    // Só páginas têm destaque: o item de ajuda (section == null) nunca é o
    // "atual", mesmo que currentSection seja nulo.
    final currentIndex = items.indexWhere(
      (item) => item.section != null && item.section == currentSection,
    );
    final selectedIndex = currentIndex < 0 ? 0 : currentIndex;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: CurvedNavigationBar(
          key: _barKey,
          index: selectedIndex,
          height: 50,
          color: colorScheme.surface,
          buttonBackgroundColor: colorScheme.primary,
          backgroundColor: theme.scaffoldBackgroundColor,
          animationDuration: const Duration(milliseconds: 260),
          items: [
            for (var index = 0; index < items.length; index++)
              _NavigationButton(
                label: items[index].label,
                icon: items[index].icon,
                selected: index == selectedIndex,
              ),
          ],
          onTap: (index) => _selectDestination(items[index], selectedIndex),
        ),
      ),
    );
  }

  Future<void> _selectDestination(
    _NavigationDestination destination,
    int currentIndex,
  ) async {
    final soundEnabled = ref.read(soundEnabledProvider);
    final effect = destination.section == null
        ? AppSoundEffect.help
        : AppSoundEffect.navigation;
    ref.read(appSoundServiceProvider).play(effect, enabled: soundEnabled);

    final section = destination.section;
    if (section == null) {
      await showDialog<void>(
        context: context,
        builder: (context) => const HelpDialog(),
      );
      // A barra moveu o destaque para "Ajuda" ao tocar; volta para a página
      // em que o jogador realmente está.
      if (mounted) _barKey.currentState?.setPage(currentIndex);
      return;
    }
    ref.read(selectedSectionProvider.notifier).select(section);
    context.go(section.route);
  }
}

class _NavigationButton extends StatefulWidget {
  const _NavigationButton({
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = widget.selected;

    return Semantics(
      button: true,
      selected: selected,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            scale: _hovered ? 1.12 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              width: 34,
              height: 34,
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? (_hovered
                          ? colorScheme.onPrimary.withValues(alpha: 0.14)
                          : Colors.transparent)
                    : (_hovered
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : (_hovered
                            ? colorScheme.primary
                            : colorScheme.outlineVariant),
                ),
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: selected
                    ? colorScheme.onPrimary
                    : (_hovered
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination(this.label, this.icon, this.section);

  final String label;
  final IconData icon;
  final AppSection? section;
}