import 'package:flutter/material.dart';
import 'spy_locations.dart';

class SpyPlayer {
  final String id;
  final String name;
  final int avatarColor;
  final bool isSpy;
  final String roleInLocation;

  const SpyPlayer({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.isSpy,
    required this.roleInLocation,
  });
}

enum SpyGamePhase {
  reveal,
  discussion,
  voting,
  spyGuessLocation,
  gameOver,
}

class SpyGameState {
  final SpyGamePhase phase;
  final List<SpyPlayer> players;
  final SpyLocation location;
  final int currentRevealIndex;
  final bool isCardRevealed;
  final int secondsRemaining;
  final bool isTimerRunning;
  final String? winner;
  final String? winnerReason;

  const SpyGameState({
    this.phase = SpyGamePhase.reveal,
    this.players = const [],
    this.location = const SpyLocation(nameAr: '', icon: Icons.place_outlined, rolesAr: []),
    this.currentRevealIndex = 0,
    this.isCardRevealed = false,
    this.secondsRemaining = 360,
    this.isTimerRunning = false,
    this.winner,
    this.winnerReason,
  });

  SpyGameState copyWith({
    SpyGamePhase? phase,
    List<SpyPlayer>? players,
    SpyLocation? location,
    int? currentRevealIndex,
    bool? isCardRevealed,
    int? secondsRemaining,
    bool? isTimerRunning,
    String? winner,
    String? winnerReason,
  }) {
    return SpyGameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      location: location ?? this.location,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      isCardRevealed: isCardRevealed ?? this.isCardRevealed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      winner: winner ?? this.winner,
      winnerReason: winnerReason ?? this.winnerReason,
    );
  }
}
