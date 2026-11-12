import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/heads_up_deck.dart';
import '../models/heads_up_game_state.dart';

class HeadsUpGameNotifier extends Notifier<HeadsUpGameState> {
  Timer? _timer;

  @override
  HeadsUpGameState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const HeadsUpGameState();
  }

  void selectCategory(HeadsUpCategory category) {
    _timer?.cancel();
    final shuffled = List<String>.from(category.words)..shuffle();
    final firstWord = shuffled.isNotEmpty ? shuffled.first : '';
    final rest = shuffled.length > 1 ? shuffled.sublist(1) : <String>[];

    state = HeadsUpGameState(
      phase: HeadsUpGamePhase.readyToPlay,
      selectedCategory: category,
      remainingWords: rest,
      currentWord: firstWord,
      correctWords: [],
      passedWords: [],
      secondsRemaining: 60,
      isTimerRunning: false,
      score: 0,
    );
  }

  void startRound() {
    _timer?.cancel();
    state = state.copyWith(
      phase: HeadsUpGamePhase.playing,
      isTimerRunning: true,
      secondsRemaining: 60,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsRemaining > 1) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        t.cancel();
        endRound();
      }
    });
  }

  void markCorrect() {
    if (state.phase != HeadsUpGamePhase.playing) return;

    final updatedCorrect = [...state.correctWords, state.currentWord];
    final newScore = state.score + 1;

    if (state.remainingWords.isEmpty) {
      // Re-shuffle to keep going if all words used
      final reloaded = List<String>.from(state.selectedCategory.words)..shuffle();
      state = state.copyWith(
        correctWords: updatedCorrect,
        score: newScore,
        currentWord: reloaded.first,
        remainingWords: reloaded.sublist(1),
      );
    } else {
      final nextWord = state.remainingWords.first;
      final rest = state.remainingWords.sublist(1);
      state = state.copyWith(
        correctWords: updatedCorrect,
        score: newScore,
        currentWord: nextWord,
        remainingWords: rest,
      );
    }
  }

  void passWord() {
    if (state.phase != HeadsUpGamePhase.playing) return;

    final updatedPassed = [...state.passedWords, state.currentWord];

    if (state.remainingWords.isEmpty) {
      final reloaded = List<String>.from(state.selectedCategory.words)..shuffle();
      state = state.copyWith(
        passedWords: updatedPassed,
        currentWord: reloaded.first,
        remainingWords: reloaded.sublist(1),
      );
    } else {
      final nextWord = state.remainingWords.first;
      final rest = state.remainingWords.sublist(1);
      state = state.copyWith(
        passedWords: updatedPassed,
        currentWord: nextWord,
        remainingWords: rest,
      );
    }
  }

  void endRound() {
    _timer?.cancel();
    state = state.copyWith(
      phase: HeadsUpGamePhase.roundSummary,
      isTimerRunning: false,
      secondsRemaining: 0,
    );
  }

  void reset() {
    _timer?.cancel();
    state = const HeadsUpGameState();
  }
}

final headsUpGameProvider =
    NotifierProvider<HeadsUpGameNotifier, HeadsUpGameState>(() {
  return HeadsUpGameNotifier();
});
