import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import '../models/out_of_context_game_state.dart';
import '../models/out_of_context_topics.dart';

class OutOfContextGameNotifier extends Notifier<OutOfContextGameState> {
  Timer? _timer;

  @override
  OutOfContextGameState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const OutOfContextGameState();
  }

  void startNewGame() {
    _timer?.cancel();
    final allPlayers = ref.read(playersProvider);
    if (allPlayers.length < 3) return;

    final random = Random();
    final randomTopic = kOutOfContextTopics[random.nextInt(kOutOfContextTopics.length)];

    // Pick 1 imposter (out of context)
    final imposterIndex = random.nextInt(allPlayers.length);

    final outPlayers = <OutOfContextPlayer>[];
    for (int i = 0; i < allPlayers.length; i++) {
      final p = allPlayers[i];
      final isOut = (i == imposterIndex);
      outPlayers.add(
        OutOfContextPlayer(
          id: p.id,
          name: p.name,
          avatarColor: p.avatarColor,
          isOut: isOut,
        ),
      );
    }

    state = OutOfContextGameState(
      phase: OutOfContextPhase.reveal,
      players: outPlayers,
      topic: randomTopic,
      currentRevealIndex: 0,
      isCardRevealed: false,
      secondsRemaining: 240, // 4 minutes
      isTimerRunning: false,
      winner: null,
      winnerReason: null,
    );
  }

  void toggleCardReveal() {
    state = state.copyWith(isCardRevealed: !state.isCardRevealed);
  }

  void nextPlayer() {
    if (state.currentRevealIndex < state.players.length - 1) {
      state = state.copyWith(
        currentRevealIndex: state.currentRevealIndex + 1,
        isCardRevealed: false,
      );
    } else {
      // Done revealing to all players; enter discussion phase
      state = state.copyWith(
        phase: OutOfContextPhase.discussion,
        isCardRevealed: false,
      );
      startTimer();
    }
  }

  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        t.cancel();
        state = state.copyWith(
          isTimerRunning: false,
          phase: OutOfContextPhase.voting,
        );
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  void resumeTimer() {
    startTimer();
  }

  void startVoting() {
    _timer?.cancel();
    state = state.copyWith(
      isTimerRunning: false,
      phase: OutOfContextPhase.voting,
    );
  }

  void accusePlayer(String playerId) {
    final accused = state.players.firstWhere((p) => p.id == playerId);
    if (accused.isOut) {
      // The players caught the imposter! The imposter gets one chance to guess the secret word.
      state = state.copyWith(
        phase: OutOfContextPhase.imposterGuess,
        accusedPlayerId: playerId,
      );
    } else {
      // Accused an innocent player! The imposter wins immediately.
      final imposter = state.players.firstWhere((p) => p.isOut);
      state = state.copyWith(
        phase: OutOfContextPhase.gameOver,
        accusedPlayerId: playerId,
        winner: 'imposter',
        winnerReason: 'تم اتهام لاعب بريء (${accused.name})! فاز المتسلل (${imposter.name}) بالخداع والمراوغة.',
      );
    }
  }

  void imposterGuessWord(String guessedWord) {
    final isCorrect = guessedWord.trim().toLowerCase() ==
        state.topic.secretWordAr.trim().toLowerCase();
    final imposter = state.players.firstWhere((p) => p.isOut);

    if (isCorrect) {
      state = state.copyWith(
        phase: OutOfContextPhase.gameOver,
        winner: 'imposter',
        winnerReason: 'رغم كشف المتسلل (${imposter.name})، إلا أنه استطاع تخمين الكلمة السرية بنجاح!',
      );
    } else {
      state = state.copyWith(
        phase: OutOfContextPhase.gameOver,
        winner: 'civilians',
        winnerReason: 'فاز باقي اللاعبين! تم كشف المتسلل (${imposter.name}) وفشل في معرفة الكلمة السرية.',
      );
    }
  }

  void resetGame() {
    _timer?.cancel();
    state = const OutOfContextGameState();
  }
}

final outOfContextGameProvider =
    NotifierProvider<OutOfContextGameNotifier, OutOfContextGameState>(() {
  return OutOfContextGameNotifier();
});
