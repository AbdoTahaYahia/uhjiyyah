import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhjiyyah/core/models/game_modes_registry.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/features/charades_mode/models/charades_game_state.dart';
import 'package:uhjiyyah/features/charades_mode/providers/charades_game_provider.dart';
import 'package:uhjiyyah/features/heads_up_mode/models/heads_up_deck.dart';
import 'package:uhjiyyah/features/heads_up_mode/models/heads_up_game_state.dart';
import 'package:uhjiyyah/features/heads_up_mode/providers/heads_up_game_provider.dart';
import 'package:uhjiyyah/features/out_of_context_mode/models/out_of_context_game_state.dart';
import 'package:uhjiyyah/features/out_of_context_mode/providers/out_of_context_game_provider.dart';
import 'package:uhjiyyah/features/spy_mode/models/spy_game_state.dart';
import 'package:uhjiyyah/features/spy_mode/providers/spy_game_provider.dart';
import 'package:uhjiyyah/features/who_among_us_mode/models/who_among_us_game_state.dart';
import 'package:uhjiyyah/features/who_among_us_mode/providers/who_among_us_game_provider.dart';
import 'package:uhjiyyah/features/wink_mode/models/wink_game_state.dart';
import 'package:uhjiyyah/features/wink_mode/providers/wink_game_provider.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer createContainerWithPlayers(List<String> names) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    for (final name in names) {
      container.read(playersProvider.notifier).addPlayer(name);
    }
    return container;
  }

  test('Registry has 7 games, all available', () {
    expect(kGameModes.length, 7);
    for (final mode in kGameModes) {
      expect(mode.isAvailable, isTrue);
    }
  });

  test('Out of Context mode initializes and handles game loop', () {
    final container = createContainerWithPlayers(['أحمد', 'محمد', 'سارة', 'فاطمة']);
    addTearDown(container.dispose);

    final notifier = container.read(outOfContextGameProvider.notifier);
    notifier.startNewGame();

    final state = container.read(outOfContextGameProvider);
    expect(state.phase, OutOfContextPhase.reveal);
    expect(state.players.length, 4);
    expect(state.players.where((p) => p.isOut).length, 1);

    // Pass through all players
    for (int i = 0; i < 4; i++) {
      notifier.toggleCardReveal();
      notifier.nextPlayer();
    }

    final discState = container.read(outOfContextGameProvider);
    expect(discState.phase, OutOfContextPhase.discussion);

    // Accuse
    final imposter = discState.players.firstWhere((p) => p.isOut);
    notifier.accusePlayer(imposter.id);
    expect(container.read(outOfContextGameProvider).phase, OutOfContextPhase.imposterGuess);

    // Imposter guesses wrong word
    notifier.imposterGuessWord('كلمة خاطئة تماما');
    expect(container.read(outOfContextGameProvider).phase, OutOfContextPhase.gameOver);
    expect(container.read(outOfContextGameProvider).winner, 'civilians');
  });

  test('Heads Up mode selects category, scores points and passes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(headsUpGameProvider.notifier);
    final category = kHeadsUpCategories.first;

    notifier.selectCategory(category);
    expect(container.read(headsUpGameProvider).phase, HeadsUpGamePhase.readyToPlay);

    notifier.startRound();
    expect(container.read(headsUpGameProvider).phase, HeadsUpGamePhase.playing);

    // Score a point
    notifier.markCorrect();
    expect(container.read(headsUpGameProvider).score, 1);
    expect(container.read(headsUpGameProvider).correctWords.length, 1);

    // Pass
    notifier.passWord();
    expect(container.read(headsUpGameProvider).passedWords.length, 1);

    // End round
    notifier.endRound();
    expect(container.read(headsUpGameProvider).phase, HeadsUpGamePhase.roundSummary);
  });

  test('Who Among Us mode handles questions, voting, and leaderboard', () {
    final container = createContainerWithPlayers(['علي', 'حسن', 'منى']);
    addTearDown(container.dispose);

    final notifier = container.read(whoAmongUsGameProvider.notifier);
    notifier.startNewGame();

    final state = container.read(whoAmongUsGameProvider);
    expect(state.phase, WhoAmongUsPhase.questionDisplay);

    notifier.beginVoting();
    expect(container.read(whoAmongUsGameProvider).phase, WhoAmongUsPhase.voting);

    // 3 votes for the first player
    final targetId = state.players.first.id;
    notifier.castVote(targetId);
    notifier.castVote(targetId);
    notifier.castVote(targetId);

    final resultState = container.read(whoAmongUsGameProvider);
    expect(resultState.phase, WhoAmongUsPhase.results);
    expect(resultState.roundWinnerId, targetId);
    expect(resultState.totalVotes[targetId], 3);
  });

  test('Charades mode tracks team turns and scores', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(charadesGameProvider.notifier);
    notifier.setupTeams(teamAName: 'الصقور', teamBName: 'النسور', totalRounds: 3);

    final state = container.read(charadesGameProvider);
    expect(state.phase, CharadesPhase.roundReady);
    expect(state.currentTeam, CharadesTeam.teamA);

    notifier.startTurn();
    expect(container.read(charadesGameProvider).phase, CharadesPhase.acting);

    notifier.teamGuessedCorrectly();
    expect(container.read(charadesGameProvider).phase, CharadesPhase.roundSummary);
    expect(container.read(charadesGameProvider).teamAScore, 1);

    notifier.nextTurn();
    expect(container.read(charadesGameProvider).currentTeam, CharadesTeam.teamB);
  });

  test('Wink mode assigns detective and winker, handles elimination and accusations', () {
    final container = createContainerWithPlayers(['كريم', 'طارق', 'هدى', 'نهى', 'زياد']);
    addTearDown(container.dispose);

    final notifier = container.read(winkGameProvider.notifier);
    notifier.startNewGame();

    final state = container.read(winkGameProvider);
    expect(state.phase, WinkPhase.roleReveal);
    expect(state.players.where((p) => p.role == WinkRole.detective).length, 1);
    expect(state.players.where((p) => p.role == WinkRole.winker).length, 1);
    expect(state.players.where((p) => p.role == WinkRole.citizen).length, 3);

    // Pass through all reveals
    for (int i = 0; i < 5; i++) {
      notifier.toggleCardReveal();
      notifier.nextPlayer();
    }

    final inGameState = container.read(winkGameProvider);
    expect(inGameState.phase, WinkPhase.inGame);

    // Detective accuses the winker directly
    final winker = inGameState.winker;
    notifier.openDetectiveAccusation();
    notifier.makeAccusation(winker.id);

    final finalState = container.read(winkGameProvider);
    expect(finalState.phase, WinkPhase.gameOver);
    expect(finalState.winner, 'detective');
  });

  test('Spy mode assigns exactly 1 spy and location to others', () {
    final container = createContainerWithPlayers(['أحمد', 'منى', 'يوسف', 'عمر']);
    addTearDown(container.dispose);

    final notifier = container.read(spyGameProvider.notifier);
    notifier.startNewGame(container.read(playersProvider));

    final state = container.read(spyGameProvider);
    expect(state.phase, SpyGamePhase.reveal);
    expect(state.players.where((p) => p.isSpy).length, 1);
    expect(state.players.where((p) => !p.isSpy).length, 3);
  });
}
