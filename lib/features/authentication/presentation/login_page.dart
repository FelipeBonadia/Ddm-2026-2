import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

/// Web client ID do Google: Firebase Console → Authentication → Sign-in
/// method → Google → "Web SDK configuration" → Web client ID.
/// Também pode ser passado na execução:
/// --dart-define=GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com
const _googleClientId = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: 'REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com',
);

/// Integrantes do grupo (nomes próprios, não são traduzidos).
const _teamMembers = <String>['Rick Robert Tomaz Rezende', 'Felipe Bonadia'];

const _portugueseLocale = Locale('pt', 'BR');
const _englishLocale = Locale('en');

/// Página de login com o visual do app, usando o firebase_ui_auth para a
/// autenticação:
/// - Google: `OAuthProviderButton` + `GoogleProvider`.
/// - E-mail e senha: `SignInScreen` com `EmailAuthProvider` (já traz criar
///   conta, "esqueci a senha" e as mensagens de erro, traduzidas pelo
///   `FirebaseUILocalizations`).
/// Depois de entrar, o `authStateChanges` dispara o redirect do GoRouter.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _googleProvider = GoogleProvider(clientId: _googleClientId);

  void _playSelection() {
    final enabled = ref.read(soundEnabledProvider);
    ref.read(appSoundServiceProvider).playSelection(enabled: enabled);
  }

  void _openEmailSignIn() {
    _playSelection();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) {
          final l10n = AppLocalizations.of(routeContext)!;
          // O SignInScreen não tem barra superior nem botão de voltar, então
          // sobrepomos um botão "voltar" no canto, que fecha esta tela e
          // devolve o usuário à página de login do app.
          return Material(
            color: Colors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SignInScreen(
                  providers: [EmailAuthProvider()],
                  actions: [
                    // Entrou ou criou conta: fecha a tela do firebase_ui_auth;
                    // o GoRouter troca a página de login pela home/última
                    // página.
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }),
                    AuthStateChangeAction<UserCreated>((context, state) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }),
                  ],
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton.filledTonal(
                        tooltip: l10n.loginBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.of(routeContext).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _BrandPanel()),
                            const SizedBox(width: 50),
                            SizedBox(
                              width: 390,
                              child: _buildLoginPanel(context, showTeam: false),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [_buildLoginPanel(context, showTeam: true)],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context, {required bool showTeam}) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(
      interfacePreferencesProvider.select((value) => value.locale),
    );
    final controller = ref.read(interfacePreferencesProvider.notifier);
    // Compara só o idioma: um Locale('pt') salvo não coincide com
    // Locale('pt', 'BR') e deixaria o SegmentedButton sem seleção (erro).
    final selectedLocale = locale.languageCode == 'pt'
        ? _portugueseLocale
        : _englishLocale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.violet,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.functions_rounded,
            color: AppColors.background,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.appLabel,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          l10n.loginTitle,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.loginSubtitle,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        // Google (firebase_ui_oauth_google). O texto do botão vem do
        // FirebaseUILocalizations.
        SizedBox(
          width: double.infinity,
          child: OAuthProviderButton(provider: _googleProvider),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openEmailSignIn,
            icon: const Icon(Icons.mail_outline_rounded),
            label: Text(l10n.loginEmail),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.loginLanguage,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<Locale>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment<Locale>(
              value: _portugueseLocale,
              label: Text(l10n.localePortuguese),
            ),
            ButtonSegment<Locale>(
              value: _englishLocale,
              label: Text(l10n.localeEnglish),
            ),
          ],
          selected: {selectedLocale},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              _playSelection();
              controller.setLocale(selection.first);
            }
          },
        ),
        if (showTeam) ...[const SizedBox(height: 20), const _TeamPanel()],
        // Sem botão "voltar ao início": sem login não há acesso à home (o
        // redirect do GoRouter mandaria de volta para esta página).
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minHeight: 470),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.violet,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.functions_rounded,
                  color: AppColors.background,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Text(
                l10n.appLabel,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.loginBrandTag,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginBrandHeading,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
                ),
                const SizedBox(height: 20),
                const _NumberMotif(),
              ],
            ),
          ),
          const _TeamPanel(),
        ],
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.loginTeamTitle,
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          // Nomes reais do grupo (antes mostrava "Integrante 1 · Integrante 2").
          for (final name in _teamMembers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NumberMotif extends StatelessWidget {
  const _NumberMotif();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 9,
    runSpacing: 9,
    children: [
      _MotifTile('3', AppColors.violet),
      _MotifTile('＋', AppColors.cyan),
      _MotifTile('6', AppColors.success),
      _MotifTile('＝', AppColors.violetBright),
      _MotifTile('24', AppColors.cyan),
    ],
  );
}

class _MotifTile extends StatelessWidget {
  const _MotifTile(this.label, this.tint);

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      label,
      style: TextStyle(color: tint, fontWeight: FontWeight.w700),
    ),
  );
}
