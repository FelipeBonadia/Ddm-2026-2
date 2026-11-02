// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Desafio Matemático';

  @override
  String get appLabel => 'Desafio Matemático';

  @override
  String get loginTitle => 'Sua próxima ideia começa aqui.';

  @override
  String get loginSubtitle => 'Entre para explorar desafios matemáticos.';

  @override
  String get loginGoogle => 'Continuar com Google';

  @override
  String get loginEmail => 'Continuar com e-mail';

  @override
  String get loginUnavailable => 'Esta opção estará disponível em breve.';

  @override
  String get loginLanguage => 'IDIOMA';

  @override
  String get loginBack => 'Voltar ao início';

  @override
  String get loginTeamTitle => 'INTEGRANTES DA EQUIPE';

  @override
  String get loginTeamNames => 'Integrante 1 · Integrante 2';

  @override
  String get loginBrandTag => 'NÚMEROS. IDEIAS. DESCOBERTAS.';

  @override
  String get loginBrandHeading => 'Uma nova maneira\nde pensar com números.';

  @override
  String get homeGreeting => 'Olá, jogador';

  @override
  String get homeSubtitle => 'Pronto para um novo desafio?';

  @override
  String get homeAccessAccount => 'Acessar conta';

  @override
  String get homeChallengeTitle => 'ALCANCE O RESULTADO';

  @override
  String get homePlayNow => 'Jogar agora';

  @override
  String get homeContinue => 'Continuar jogando';

  @override
  String get homeYourSpace => 'Seu espaço';

  @override
  String get homeStatsLabel => 'DADOS DE DEMONSTRAÇÃO';

  @override
  String get homeStepTitle => 'Uma ideia em três etapas';

  @override
  String get homeStepOne => 'Receba quatro números';

  @override
  String get homeStepTwo => 'Combine operações';

  @override
  String get homeStepThree => 'Alcance o resultado';

  @override
  String get homeSequence => 'Sequência';

  @override
  String get homeStreakValue => '3 dias';

  @override
  String get homeChallenges => 'Desafios';

  @override
  String get homePrecision => 'Precisão';

  @override
  String get gameBack => 'Voltar ao início';

  @override
  String get gameTitle => 'Desafio';

  @override
  String get gameTimer => '--:--';

  @override
  String get gameChallengeDay => 'DESAFIO DO DIA';

  @override
  String get gameLevel => 'DIFICULDADE';

  @override
  String get gameEasy => 'FÁCIL';

  @override
  String get gameIntermediate => 'INTERMEDIÁRIO';

  @override
  String get gameAdvanced => 'AVANÇADO';

  @override
  String get gameHard => 'DIFÍCIL';

  @override
  String get gameResultTarget => 'IGUALE OS DOIS LADOS';

  @override
  String get gameRuleHint =>
      'Use cada um dos quatro números uma única vez para formar uma igualdade válida.';

  @override
  String get gameLeftSide => 'LADO ESQUERDO';

  @override
  String get gameRightSide => 'LADO DIREITO';

  @override
  String get gameNumbers => 'NÚMEROS';

  @override
  String get gameOperations => 'OPERADORES';

  @override
  String get gameExpressionLabel => 'SUA EXPRESSÃO';

  @override
  String get gameExpressionPlaceholder => 'Monte sua expressão';

  @override
  String get gameBoardEmptyHint => 'Arraste ou toque para adicionar à equação';

  @override
  String get gameRemoveTokenHint => 'Toque para remover';

  @override
  String get gameUndo => 'Desfazer';

  @override
  String get gameEquality => '=';

  @override
  String get gameContinue => 'Próximo desafio';

  @override
  String get gameFeedbackCorrect => 'Igualdade correta!';

  @override
  String get gameFeedbackIncorrect =>
      'Os dois lados não são iguais. Tente novamente.';

  @override
  String get gameFeedbackIncomplete =>
      'Complete os dois lados e use os quatro números.';

  @override
  String get gameFeedbackMissingEquality =>
      'Insira o sinal de igual (=) para formar a igualdade.';

  @override
  String get gameFeedbackWrongNumbers =>
      'Use cada número disponível exatamente uma vez.';

  @override
  String get gameFeedbackOperationNotAllowed =>
      'Essa operação não é permitida nesta dificuldade.';

  @override
  String get gameFeedbackInvalidSyntax =>
      'Verifique a ordem dos números, operadores e parênteses.';

  @override
  String get gameFeedbackDivisionByZero =>
      'A divisão por zero não é permitida.';

  @override
  String get gameFeedbackDivisionNotExact =>
      'A divisão deve resultar em um número inteiro.';

  @override
  String get gameFeedbackInvalid =>
      'Essa igualdade é inválida. Verifique a expressão.';

  @override
  String get gameFeedbackDomainError => 'Erro de domínio.';

  @override
  String get gameLatexLabel => 'PRÉVIA LATEX';

  @override
  String get gameLatexFallback => 'A expressão será exibida aqui';

  @override
  String get gameVerify => 'Verificar';

  @override
  String get gameClear => 'Limpar';

  @override
  String get gameSkip => 'Pular';

  @override
  String gameUnavailable(Object action) {
    return '\$action estará disponível em uma etapa futura.';
  }

  @override
  String get gameVerifyAction => 'Verificação';

  @override
  String get gameSkipAction => 'Pular desafio';

  @override
  String get gameAttemptsTooltip => 'Número de tentativas';

  @override
  String gameAttemptsBadge(Object count) {
    return '\$count tentativas';
  }

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressSubtitle => 'Acompanhe seus desafios e resultados.';

  @override
  String get progressDemoLabel => 'DADOS DE DEMONSTRAÇÃO';

  @override
  String get progressResolved => 'Desafios resolvidos';

  @override
  String get progressScore => 'Pontuação';

  @override
  String get progressBestStreak => 'Melhor sequência';

  @override
  String get progressBestStreakValue => '3 dias';

  @override
  String get progressCurrentStreak => 'Sequência atual';

  @override
  String progressStreakDays(Object days) {
    return '\$days dias';
  }

  @override
  String get progressDifficultyEasy => 'Fácil';

  @override
  String get progressDifficultyIntermediate => 'Intermediário';

  @override
  String get progressDifficultyAdvanced => 'Avançado';

  @override
  String get progressDifficultyHard => 'Difícil';

  @override
  String get progressHistoryTitle => 'Histórico';

  @override
  String progressHistoryDemo(Object difficulty) {
    return 'Demonstração · \$difficulty';
  }

  @override
  String progressHistoryCaption(Object date, Object difficulty) {
    return '\$date · \$difficulty';
  }

  @override
  String get progressEmptyTitle => 'Nenhum desafio resolvido ainda';

  @override
  String get progressEmptyHint =>
      'Resolva um desafio para ver seu progresso aqui.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSubtitle =>
      'Personalize a aparência de acordo com seu estilo de jogo.';

  @override
  String get settingsAppearance => 'APARÊNCIA';

  @override
  String get settingsDarkTheme => 'Tema escuro';

  @override
  String get settingsOn => 'Ativado';

  @override
  String get settingsOff => 'Desativado';

  @override
  String get settingsReading => 'LEITURA';

  @override
  String get settingsFontSize => 'Tamanho da fonte';

  @override
  String get settingsFontFamily => 'Família da fonte';

  @override
  String get settingsAccentColor => 'COR PRINCIPAL';

  @override
  String get settingsSelectAccentColor => 'Selecionar cor principal';

  @override
  String get settingsLanguageSection => 'IDIOMA / LANGUAGE';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsSound => 'Efeitos sonoros';

  @override
  String get settingsSoundDescription => 'Controle de feedback sonoro';

  @override
  String get settingsAudioSection => 'ÁUDIO';

  @override
  String get settingsSoundEnabled => 'Ativado';

  @override
  String get settingsSoundDisabled => 'Desativado';

  @override
  String get settingsSoundStatus => 'Ativado';

  @override
  String get helpTitle => 'Como jogar';

  @override
  String get helpMessage =>
      'Use os quatro números do desafio e combine operações matemáticas para alcançar o resultado indicado. Monte sua expressão antes de verificar.';

  @override
  String get helpAction => 'Entendi';

  @override
  String get navHome => 'Início';

  @override
  String get navGame => 'Jogo';

  @override
  String get navProgress => 'Progresso';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navRailTag => 'DESAFIOS, UM PASSO DE CADA VEZ';

  @override
  String get welcomeToApp => 'Bem-vindo ao aplicativo';

  @override
  String get localePortuguese => '🇧🇷 Português';

  @override
  String get localeEnglish => '🇺🇸 Inglês';

  @override
  String get systemStatus => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeModeSystem => 'Sistema';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appName => 'Math Puzzle';

  @override
  String get appLabel => 'Math Puzzle';

  @override
  String get loginTitle => 'Sua próxima ideia começa aqui.';

  @override
  String get loginSubtitle => 'Entre para explorar os desafios matemáticos.';

  @override
  String get loginGoogle => 'Continuar com Google';

  @override
  String get loginEmail => 'Continuar com e-mail';

  @override
  String get loginUnavailable => 'Esta opção ficará disponível em breve.';

  @override
  String get loginLanguage => 'IDIOMA';

  @override
  String get loginBack => 'Voltar ao início';

  @override
  String get loginTeamTitle => 'INTEGRANTES DO GRUPO';

  @override
  String get loginTeamNames => 'Integrante 1 · Integrante 2';

  @override
  String get loginBrandTag => 'NÚMEROS. IDEIAS. DESCOBERTAS.';

  @override
  String get loginBrandHeading => 'Um jeito novo\nde pensar com números.';

  @override
  String get homeGreeting => 'Olá, jogador';

  @override
  String get homeSubtitle => 'Pronto para um novo desafio?';

  @override
  String get homeAccessAccount => 'Acessar conta';

  @override
  String get homeChallengeTitle => 'ALCANCE O RESULTADO';

  @override
  String get homePlayNow => 'Jogar agora';

  @override
  String get homeContinue => 'Continuar jogando';

  @override
  String get homeYourSpace => 'Seu espaço';

  @override
  String get homeStatsLabel => 'DADOS DEMONSTRATIVOS';

  @override
  String get homeStepTitle => 'Uma ideia em três passos';

  @override
  String get homeStepOne => 'Receba quatro números';

  @override
  String get homeStepTwo => 'Combine operações';

  @override
  String get homeStepThree => 'Alcance o alvo';

  @override
  String get homeSequence => 'Sequência';

  @override
  String get homeStreakValue => '3 dias';

  @override
  String get homeChallenges => 'Desafios';

  @override
  String get homePrecision => 'Precisão';

  @override
  String get gameBack => 'Voltar ao início';

  @override
  String get gameTitle => 'Desafio';

  @override
  String get gameTimer => '--:--';

  @override
  String get gameChallengeDay => 'DESAFIO DO DIA';

  @override
  String get gameLevel => 'DIFICULDADE';

  @override
  String get gameEasy => 'FÁCIL';

  @override
  String get gameHard => 'DIFÍCIL';

  @override
  String get gameResultTarget => 'DEIXE OS DOIS LADOS IGUAIS';

  @override
  String get gameRuleHint =>
      'Use cada um dos quatro números uma vez para formar uma igualdade.';

  @override
  String get gameLeftSide => 'LADO ESQUERDO';

  @override
  String get gameRightSide => 'LADO DIREITO';

  @override
  String get gameNumbers => 'NÚMEROS';

  @override
  String get gameOperations => 'OPERAÇÕES';

  @override
  String get gameExpressionLabel => 'SUA EXPRESSÃO';

  @override
  String get gameExpressionPlaceholder => 'Monte sua expressão';

  @override
  String get gameUndo => 'Desfazer';

  @override
  String get gameEquality => '=';

  @override
  String get gameContinue => 'Próximo desafio';

  @override
  String get gameFeedbackCorrect => 'Igualdade correta!';

  @override
  String get gameFeedbackIncorrect =>
      'Os dois lados não são iguais. Tente novamente.';

  @override
  String get gameFeedbackIncomplete =>
      'Complete os dois lados usando os quatro números.';

  @override
  String get gameFeedbackWrongNumbers =>
      'Use cada número disponível exatamente uma vez.';

  @override
  String get gameFeedbackOperationNotAllowed =>
      'Essa operação não é permitida nesta dificuldade.';

  @override
  String get gameFeedbackInvalidSyntax =>
      'Confira a ordem dos números, operações e parênteses.';

  @override
  String get gameFeedbackDivisionByZero => 'Divisão por zero não é permitida.';

  @override
  String get gameFeedbackDivisionNotExact =>
      'A divisão deve resultar em um número inteiro.';

  @override
  String get gameFeedbackInvalid =>
      'A igualdade é inválida. Confira a expressão.';

  @override
  String get gameLatexLabel => 'PRÉVIA LATEX';

  @override
  String get gameLatexFallback => 'A expressão será renderizada aqui';

  @override
  String get gameVerify => 'Verificar';

  @override
  String get gameClear => 'Limpar';

  @override
  String get gameSkip => 'Pular';

  @override
  String gameUnavailable(Object action) {
    return '$action ficará disponível em uma próxima etapa.';
  }

  @override
  String get gameVerifyAction => 'Verificação';

  @override
  String get gameSkipAction => 'Pular o desafio';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressSubtitle => 'Acompanhe seus desafios e resultados.';

  @override
  String get progressDemoLabel => 'DADOS DEMONSTRATIVOS';

  @override
  String get progressResolved => 'Desafios resolvidos';

  @override
  String get progressScore => 'Pontuação';

  @override
  String get progressBestStreak => 'Melhor sequência';

  @override
  String get progressBestStreakValue => '3 dias';

  @override
  String get progressDifficultyEasy => 'Fácil';

  @override
  String get progressHistoryTitle => 'Histórico ilustrativo';

  @override
  String progressHistoryDemo(Object difficulty) {
    return 'Demonstração · $difficulty';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSubtitle =>
      'Ajuste a aparência para o seu jeito de jogar.';

  @override
  String get settingsAppearance => 'APARÊNCIA';

  @override
  String get settingsDarkTheme => 'Tema escuro';

  @override
  String get settingsOn => 'Ativado';

  @override
  String get settingsOff => 'Desativado';

  @override
  String get settingsReading => 'LEITURA';

  @override
  String get settingsFontSize => 'Tamanho da fonte';

  @override
  String get settingsFontFamily => 'Família tipográfica';

  @override
  String get settingsAccentColor => 'COR PRINCIPAL';

  @override
  String get settingsSelectAccentColor => 'Selecionar cor principal';

  @override
  String get settingsLanguageSection => 'IDIOMA / LANGUAGE';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsSound => 'Efeitos sonoros';

  @override
  String get settingsSoundDescription => 'Controle de feedback auditivo';

  @override
  String get settingsAudioSection => 'ÁUDIO';

  @override
  String get settingsSoundEnabled => 'Ativados';

  @override
  String get settingsSoundDisabled => 'Desativados';

  @override
  String get settingsSoundStatus => 'Ativado';

  @override
  String get helpTitle => 'Como jogar';

  @override
  String get helpMessage =>
      'Use os quatro números do desafio e combine operações matemáticas para alcançar o resultado indicado. Organize sua expressão antes de conferir.';

  @override
  String get helpAction => 'Entendi';

  @override
  String get navHome => 'Início';

  @override
  String get navGame => 'Jogo';

  @override
  String get navProgress => 'Progresso';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navRailTag => 'DESAFIOS, UM PASSO DE CADA VEZ';

  @override
  String get welcomeToApp => 'Bem-vindo ao aplicativo';

  @override
  String get localePortuguese => '🇧🇷 Português';

  @override
  String get localeEnglish => '🇺🇸 English';

  @override
  String get systemStatus => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeModeSystem => 'Sistema';
}
