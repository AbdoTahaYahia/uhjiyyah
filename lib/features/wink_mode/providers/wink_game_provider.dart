import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import '../models/wink_game_state.dart';

class WinkGameNotifier extends Notifier<WinkGameState> {
  @override
  WinkGameState build() {
    return const WinkGameState();
  }

  void startNewGame() {
    final allPlayers = ref.read(playersProvider);
    if (allPlayers.length < 4) return;

    final random = Random();
    final shuffledIndices = List.generate(allPlayers.length, (i) => i)..shuffle(random);

    final detectiveIdx = shuffledIndices[0];
    final winkerIdx = shuffledIndices[1];

    final winkPlayers = <WinkPlayer>[];
    for (int i = 0; i < allPlayers.length; i++) {
      final p = allPlayers[i];
      WinkRole role;
      if (i == detectiveIdx) {
        role = WinkRole.detective;
      } else if (i == winkerIdx) {
        role = WinkRole.winker;
      } else {
        role = WinkRole.citizen;
      }

      winkPlayers.add(
        WinkPlayer(
          id: p.id,
          name: p.name,
          avatarColor: p.avatarColor,
          role: role,
          isAlive: true,
        ),
      );
    }

    state = WinkGameState(
      phase: WinkPhase.roleReveal,
      players: winkPlayers,
      currentRevealIndex: 0,
      isCardRevealed: false,
      remainingAccusations: 2,
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
      // Done revealing, start in-game circle phase
      state = state.copyWith(
        phase: WinkPhase.inGame,
        isCardRevealed: false,
      );
    }
  }

  void eliminatePlayer(String playerId) {
    final updatedPlayers = state.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(isAlive: false);
      }
      return p;
    }).toList();

    // Check if remaining alive citizens is 1 or fewer -> winker wins
    final remainingCitizens =
        updatedPlayers.where((p) => p.role == WinkRole.citizen && p.isAlive).length;

    if (remainingCitizens <= 1) {
      final winkerPlayer = state.players.firstWhere((p) => p.role == WinkRole.winker);
      state = state.copyWith(
        players: updatedPlayers,
        phase: WinkPhase.gameOver,
        winner: 'winker',
        winnerReason: 'تمكن الغامز (${winkerPlayer.name}) من إقصاء جميع المواطنين دون كشفه!',
      );
    } else {
      state = state.copyWith(players: updatedPlayers);
    }
  }

  void openDetectiveAccusation() {
    state = state.copyWith(phase: WinkPhase.detectiveAccusing);
  }

  void cancelAccusation() {
    state = state.copyWith(phase: WinkPhase.inGame);
  }

  void makeAccusation(String accusedPlayerId) {
    final accused = state.players.firstWhere((p) => p.id == accusedPlayerId);
    final detectivePlayer = state.players.firstWhere((p) => p.role == WinkRole.detective);
    final winkerPlayer = state.players.firstWhere((p) => p.role == WinkRole.winker);

    if (accused.role == WinkRole.winker) {
      // Detective wins!
      state = state.copyWith(
        phase: WinkPhase.gameOver,
        winner: 'detective',
        winnerReason: 'أحسنت! تمكن المحقق (${detectivePlayer.name}) من كشف الغامز الحقيقي (${winkerPlayer.name}) بنجاح!',
      );
    } else {
      final newRemaining = state.remainingAccusations - 1;
      if (newRemaining <= 0) {
        // Detective exhausted all accusations -> Winker wins!
        state = state.copyWith(
          phase: WinkPhase.gameOver,
          remainingAccusations: 0,
          winner: 'winker',
          winnerReason: 'استنفد المحقق جميع محاولات الاتهام! فاز الغامز (${winkerPlayer.name}) بالدهاء والتخفي.',
        );
      } else {
        // Return to inGame with 1 fewer accusation
        state = state.copyWith(
          phase: WinkPhase.inGame,
          remainingAccusations: newRemaining,
        );
      }
    }
  }

  void reset() {
    state = const WinkGameState();
  }
}

final winkGameProvider =
    NotifierProvider<WinkGameNotifier, WinkGameState>(() {
  return WinkGameNotifier();
});
