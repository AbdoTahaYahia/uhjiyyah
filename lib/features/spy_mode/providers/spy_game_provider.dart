import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/models/player.dart';
import '../models/spy_game_state.dart';
import '../models/spy_locations.dart';

class SpyGameNotifier extends Notifier<SpyGameState> {
  Timer? _timer;

  @override
  SpyGameState build() => const SpyGameState();

  /// Starts a new Spyfall game session.
  void startNewGame(List<Player> globalPlayers) {
    _timer?.cancel();
    if (globalPlayers.length < 3) return;

    final random = Random();
    // Choose random location
    final location = kSpyLocations[random.nextInt(kSpyLocations.length)];
    // Choose one random spy index (or 2 if >= 8 players)
    final spyIndex = random.nextInt(globalPlayers.length);

    final List<SpyPlayer> players = [];
    final shuffledRoles = List<String>.from(location.rolesAr)..shuffle(random);

    for (int i = 0; i < globalPlayers.length; i++) {
      final isSpy = (i == spyIndex);
      final role = isSpy
          ? 'الجاسوس'
          : shuffledRoles[i % shuffledRoles.length];

      players.add(
        SpyPlayer(
          id: globalPlayers[i].id,
          name: globalPlayers[i].name,
          avatarColor: globalPlayers[i].avatarColor,
          isSpy: isSpy,
          roleInLocation: role,
        ),
      );
    }

    state = SpyGameState(
      phase: SpyGamePhase.reveal,
      players: players,
      location: location,
      currentRevealIndex: 0,
      isCardRevealed: false,
      secondsRemaining: 360, // 6 minutes
      isTimerRunning: false,
    );
  }

  void toggleCard() {
    state = state.copyWith(isCardRevealed: !state.isCardRevealed);
  }

  void nextPlayer() {
    if (state.currentRevealIndex + 1 < state.players.length) {
      state = state.copyWith(
        currentRevealIndex: state.currentRevealIndex + 1,
        isCardRevealed: false,
      );
    } else {
      // Start discussion
      state = state.copyWith(
        phase: SpyGamePhase.discussion,
        isCardRevealed: false,
        isTimerRunning: true,
      );
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0 && state.isTimerRunning) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else if (state.secondsRemaining <= 0) {
        timer.cancel();
        // Time ran out -> Vote who is spy
        state = state.copyWith(phase: SpyGamePhase.voting, isTimerRunning: false);
      }
    });
  }

  void toggleTimer() {
    state = state.copyWith(isTimerRunning: !state.isTimerRunning);
  }

  void startVoting() {
    _timer?.cancel();
    state = state.copyWith(phase: SpyGamePhase.voting, isTimerRunning: false);
  }

  /// Players vote on a suspect.
  void submitVote(String suspectPlayerId) {
    final suspect = state.players.firstWhere((p) => p.id == suspectPlayerId);
    if (suspect.isSpy) {
      // Caught the spy! Spy has one last chance to guess location
      state = state.copyWith(
        phase: SpyGamePhase.spyGuessLocation,
      );
    } else {
      // Wrong person accused -> Spy wins!
      state = state.copyWith(
        phase: SpyGamePhase.gameOver,
        winner: 'الجاسوس',
        winnerReason: 'أخطأ أهل المكان في الاتهام واشتبهوا بشخص بريء! انتصر الجاسوس!',
      );
    }
  }

  /// Spy tries to guess the location.
  void submitSpyGuess(String guessedLocationName) {
    if (guessedLocationName == state.location.nameAr) {
      state = state.copyWith(
        phase: SpyGamePhase.gameOver,
        winner: 'الجاسوس',
        winnerReason: 'رغم كشفه، استطاع الجاسوس معرفة المكان السري بدقة (${state.location.nameAr}) وانتصر!',
      );
    } else {
      state = state.copyWith(
        phase: SpyGamePhase.gameOver,
        winner: 'أهل المكان',
        winnerReason: 'فشل الجاسوس في تخمين المكان الصحيح! انتصر أهل المكان وحافظوا على السرية!',
      );
    }
  }

  void reset() {
    _timer?.cancel();
    state = const SpyGameState();
  }
}

final spyGameProvider =
    NotifierProvider<SpyGameNotifier, SpyGameState>(
  SpyGameNotifier.new,
);
