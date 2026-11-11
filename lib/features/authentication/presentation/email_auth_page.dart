import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_providers.dart';

/// Tamanho mínimo de senha aceito pelo Firebase Authentication.
const _minPasswordLength = 6;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

enum EmailAuthMode { signIn, signUp }

/// Tela de entrar / criar conta com e-mail e senha.
///
/// Melhorias de usabilidade em relação ao formulário padrão do
/// firebase_ui_auth:
/// - a regra da senha (mínimo de 6 caracteres) aparece antes de o usuário
///   errar; no cadastro ela vira um indicador que "acende" ao ser cumprida;
/// - validação campo a campo, com mensagens claras (e-mail inválido, senha
///   curta, senhas diferentes);
/// - botão para mostrar/ocultar a senha e campo de confirmação no cadastro;
/// - botão com indicador de carregamento (evita toques repetidos);
/// - erros do Firebase traduzidos para mensagens amigáveis;
/// - "Esqueci minha senha" com envio do link de redefinição;
/// - após criar a conta: pop-up de sucesso e volta para o login, com o
///   e-mail já preenchido.
class EmailAuthPage extends ConsumerStatefulWidget {
  const EmailAuthPage({super.key, this.initialMode = EmailAuthMode.signIn});

  final EmailAuthMode initialMode;

  @override
  ConsumerState<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends ConsumerState<EmailAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late EmailAuthMode _mode = widget.initialMode;
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _notice;

  bool get _isSignUp => _mode == EmailAuthMode.signUp;

