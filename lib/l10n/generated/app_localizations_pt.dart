// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Math Puzzle';

  @override
  String get appLabel => 'Math Puzzle';

  @override
  String get loginTitle => 'Sua próxima ideia começa aqui.';

  @override
  String get loginSubtitle => 'Entre para explorar desafios matemáticos.';

  @override
  String get loginGoogle => 'Continuar com o Google';

  @override
  String get loginEmail => 'Continuar com e-mail';

  @override
  String get loginUnavailable => 'Esta opção estará disponível em breve.';

  @override
  String get loginLanguage => 'IDIOMA';

  @override
  String get loginBack => 'Voltar ao início';

  @override
  String get loginTeamTitle => 'INTEGRANTES';

  @override
  String get loginTeamNames => 'Integrante 1 · Integrante 2';

  @override
  String get loginBrandTag => 'NÚMEROS. IDEIAS. DESCOBERTAS.';

  @override
  String get loginBrandHeading => 'Uma nova forma\nde pensar com números.';

  @override
  String get homeGreeting => 'Olá, jogador';

  @override
  String get homeSubtitle => 'Pronto para um novo desafio?';

  @override
  String get homeAccessAccount => 'Acessar conta';

  @override
  String get homeChallengeTitle => 'SEU DESAFIO ATUAL';

  @override
  String get homePlayNow => 'Jogar agora';

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeYourSpace => 'Seu espaço';

  @override
  String get homeStatsLabel => 'SUAS ESTATÍSTICAS';

  @override
  String get homeStepTitle => 'Uma ideia em três passos';

  @override
  String get homeStepOne => 'Receba quatro números';

  @override
  String get homeStepTwo => 'Combine operações';

  @override
  String get homeStepThree => 'Iguale os dois lados';

  @override
  String get homeSequence => 'Sequência';

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
  String get gameEasy => 'Fácil';

  @override
  String get gameIntermediate => 'Intermediário';

  @override
  String get gameAdvanced => 'Avançado';

  @override
  String get gameHard => 'Difícil';

  @override
  String get gameResultTarget => 'IGUALE OS DOIS LADOS';

  @override
  String get gameRuleHint =>
      'Use cada um dos quatro números uma vez para formar uma igualdade válida.';

  @override
  String get gameDragHint => 'Arraste os números e operadores para jogar.';

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
      'Confira a ordem dos números, operadores e parênteses.';

  @override
  String get gameFeedbackDivisionByZero => 'Não é permitido dividir por zero.';

  @override
  String get gameFeedbackDivisionNotExact =>
      'A divisão deve resultar em um número inteiro.';

  @override
  String get gameFeedbackInvalid =>
      'Esta igualdade é inválida. Confira a expressão.';

  @override
  String get gameFeedbackDomainError =>
      'Operação inválida: raiz não exata, fatorial fora do limite ou resultado grande demais.';

  @override
  String get gameLatexLabel => 'PRÉVIA EM LATEX';

  @override
  String get gameLatexFallback => 'A expressão será renderizada aqui';

  @override
  String get gameVerify => 'Verificar';

  @override
  String get gameClear => 'Limpar';

  @override
  String get gameSkip => 'Pular';

  @override
  String gameUnavailable(String action) {
    return '$action estará disponível em uma etapa futura.';
  }

  @override
  String get gameVerifyAction => 'Verificação';

  @override
  String get gameSkipAction => 'Pular desafio';

  @override
  String get gameAttemptsTooltip => 'Número de tentativas';

  @override
  String gameAttemptsBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativas',
      one: '1 tentativa',
      zero: '0 tentativas',
    );
    return '$_temp0';
  }

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressSubtitle => 'Acompanhe seus desafios e resultados.';

  @override
  String get progressDemoLabel => 'SEU PROGRESSO';

  @override
  String get progressResolved => 'Desafios resolvidos';

  @override
  String get progressScore => 'Pontuação';

  @override
  String get progressBestStreak => 'Melhor sequência';

  @override
  String get progressCurrentStreak => 'Sequência atual';

  @override
  String progressStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
      zero: '0 dias',
    );
    return '$_temp0';
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
  String progressHistoryCaption(String date, String difficulty) {
    return '$date · $difficulty';
  }

  @override
  String get progressEmptyTitle => 'Nenhum desafio resolvido ainda';

  @override
  String get progressEmptyHint =>
      'Resolva um desafio para ver seu progresso aqui.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSubtitle => 'Ajuste a aparência ao seu estilo de jogo.';

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
  String get settingsFontFamily => 'Tipo de fonte';

  @override
  String get settingsAccentColor => 'COR PRINCIPAL';

  @override
  String get settingsSelectAccentColor => 'Selecione a cor principal';

  @override
  String get settingsLanguageSection => 'LANGUAGE / IDIOMA';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsSound => 'Efeitos sonoros';

  @override
  String get settingsSoundDescription => 'Controle do retorno sonoro';

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
      'Use cada um dos quatro números uma vez e monte uma igualdade. O sinal = já está no tabuleiro.\n\nOperadores por dificuldade:\n• Fácil: + − × ÷, parênteses, √, ∛, !, **, |x|, ⌊x⌋ e ⌈x⌉. É o único nível que permite divisão não inteira (5/2).\n• Intermediário: o mesmo, sem base e teto.\n• Avançado: + − × ÷, parênteses, √, ! e |x|.\n• Difícil: + − × ÷, parênteses e |x|.\n\nAs funções recebem um grupo, √ (8 + 1), ou um único número, √ 9. Um sinal de menos antes de um grupo o inverte: −(2 − 5) = 3.\n\nToque em uma peça do tabuleiro para removê-la e use Pular se um desafio estiver difícil demais.';

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
  String get welcomeToApp => 'Bem-vindo ao app';

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

  @override
  String get accountSignOut => 'Sair';

  @override
  String get progressLoadError => 'Erro ao carregar';

  @override
  String get authBack => 'Voltar';

  @override
  String get authSignInTitle => 'Entrar com e-mail';

  @override
  String get authSignUpTitle => 'Criar sua conta';

  @override
  String get authSignInSubtitle => 'Digite seu e-mail e sua senha para entrar.';

  @override
  String get authSignUpSubtitle =>
      'Preencha os dados abaixo para criar sua conta.';

  @override
  String get authTabSignIn => 'Entrar';

  @override
  String get authTabSignUp => 'Criar conta';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authEmailHint => 'nome@exemplo.com';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get authPasswordRule => 'Mínimo de 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authSignInButton => 'Entrar';

  @override
  String get authSignUpButton => 'Criar conta';

  @override
  String get authNoAccount => 'Não tem conta? Criar conta';

  @override
  String get authForgotPassword => 'Esqueci minha senha';

  @override
  String get authResetTitle => 'Redefinir senha';

  @override
  String get authResetBody =>
      'Informe seu e-mail e enviaremos um link para você criar uma nova senha.';

  @override
  String get authResetSend => 'Enviar link';

  @override
  String get authResetSent =>
      'Link enviado! Verifique sua caixa de entrada e o spam.';

  @override
  String get authCancel => 'Cancelar';

  @override
  String get authAccountCreatedTitle => 'Conta criada com sucesso!';

  @override
  String get authAccountCreatedBody =>
      'Sua conta está pronta. Agora entre com seu e-mail e sua senha.';

  @override
  String get authAccountCreatedAction => 'Ir para o login';

  @override
  String get authAccountCreatedNotice =>
      'Conta criada! Digite sua senha para entrar.';

  @override
  String get authEmailRequired => 'Informe seu e-mail.';

  @override
  String get authEmailInvalid =>
      'Digite um e-mail válido, como nome@exemplo.com.';

  @override
  String get authPasswordRequired => 'Informe sua senha.';

  @override
  String get authPasswordTooShort =>
      'A senha precisa ter pelo menos 6 caracteres.';

  @override
  String get authConfirmRequired => 'Repita a senha para confirmar.';

  @override
  String get authPasswordsMismatch => 'As senhas não coincidem.';

  @override
  String get authErrorInvalidCredentials =>
      'E-mail ou senha incorretos. Confira os dados e tente novamente.';

  @override
  String get authErrorUserNotFound =>
      'Não encontramos uma conta com este e-mail. Que tal criar uma?';

  @override
  String get authErrorEmailInUse =>
      'Este e-mail já está cadastrado. Tente entrar com ele.';

  @override
  String get authErrorWeakPassword =>
      'Senha muito fraca. Use pelo menos 6 caracteres.';

  @override
  String get authErrorTooManyRequests =>
      'Muitas tentativas. Aguarde alguns minutos e tente novamente.';

  @override
  String get authErrorNetwork =>
      'Sem conexão com a internet. Verifique sua rede e tente de novo.';

  @override
  String get authErrorUserDisabled => 'Esta conta foi desativada.';

  @override
  String get authErrorGeneric =>
      'Algo deu errado. Tente novamente em instantes.';

  @override
  String get accountSignOutConfirmTitle => 'Sair da conta?';

  @override
  String get accountSignOutConfirmBody =>
      'Você precisará entrar novamente para continuar jogando.';

  @override
  String get settingsFontSmaller => 'Diminuir fonte';

  @override
  String get settingsFontLarger => 'Aumentar fonte';

  @override
  String get settingsFontReset => 'Restaurar tamanho padrão';

  @override
  String get settingsColorViolet => 'Violeta';

  @override
  String get settingsColorCyan => 'Ciano';

  @override
  String get settingsColorGreen => 'Verde';

  @override
  String get settingsResetAppearance => 'Restaurar aparência padrão';

  @override
  String get settingsResetDone => 'Aparência restaurada.';

  @override
  String get settingsUndo => 'Desfazer';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeSystem => 'Dispositivo';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsColorOrange => 'Laranja';

  @override
  String get settingsColorPink => 'Rosa';

  @override
  String get settingsColorBlue => 'Azul';

  @override
  String get settingsColorRed => 'Vermelho';

  @override
  String get settingsColorCustom => 'Personalizada';

  @override
  String get settingsCustomColorTitle => 'Escolha uma cor';

  @override
  String get settingsCustomColorApply => 'Aplicar';

  @override
  String get settingsCustomColorCancel => 'Cancelar';

  @override
  String get gameLoading => 'Carregando seus desafios…';

  @override
  String get gameLoadError => 'Não foi possível carregar seu progresso.';

  @override
  String get gameRetry => 'Tentar novamente';

  @override
  String get gameAllSolved =>
      'Você resolveu todos os desafios deste nível! Eles vão se repetir.';

  @override
  String get progressSolvedNumbers => 'Números resolvidos';
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
  String get gameDragHint => 'Arraste os números e operadores para jogar.';

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
  String gameUnavailable(String action) {
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
  String get progressDifficultyEasy => 'Fácil';

  @override
  String get progressHistoryTitle => 'Histórico ilustrativo';

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
