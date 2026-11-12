import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/models/player.dart';
import '../models/charades_deck.dart';
import '../models/charades_game_state.dart';

class CharadesGameNotifier extends Notifier<CharadesGameState> {
  Timer? _timer;

  @override
  CharadesGameState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const CharadesGameState();
  }

  void setupTeams({
    String teamAName = 'الفريق الأول',
    String teamBName = 'الفريق الثاني',
    List<Player> teamAPlayers = const [],
    List<Player> teamBPlayers = const [],
    int totalRounds = 5,
  }) {
    _timer?.cancel();
    final shuffled = List<CharadesCard>.from(kCharadesCards)..shuffle();

    state = CharadesGameState(
      phase: CharadesPhase.roundReady,
      teamAName: teamAName.trim().isEmpty ? 'الفريق الأول' : teamAName,
      teamBName: teamBName.trim().isEmpty ? 'الفريق الثاني' : teamBName,
      teamAPlayers: teamAPlayers,
      teamBPlayers: teamBPlayers,
      teamAActorIndex: 0,
      teamBActorIndex: 0,
      teamAScore: 0,
      teamBScore: 0,
      currentTeam: CharadesTeam.teamA,
      currentRound: 1,
      totalRounds: totalRounds,
      cardsPool: shuffled,
      currentCardIndex: 0,
      remainingWordSwaps: 3,
      secondsRemaining: 90,
      isTimerRunning: false,
    );
  }

  void startTurn() {
    _timer?.cancel();
    state = state.copyWith(
      phase: CharadesPhase.acting,
      secondsRemaining: 90,
      remainingWordSwaps: 3,
      isTimerRunning: true,
      lastRoundSuccess: null,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsRemaining > 1) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        t.cancel();
        teamFailedOrTimedOut();
      }
    });
  }

  void teamGuessedCorrectly() {
    _timer?.cancel();
    final isTeamA = state.currentTeam == CharadesTeam.teamA;
    final newTeamAScore = isTeamA ? state.teamAScore + 1 : state.teamAScore;
    final newTeamBScore = !isTeamA ? state.teamBScore + 1 : state.teamBScore;

    state = state.copyWith(
      phase: CharadesPhase.roundSummary,
      teamAScore: newTeamAScore,
      teamBScore: newTeamBScore,
      isTimerRunning: false,
      lastRoundSuccess: true,
    );
  }

  void teamFailedOrTimedOut() {
    _timer?.cancel();
    state = state.copyWith(
      phase: CharadesPhase.roundSummary,
      isTimerRunning: false,
      lastRoundSuccess: false,
    );
  }

  void swapCurrentCard() {
    if (state.phase != CharadesPhase.acting) return;
    if (state.remainingWordSwaps <= 0) return;
    if (state.cardsPool.isEmpty) return;

    final nextCardIdx = (state.currentCardIndex + 1) % state.cardsPool.length;
    state = state.copyWith(
      currentCardIndex: nextCardIdx,
      remainingWordSwaps: state.remainingWordSwaps - 1,
    );
  }

  void nextTurn() {
    _timer?.cancel();
    final nextCardIdx = (state.currentCardIndex + 1) % state.cardsPool.length;

    if (state.currentTeam == CharadesTeam.teamA) {
      // Advance Team A's actor for its next round, switch to Team B
      state = state.copyWith(
        phase: CharadesPhase.roundReady,
        currentTeam: CharadesTeam.teamB,
        teamAActorIndex: state.teamAActorIndex + 1,
        currentCardIndex: nextCardIdx,
        remainingWordSwaps: 3,
        secondsRemaining: 90,
        lastRoundSuccess: null,
      );
    } else {
      // Completed turn for Team B; advance Team B actor
      final nextBActorIdx = state.teamBActorIndex + 1;

      if (state.currentRound < state.totalRounds) {
        state = state.copyWith(
          phase: CharadesPhase.roundReady,
          currentRound: state.currentRound + 1,
          currentTeam: CharadesTeam.teamA,
          teamBActorIndex: nextBActorIdx,
          currentCardIndex: nextCardIdx,
          remainingWordSwaps: 3,
          secondsRemaining: 90,
          lastRoundSuccess: null,
        );
      } else {
        // Game Over!
        state = state.copyWith(
          phase: CharadesPhase.gameOver,
          teamBActorIndex: nextBActorIdx,
          isTimerRunning: false,
        );
      }
    }
  }

  void reset() {
    _timer?.cancel();
    state = const CharadesGameState();
  }
}

final charadesGameProvider =
    NotifierProvider<CharadesGameNotifier, CharadesGameState>(() {
  return CharadesGameNotifier();
});