  @override
  void initState() {
    super.initState();
    // Atualiza o indicador "mínimo de 6 caracteres" a cada tecla.
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted && _isSignUp) setState(() {});
  }

  void _playSelection() {
    final enabled = ref.read(soundEnabledProvider);
    ref.read(appSoundServiceProvider).playSelection(enabled: enabled);
  }

  void _setMode(EmailAuthMode mode) {
    if (_loading || mode == _mode) return;
    _playSelection();
    // As senhas não são mantidas ao trocar de aba; o e-mail sim.
    _passwordController.clear();
    _confirmController.clear();
    setState(() {
      _mode = mode;
      _error = null;
      _notice = null;
    });
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final password = value ?? '';
    if (password.isEmpty) return l10n.authPasswordRequired;
    if (password.length < _minPasswordLength) return l10n.authPasswordTooShort;
    return null;
  }

  String? _validateConfirm(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if ((value ?? '').isEmpty) return l10n.authConfirmRequired;
    if (value != _passwordController.text) return l10n.authPasswordsMismatch;
    return null;
  }

  void _focusFirstInvalidField() {
    final l10n = AppLocalizations.of(context)!;
    if (_emailError(l10n, _emailController.text) != null) {
      _emailFocus.requestFocus();
    } else if (_validatePassword(_passwordController.text) != null) {
      _passwordFocus.requestFocus();
    } else if (_isSignUp) {
      _confirmFocus.requestFocus();
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      _focusFirstInvalidField();
      return;
    }

    _playSelection();
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
    });

    if (_isSignUp) {
      await _signUp(email, password);
    } else {
      await _signIn(email, password);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _signIn(String email, String password) async {
    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmail(email: email, password: password);
      TextInput.finishAutofillContext();
      if (!mounted) return;
      // O GoRouter já leva para a home quando o login muda. Aqui só fechamos
      // esta tela, que foi aberta por cima da página de login.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _authErrorMessage(AppLocalizations.of(context)!, error);
      });
    }
  }

  Future<void> _signUp(String email, String password) async {
    // Criar a conta já deixa o usuário logado no Firebase, e o roteador o
    // mandaria direto para a home. Pausamos o redirect para mostrar o aviso
    // de sucesso e voltar para o login.
    authRedirectPaused.value = true;
    var created = false;
    try {
      await ref
          .read(authServiceProvider)
          .createAccount(email: email, password: password);
      created = true;
      TextInput.finishAutofillContext();
      if (mounted) await _showAccountCreatedDialog();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = _authErrorMessage(AppLocalizations.of(context)!, error);
        });
      }
    } finally {
      if (created) {
        // A conta existe, mas o usuário deve entrar pela tela de login.
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {
          // Sem ação: no pior caso o usuário segue logado com a conta nova.
        }
      }
      authRedirectPaused.value = false;
    }

    if (created && mounted) {
      final l10n = AppLocalizations.of(context)!;
      _passwordController.clear();
      _confirmController.clear();
      setState(() {
        _mode = EmailAuthMode.signIn;
        _notice = l10n.authAccountCreatedNotice;
      });
      // Com o e-mail preenchido, falta só digitar a senha.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passwordFocus.requestFocus();
      });
    }
  }

  Future<void> _showAccountCreatedDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 48,
        ),
        title: Text(l10n.authAccountCreatedTitle, textAlign: TextAlign.center),
        content: Text(
          l10n.authAccountCreatedBody,
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.authAccountCreatedAction),
          ),
        ],
      ),
    );
  }

  Future<void> _forgotPassword() async {
    _playSelection();
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _ResetPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.authResetSent)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final passwordLongEnough =
        _passwordController.text.length >= _minPasswordLength;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.authBack,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<EmailAuthMode>(
                        showSelectedIcon: false,
                        expandedInsets: EdgeInsets.zero,
                        segments: [
                          ButtonSegment<EmailAuthMode>(
                            value: EmailAuthMode.signIn,
                            label: Text(l10n.authTabSignIn),
                          ),
                          ButtonSegment<EmailAuthMode>(
                            value: EmailAuthMode.signUp,
                            label: Text(l10n.authTabSignUp),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: _loading
                            ? null
                            : (selection) => _setMode(selection.first),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isSignUp ? l10n.authSignUpTitle : l10n.authSignInTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignUp
                            ? l10n.authSignUpSubtitle
                            : l10n.authSignInSubtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_notice != null) ...[
                        _MessageBanner(message: _notice!, isError: false),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        key: ValueKey('email-${_mode.name}'),
                        controller: _emailController,
                        focusNode: _emailFocus,
                        enabled: !_loading,
                        autofocus: _emailController.text.isEmpty,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => _emailError(l10n, value),
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                        decoration: _fieldDecoration(
                          context,
                          label: l10n.authEmailLabel,
                          hint: l10n.authEmailHint,
                          prefix: const Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: ValueKey('password-${_mode.name}'),
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        enabled: !_loading,
                        obscureText: _obscure,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: _isSignUp
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: [
                          _isSignUp
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validatePassword,
                        onFieldSubmitted: (_) {
                          if (_isSignUp) {
                            _confirmFocus.requestFocus();
                          } else {
                            _submit();
                          }
                        },
                        decoration: _fieldDecoration(
                          context,
                          label: l10n.authPasswordLabel,
                          // No cadastro a regra aparece como indicador logo
                          // abaixo; no login, como texto de apoio.
                          helper: _isSignUp ? null : l10n.authPasswordRule,
                          prefix: const Icon(Icons.lock_outline_rounded),
                          suffix: IconButton(
                            tooltip: _obscure
                                ? l10n.authShowPassword
                                : l10n.authHidePassword,
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      if (_isSignUp) ...[
                        const SizedBox(height: 10),
                        _RuleRow(
                          met: passwordLongEnough,
                          text: l10n.authPasswordRule,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: ValueKey('confirm-${_mode.name}'),
                          controller: _confirmController,
                          focusNode: _confirmFocus,
                          enabled: !_loading,
                          obscureText: _obscure,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateConfirm,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: _fieldDecoration(
                            context,
                            label: l10n.authConfirmPasswordLabel,
                            prefix: const Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                      ] else
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading ? null : _forgotPassword,
                            child: Text(l10n.authForgotPassword),
                          ),
                        ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _MessageBanner(message: _error!, isError: true),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isSignUp
                                    ? l10n.authSignUpButton
                                    : l10n.authSignInButton,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo "Esqueci minha senha": pede o e-mail e envia o link de
/// redefinição. Fecha com `true` quando o envio deu certo.
class _ResetPasswordDialog extends ConsumerStatefulWidget {
  const _ResetPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_controller.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _authErrorMessage(AppLocalizations.of(context)!, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      scrollable: true,
      title: Text(l10n.authResetTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.authResetBody, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              enabled: !_loading,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: (value) => _emailError(l10n, value),
              onFieldSubmitted: (_) => _send(),
              decoration: _fieldDecoration(
                context,
                label: l10n.authEmailLabel,
                hint: l10n.authEmailHint,
                prefix: const Icon(Icons.mail_outline_rounded),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: _error!, isError: true),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.authCancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _send,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(l10n.authResetSend),
        ),
      ],
    );
  }
}

/// Item de regra da senha: cinza enquanto não é cumprida, verde com ✓ depois.
class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final okColor = isDark ? AppColors.success : const Color(0xFF1B7F4B);
    final color = met
        ? okColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 13)),
        ),
      ],
    );
  }
}

/// Faixa de aviso dentro do formulário (erro em vermelho, confirmação em
/// verde). `liveRegion` faz leitores de tela anunciarem a mensagem.
class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isError
        ? theme.colorScheme.error
        : (isDark ? AppColors.success : const Color(0xFF1B7F4B));

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decoração dos campos, com borda destacada no foco e em vermelho no erro
/// (o tema do app só define a borda padrão).
InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  String? helper,
  Widget? prefix,
  Widget? suffix,
}) {
  final scheme = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: width),
  );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    helperMaxLines: 2,
    errorMaxLines: 3,
    prefixIcon: prefix,
    suffixIcon: suffix,
    focusedBorder: border(scheme.primary, 2),
    errorBorder: border(scheme.error, 1),
    focusedErrorBorder: border(scheme.error, 2),
  );
}

String? _emailError(AppLocalizations l10n, String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return l10n.authEmailRequired;
  if (!_emailPattern.hasMatch(email)) return l10n.authEmailInvalid;
  return null;
}

/// Traduz os erros do Firebase para mensagens que o usuário entende.
String _authErrorMessage(AppLocalizations l10n, Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
        return l10n.authErrorInvalidCredentials;
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'invalid-email':
        return l10n.authEmailInvalid;
      case 'email-already-in-use':
        return l10n.authErrorEmailInUse;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'network-request-failed':
        return l10n.authErrorNetwork;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
    }
  }
  return l10n.authErrorGeneric;
}
