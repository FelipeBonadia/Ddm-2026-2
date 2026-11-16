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
  String get homeChallengeTitle => 'YOUR CURRENT CHALLENGE';

  @override
  String get homePlayNow => 'Play now';

  @override
  String get homeContinue => 'Continue';

  @override
  String get homeYourSpace => 'Your space';

  @override
  String get homeStatsLabel => 'YOUR STATS';

  @override
  String get homeStepTitle => 'One idea in three steps';

  @override
  String get homeStepOne => 'Receive four numbers';

  @override
  String get homeStepTwo => 'Combine operations';

  @override
  String get homeStepThree => 'Make both sides equal';

  @override
  String get homeSequence => 'Streak';

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
  String get gameEasy => 'Easy';

  @override
  String get gameIntermediate => 'Intermediate';

  @override
  String get gameAdvanced => 'Advanced';

  @override
  String get gameHard => 'Hard';

  @override
  String get gameResultTarget => 'MAKE BOTH SIDES EQUAL';

  @override
  String get gameRuleHint =>
      'Use each of the four numbers once to form a valid equality.';

  @override
  String get gameDragHint => 'Drag the numbers and operators to play.';

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
  String get gameFeedbackDomainError =>
      'Invalid operation: inexact root, factorial out of range, or result too large.';

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
  String gameUnavailable(String action) {
    return '$action will be available in a future step.';
  }

  @override
  String get gameVerifyAction => 'Verification';

  @override
  String get gameSkipAction => 'Skip challenge';

  @override
  String get gameAttemptsTooltip => 'Number of attempts';

  @override
  String gameAttemptsBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tries',
      one: '1 try',
      zero: '0 tries',
    );
    return '$_temp0';
  }

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSubtitle => 'Track your challenges and results.';

  @override
  String get progressDemoLabel => 'YOUR PROGRESS';

  @override
  String get progressResolved => 'Solved challenges';

  @override
  String get progressScore => 'Score';

  @override
  String get progressBestStreak => 'Best streak';

  @override
  String get progressCurrentStreak => 'Current streak';

  @override
  String progressStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
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
  String progressHistoryCaption(String date, String difficulty) {
    return '$date · $difficulty';
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
      'Use each of the four numbers once and build an equality. The = sign is already on the board.\n\nOperators by difficulty:\n• Easy: + − × ÷, parentheses, √, ∛, !, **, |x|, ⌊x⌋ and ⌈x⌉. It is the only level that allows non-integer division (5/2).\n• Intermediate: the same, without floor and ceiling.\n• Advanced: + − × ÷, parentheses, √, ! and |x|.\n• Hard: + − × ÷, parentheses and |x|.\n\nFunctions take a group, √ (8 + 1), or a single number, √ 9. A minus sign before a group negates it: −(2 − 5) = 3.\n\nTap a piece on the board to remove it, and use Skip if a challenge is too hard.';

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

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get progressLoadError => 'Error Loading';

  @override
  String get authBack => 'Back';

  @override
  String get authSignInTitle => 'Sign in with email';

  @override
  String get authSignUpTitle => 'Create your account';

  @override
  String get authSignInSubtitle => 'Enter your email and password to sign in.';

  @override
  String get authSignUpSubtitle =>
      'Fill in the details below to create your account.';

  @override
  String get authTabSignIn => 'Sign in';

  @override
  String get authTabSignUp => 'Create account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordRule => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authSignUpButton => 'Create account';

  @override
  String get authNoAccount => 'No account yet? Create one';

  @override
  String get authForgotPassword => 'Forgot my password';

  @override
  String get authResetTitle => 'Reset password';

  @override
  String get authResetBody =>
      'Enter your email and we will send you a link to create a new password.';

  @override
  String get authResetSend => 'Send link';

  @override
  String get authResetSent => 'Link sent! Check your inbox and spam folder.';

  @override
  String get authCancel => 'Cancel';

  @override
  String get authAccountCreatedTitle => 'Account created successfully!';

  @override
  String get authAccountCreatedBody =>
      'Your account is ready. Now sign in with your email and password.';

  @override
  String get authAccountCreatedAction => 'Go to sign in';

  @override
  String get authAccountCreatedNotice =>
      'Account created! Enter your password to sign in.';

  @override
  String get authEmailRequired => 'Enter your email.';

  @override
  String get authEmailInvalid => 'Enter a valid email, like name@example.com.';

  @override
  String get authPasswordRequired => 'Enter your password.';

  @override
  String get authPasswordTooShort =>
      'The password must have at least 6 characters.';

  @override
  String get authConfirmRequired => 'Repeat the password to confirm.';

  @override
  String get authPasswordsMismatch => 'The passwords do not match.';

  @override
  String get authErrorInvalidCredentials =>
      'Incorrect email or password. Check your details and try again.';

  @override
  String get authErrorUserNotFound =>
      'We could not find an account with this email. Why not create one?';

  @override
  String get authErrorEmailInUse =>
      'This email is already registered. Try signing in with it.';

  @override
  String get authErrorWeakPassword =>
      'Password too weak. Use at least 6 characters.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorGeneric =>
      'Something went wrong. Please try again shortly.';

  @override
  String get accountSignOutConfirmTitle => 'Sign out?';

  @override
  String get accountSignOutConfirmBody =>
      'You will need to sign in again to keep playing.';

  @override
  String get settingsFontSmaller => 'Decrease font size';

  @override
  String get settingsFontLarger => 'Increase font size';

  @override
  String get settingsFontReset => 'Reset to default size';

  @override
  String get settingsColorViolet => 'Violet';

  @override
  String get settingsColorCyan => 'Cyan';

  @override
  String get settingsColorGreen => 'Green';

  @override
  String get settingsResetAppearance => 'Restore default appearance';

  @override
  String get settingsResetDone => 'Appearance restored.';

  @override
  String get settingsUndo => 'Undo';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeSystem => 'Device';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsColorOrange => 'Orange';

  @override
  String get settingsColorPink => 'Pink';

  @override
  String get settingsColorBlue => 'Blue';

  @override
  String get settingsColorRed => 'Red';

  @override
  String get settingsColorCustom => 'Custom';

  @override
  String get settingsCustomColorTitle => 'Pick a color';

  @override
  String get settingsCustomColorApply => 'Apply';

  @override
  String get settingsCustomColorCancel => 'Cancel';

  @override
  String get gameLoading => 'Loading your challenges…';

  @override
  String get gameLoadError => 'Could not load your progress.';

  @override
  String get gameRetry => 'Try again';

  @override
  String get gameAllSolved =>
      'You solved every challenge in this level! They will now repeat.';

  @override
  String get progressSolvedNumbers => 'Solved numbers';
}
