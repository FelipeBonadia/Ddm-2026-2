// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Math Puzzle';

  @override
  String get appLabel => 'Math Puzzle';

  @override
  String get loginTitle => 'Your next idea starts here.';

  @override
  String get loginSubtitle => 'Log in to explore mathematical challenges.';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginEmail => 'Continue with email';

  @override
  String get loginUnavailable => 'This option will be available soon.';

  @override
  String get loginLanguage => 'LANGUAGE';

  @override
  String get loginBack => 'Back to start';

  @override
  String get loginTeamTitle => 'TEAM MEMBERS';

  @override
  String get loginTeamNames => 'Team member 1 · Team member 2';

  @override
  String get loginBrandTag => 'NUMBERS. IDEAS. DISCOVERIES.';

  @override
  String get loginBrandHeading => 'A new way\nto think with numbers.';

  @override
  String get homeGreeting => 'Hello, player';

  @override
  String get homeSubtitle => 'Ready for a new challenge?';

  @override
  String get homeAccessAccount => 'Access account';

  @override
  String get homeChallengeTitle => 'REACH THE RESULT';

  @override
  String get homePlayNow => 'Play now';

  @override
  String get homeContinue => 'Continue playing';

  @override
  String get homeYourSpace => 'Your space';

  @override
  String get homeStatsLabel => 'DEMONSTRATION DATA';

  @override
  String get homeStepTitle => 'One idea in three steps';

  @override
  String get homeStepOne => 'Receive four numbers';

  @override
  String get homeStepTwo => 'Combine operations';

  @override
  String get homeStepThree => 'Reach the target';

  @override
  String get homeSequence => 'Sequence';

  @override
  String get homeStreakValue => '3 days';

  @override
  String get homeChallenges => 'Challenges';

  @override
  String get homePrecision => 'Accuracy';

  @override
  String get gameBack => 'Back to start';

  @override
  String get gameTitle => 'Challenge';

  @override
  String get gameTimer => '--:--';

  @override
  String get gameChallengeDay => 'CHALLENGE OF THE DAY';

  @override
  String get gameLevel => 'DIFFICULTY';

  @override
  String get gameEasy => 'ESASY';

  @override
  String get gameIntermediate => 'INTERMEDIATE';

  @override
  String get gameAdvanced => 'ADVANCED';

  @override
  String get gameHard => 'HARD';

  @override
  String get gameResultTarget => 'MAKE BOTH SIDES EQUAL';

  @override
  String get gameRuleHint =>
      'Use each of the four numbers once to form a valid equality.';

  @override
  String get gameLeftSide => 'LEFT SIDE';

  @override
  String get gameRightSide => 'RIGHT SIDE';

  @override
  String get gameNumbers => 'NUMBERS';

  @override
  String get gameOperations => 'OPERATORS';

  @override
  String get gameExpressionLabel => 'YOUR EXPRESSION';

  @override
  String get gameExpressionPlaceholder => 'Build your expression';

  @override
  String get gameBoardEmptyHint => 'Drag or tap to add to the equation';

  @override
  String get gameRemoveTokenHint => 'Tap to remove';

  @override
  String get gameUndo => 'Undo';

  @override
  String get gameEquality => '=';

  @override
  String get gameContinue => 'Next challenge';

  @override
  String get gameFeedbackCorrect => 'Correct equality!';

  @override
  String get gameFeedbackIncorrect => 'The two sides are not equal. Try again.';

  @override
  String get gameFeedbackIncomplete =>
      'Complete both sides and use all four numbers.';

  @override
  String get gameFeedbackMissingEquality =>
      'Insert the equal sign (=) to form the equality.';

  @override
  String get gameFeedbackWrongNumbers =>
      'Use each available number exactly once.';

  @override
  String get gameFeedbackOperationNotAllowed =>
      'That operation is not allowed at this difficulty.';

  @override
  String get gameFeedbackInvalidSyntax =>
      'Check the order of numbers, operators and parentheses.';

  @override
  String get gameFeedbackDivisionByZero => 'Division by zero is not allowed.';

  @override
  String get gameFeedbackDivisionNotExact =>
      'Division must produce an integer result.';

  @override
  String get gameFeedbackInvalid =>
      'This equality is invalid. Check the expression.';

  @override
  String get gameFeedbackDomainError => 'Domain error.';

  @override
  String get gameLatexLabel => 'LATEX PREVIEW';

  @override
  String get gameLatexFallback => 'The expression will be rendered here';

  @override
  String get gameVerify => 'Verify';

  @override
  String get gameClear => 'Clear';

  @override
  String get gameSkip => 'Skip';

  @override
  String gameUnavailable(Object action) {
    return '\$action will be available in a future step.';
  }

  @override
  String get gameVerifyAction => 'Verification';

  @override
  String get gameSkipAction => 'Skip challenge';

  @override
  String get gameAttemptsTooltip => 'Number of attempts';

  @override
  String gameAttemptsBadge(Object count) {
    return '\$count tries';
  }

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSubtitle => 'Track your challenges and results.';

  @override
  String get progressDemoLabel => 'DEMONSTRATION DATA';

  @override
  String get progressResolved => 'Solved challenges';

  @override
  String get progressScore => 'Score';

  @override
  String get progressBestStreak => 'Best streak';

  @override
  String get progressBestStreakValue => '3 days';

  @override
  String get progressCurrentStreak => 'Current streak';

  @override
  String progressStreakDays(Object days) {
    return '\$days days';
  }

  @override
  String get progressDifficultyEasy => 'Easy';

  @override
  String get progressDifficultyIntermediate => 'Intermediate';

  @override
  String get progressDifficultyAdvanced => 'Advanced';

  @override
  String get progressDifficultyHard => 'Hard';

  @override
  String get progressHistoryTitle => 'History';

  @override
  String progressHistoryDemo(Object difficulty) {
    return 'Demo · \$difficulty';
  }

  @override
  String progressHistoryCaption(Object date, Object difficulty) {
    return '\$date · \$difficulty';
  }

  @override
  String get progressEmptyTitle => 'No challenges solved yet';

  @override
  String get progressEmptyHint =>
      'Solve a challenge to see your progress here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Adjust the appearance to your gaming style.';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get settingsDarkTheme => 'Dark theme';

  @override
  String get settingsOn => 'Enabled';

  @override
  String get settingsOff => 'Disabled';

  @override
  String get settingsReading => 'READING';

  @override
  String get settingsFontSize => 'Font size';

  @override
  String get settingsFontFamily => 'Type family';

  @override
  String get settingsAccentColor => 'PRIMARY COLOR';

  @override
  String get settingsSelectAccentColor => 'Select primary color';

  @override
  String get settingsLanguageSection => 'LANGUAGE / IDIOMA';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsSound => 'Sound effects';

  @override
  String get settingsSoundDescription => 'Audio feedback control';

  @override
  String get settingsAudioSection => 'AUDIO';

  @override
  String get settingsSoundEnabled => 'Enabled';

  @override
  String get settingsSoundDisabled => 'Disabled';

  @override
  String get settingsSoundStatus => 'Enabled';

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpMessage =>
      'Use the four numbers from the challenge and combine mathematical operations to reach the indicated result. Arrange your expression before verifying.';

  @override
  String get helpAction => 'Got it';

  @override
  String get navHome => 'Home';

  @override
  String get navGame => 'Game';

  @override
  String get navProgress => 'Progress';

  @override
  String get navHelp => 'Help';

  @override
  String get navSettings => 'Settings';

  @override
  String get navRailTag => 'CHALLENGES, ONE STEP AT A TIME';

  @override
  String get welcomeToApp => 'Welcome to the app';

  @override
  String get localePortuguese => '🇧🇷 Português';

  @override
  String get localeEnglish => '🇺🇸 English';

  @override
  String get systemStatus => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'System';
}
