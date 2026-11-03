import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Math Puzzle'**
  String get appName;

  /// No description provided for @appLabel.
  ///
  /// In pt, this message translates to:
  /// **'Math Puzzle'**
  String get appLabel;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua próxima ideia começa aqui.'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para explorar desafios matemáticos.'**
  String get loginSubtitle;

  /// No description provided for @loginGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com o Google'**
  String get loginGoogle;

  /// No description provided for @loginEmail.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com e-mail'**
  String get loginEmail;

  /// No description provided for @loginUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Esta opção estará disponível em breve.'**
  String get loginUnavailable;

  /// No description provided for @loginLanguage.
  ///
  /// In pt, this message translates to:
  /// **'IDIOMA'**
  String get loginLanguage;

  /// No description provided for @loginBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get loginBack;

  /// No description provided for @loginTeamTitle.
  ///
  /// In pt, this message translates to:
  /// **'INTEGRANTES'**
  String get loginTeamTitle;

  /// No description provided for @loginTeamNames.
  ///
  /// In pt, this message translates to:
  /// **'Integrante 1 · Integrante 2'**
  String get loginTeamNames;

  /// No description provided for @loginBrandTag.
  ///
  /// In pt, this message translates to:
  /// **'NÚMEROS. IDEIAS. DESCOBERTAS.'**
  String get loginBrandTag;

  /// No description provided for @loginBrandHeading.
  ///
  /// In pt, this message translates to:
  /// **'Uma nova forma\nde pensar com números.'**
  String get loginBrandHeading;

  /// No description provided for @homeGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, jogador'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pronto para um novo desafio?'**
  String get homeSubtitle;

  /// No description provided for @homeAccessAccount.
  ///
  /// In pt, this message translates to:
  /// **'Acessar conta'**
  String get homeAccessAccount;

  /// No description provided for @homeChallengeTitle.
  ///
  /// In pt, this message translates to:
  /// **'SEU DESAFIO ATUAL'**
  String get homeChallengeTitle;

  /// No description provided for @homePlayNow.
  ///
  /// In pt, this message translates to:
  /// **'Jogar agora'**
  String get homePlayNow;

  /// No description provided for @homeContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get homeContinue;

  /// No description provided for @homeYourSpace.
  ///
  /// In pt, this message translates to:
  /// **'Seu espaço'**
  String get homeYourSpace;

  /// No description provided for @homeStatsLabel.
  ///
  /// In pt, this message translates to:
  /// **'SUAS ESTATÍSTICAS'**
  String get homeStatsLabel;

  /// No description provided for @homeStepTitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma ideia em três passos'**
  String get homeStepTitle;

  /// No description provided for @homeStepOne.
  ///
  /// In pt, this message translates to:
  /// **'Receba quatro números'**
  String get homeStepOne;

  /// No description provided for @homeStepTwo.
  ///
  /// In pt, this message translates to:
  /// **'Combine operações'**
  String get homeStepTwo;

  /// No description provided for @homeStepThree.
  ///
  /// In pt, this message translates to:
  /// **'Iguale os dois lados'**
  String get homeStepThree;

  /// No description provided for @homeSequence.
  ///
  /// In pt, this message translates to:
  /// **'Sequência'**
  String get homeSequence;

  /// No description provided for @homeChallenges.
  ///
  /// In pt, this message translates to:
  /// **'Desafios'**
  String get homeChallenges;

  /// No description provided for @homePrecision.
  ///
  /// In pt, this message translates to:
  /// **'Precisão'**
  String get homePrecision;

  /// No description provided for @gameBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get gameBack;

  /// No description provided for @gameTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafio'**
  String get gameTitle;

  /// No description provided for @gameTimer.
  ///
  /// In pt, this message translates to:
  /// **'--:--'**
  String get gameTimer;

  /// No description provided for @gameChallengeDay.
  ///
  /// In pt, this message translates to:
  /// **'DESAFIO DO DIA'**
  String get gameChallengeDay;

  /// No description provided for @gameLevel.
  ///
  /// In pt, this message translates to:
  /// **'DIFICULDADE'**
  String get gameLevel;

  /// No description provided for @gameEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get gameEasy;

  /// No description provided for @gameIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get gameIntermediate;

  /// No description provided for @gameAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get gameAdvanced;

  /// No description provided for @gameHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get gameHard;

  /// No description provided for @gameResultTarget.
  ///
  /// In pt, this message translates to:
  /// **'IGUALE OS DOIS LADOS'**
  String get gameResultTarget;

  /// No description provided for @gameRuleHint.
  ///
  /// In pt, this message translates to:
  /// **'Use cada um dos quatro números uma vez para formar uma igualdade válida.'**
  String get gameRuleHint;

  /// No description provided for @gameLeftSide.
  ///
  /// In pt, this message translates to:
  /// **'LADO ESQUERDO'**
  String get gameLeftSide;

  /// No description provided for @gameRightSide.
  ///
  /// In pt, this message translates to:
  /// **'LADO DIREITO'**
  String get gameRightSide;

  /// No description provided for @gameNumbers.
  ///
  /// In pt, this message translates to:
  /// **'NÚMEROS'**
  String get gameNumbers;

  /// No description provided for @gameOperations.
  ///
  /// In pt, this message translates to:
  /// **'OPERADORES'**
  String get gameOperations;

  /// No description provided for @gameExpressionLabel.
  ///
  /// In pt, this message translates to:
  /// **'SUA EXPRESSÃO'**
  String get gameExpressionLabel;

  /// No description provided for @gameExpressionPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Monte sua expressão'**
  String get gameExpressionPlaceholder;

  /// No description provided for @gameBoardEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste ou toque para adicionar à equação'**
  String get gameBoardEmptyHint;

  /// No description provided for @gameRemoveTokenHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para remover'**
  String get gameRemoveTokenHint;

  /// No description provided for @gameUndo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get gameUndo;

  /// No description provided for @gameEquality.
  ///
  /// In pt, this message translates to:
  /// **'='**
  String get gameEquality;

  /// No description provided for @gameContinue.
  ///
  /// In pt, this message translates to:
  /// **'Próximo desafio'**
  String get gameContinue;

  /// No description provided for @gameFeedbackCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Igualdade correta!'**
  String get gameFeedbackCorrect;

  /// No description provided for @gameFeedbackIncorrect.
  ///
  /// In pt, this message translates to:
  /// **'Os dois lados não são iguais. Tente novamente.'**
  String get gameFeedbackIncorrect;

  /// No description provided for @gameFeedbackIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Complete os dois lados e use os quatro números.'**
  String get gameFeedbackIncomplete;

  /// No description provided for @gameFeedbackMissingEquality.
  ///
  /// In pt, this message translates to:
  /// **'Insira o sinal de igual (=) para formar a igualdade.'**
  String get gameFeedbackMissingEquality;

  /// No description provided for @gameFeedbackWrongNumbers.
  ///
  /// In pt, this message translates to:
  /// **'Use cada número disponível exatamente uma vez.'**
  String get gameFeedbackWrongNumbers;

  /// No description provided for @gameFeedbackOperationNotAllowed.
  ///
  /// In pt, this message translates to:
  /// **'Essa operação não é permitida nesta dificuldade.'**
  String get gameFeedbackOperationNotAllowed;

  /// No description provided for @gameFeedbackInvalidSyntax.
  ///
  /// In pt, this message translates to:
  /// **'Confira a ordem dos números, operadores e parênteses.'**
  String get gameFeedbackInvalidSyntax;

  /// No description provided for @gameFeedbackDivisionByZero.
  ///
  /// In pt, this message translates to:
  /// **'Não é permitido dividir por zero.'**
  String get gameFeedbackDivisionByZero;

  /// No description provided for @gameFeedbackDivisionNotExact.
  ///
  /// In pt, this message translates to:
  /// **'A divisão deve resultar em um número inteiro.'**
  String get gameFeedbackDivisionNotExact;

  /// No description provided for @gameFeedbackInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Esta igualdade é inválida. Confira a expressão.'**
  String get gameFeedbackInvalid;

  /// No description provided for @gameFeedbackDomainError.
  ///
  /// In pt, this message translates to:
  /// **'Operação inválida: raiz não exata, fatorial fora do limite ou resultado grande demais.'**
  String get gameFeedbackDomainError;

  /// No description provided for @gameLatexLabel.
  ///
  /// In pt, this message translates to:
  /// **'PRÉVIA EM LATEX'**
  String get gameLatexLabel;

  /// No description provided for @gameLatexFallback.
  ///
  /// In pt, this message translates to:
  /// **'A expressão será renderizada aqui'**
  String get gameLatexFallback;

  /// No description provided for @gameVerify.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get gameVerify;

  /// No description provided for @gameClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get gameClear;

  /// No description provided for @gameSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get gameSkip;

  /// No description provided for @gameUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'{action} estará disponível em uma etapa futura.'**
  String gameUnavailable(String action);

  /// No description provided for @gameVerifyAction.
  ///
  /// In pt, this message translates to:
  /// **'Verificação'**
  String get gameVerifyAction;

  /// No description provided for @gameSkipAction.
  ///
  /// In pt, this message translates to:
  /// **'Pular desafio'**
  String get gameSkipAction;

  /// No description provided for @gameAttemptsTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Número de tentativas'**
  String get gameAttemptsTooltip;

  /// No description provided for @gameAttemptsBadge.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 tentativas} =1{1 tentativa} other{{count} tentativas}}'**
  String gameAttemptsBadge(int count);

  /// No description provided for @progressTitle.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get progressTitle;

  /// No description provided for @progressSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe seus desafios e resultados.'**
  String get progressSubtitle;

  /// No description provided for @progressDemoLabel.
  ///
  /// In pt, this message translates to:
  /// **'SEU PROGRESSO'**
  String get progressDemoLabel;

  /// No description provided for @progressResolved.
  ///
  /// In pt, this message translates to:
  /// **'Desafios resolvidos'**
  String get progressResolved;

  /// No description provided for @progressScore.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação'**
  String get progressScore;

  /// No description provided for @progressBestStreak.
  ///
  /// In pt, this message translates to:
  /// **'Melhor sequência'**
  String get progressBestStreak;

  /// No description provided for @progressCurrentStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sequência atual'**
  String get progressCurrentStreak;

  /// No description provided for @progressStreakDays.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =0{0 dias} =1{1 dia} other{{days} dias}}'**
  String progressStreakDays(int days);

  /// No description provided for @progressDifficultyEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get progressDifficultyEasy;

  /// No description provided for @progressDifficultyIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get progressDifficultyIntermediate;

  /// No description provided for @progressDifficultyAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get progressDifficultyAdvanced;

  /// No description provided for @progressDifficultyHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get progressDifficultyHard;

  /// No description provided for @progressHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get progressHistoryTitle;

  /// No description provided for @progressHistoryCaption.
  ///
  /// In pt, this message translates to:
  /// **'{date} · {difficulty}'**
  String progressHistoryCaption(String date, String difficulty);

  /// No description provided for @progressEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum desafio resolvido ainda'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Resolva um desafio para ver seu progresso aqui.'**
  String get progressEmptyHint;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste a aparência ao seu estilo de jogo.'**
  String get settingsSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'APARÊNCIA'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema escuro'**
  String get settingsDarkTheme;

  /// No description provided for @settingsOn.
  ///
  /// In pt, this message translates to:
  /// **'Ativado'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In pt, this message translates to:
  /// **'Desativado'**
  String get settingsOff;

  /// No description provided for @settingsReading.
  ///
  /// In pt, this message translates to:
  /// **'LEITURA'**
  String get settingsReading;

  /// No description provided for @settingsFontSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da fonte'**
  String get settingsFontSize;

  /// No description provided for @settingsFontFamily.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de fonte'**
  String get settingsFontFamily;

  /// No description provided for @settingsAccentColor.
  ///
  /// In pt, this message translates to:
  /// **'COR PRINCIPAL'**
  String get settingsAccentColor;

  /// No description provided for @settingsSelectAccentColor.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a cor principal'**
  String get settingsSelectAccentColor;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In pt, this message translates to:
  /// **'LANGUAGE / IDIOMA'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsSound.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos sonoros'**
  String get settingsSound;

  /// No description provided for @settingsSoundDescription.
  ///
  /// In pt, this message translates to:
  /// **'Controle do retorno sonoro'**
  String get settingsSoundDescription;

  /// No description provided for @settingsAudioSection.
  ///
  /// In pt, this message translates to:
  /// **'ÁUDIO'**
  String get settingsAudioSection;

  /// No description provided for @settingsSoundEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Ativado'**
  String get settingsSoundEnabled;

  /// No description provided for @settingsSoundDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Desativado'**
  String get settingsSoundDisabled;

  /// No description provided for @settingsSoundStatus.
  ///
  /// In pt, this message translates to:
  /// **'Ativado'**
  String get settingsSoundStatus;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como jogar'**
  String get helpTitle;

  /// No description provided for @helpMessage.
  ///
  /// In pt, this message translates to:
  /// **'Use cada um dos quatro números uma vez e monte uma igualdade. O sinal = já está no tabuleiro.\n\nOperadores por dificuldade:\n• Fácil: + − × ÷, parênteses, √, ∛, !, **, |x|, ⌊x⌋ e ⌈x⌉. É o único nível que permite divisão não inteira (5/2).\n• Intermediário: o mesmo, sem base e teto.\n• Avançado: + − × ÷, parênteses, √, ! e |x|.\n• Difícil: + − × ÷, parênteses e |x|.\n\nAs funções recebem um grupo, √ (8 + 1), ou um único número, √ 9. Um sinal de menos antes de um grupo o inverte: −(2 − 5) = 3.\n\nToque em uma peça do tabuleiro para removê-la e use Pular se um desafio estiver difícil demais.'**
  String get helpMessage;

  /// No description provided for @helpAction.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get helpAction;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navGame.
  ///
  /// In pt, this message translates to:
  /// **'Jogo'**
  String get navGame;

  /// No description provided for @navProgress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get navProgress;

  /// No description provided for @navHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get navHelp;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navSettings;

  /// No description provided for @navRailTag.
  ///
  /// In pt, this message translates to:
  /// **'DESAFIOS, UM PASSO DE CADA VEZ'**
  String get navRailTag;

  /// No description provided for @welcomeToApp.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao app'**
  String get welcomeToApp;

  /// No description provided for @localePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'🇧🇷 Português'**
  String get localePortuguese;

  /// No description provided for @localeEnglish.
  ///
  /// In pt, this message translates to:
  /// **'🇺🇸 English'**
  String get localeEnglish;

  /// No description provided for @systemStatus.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get systemStatus;

  /// No description provided for @themeModeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeModeSystem;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
