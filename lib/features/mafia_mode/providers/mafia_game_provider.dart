import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/models/player.dart';
import '../models/mafia_game_state.dart';
import '../models/mafia_player.dart';
import '../models/mafia_role.dart';

/// Riverpod Notifier for the complete Mafia game lifecycle with Turn-by-Turn Night.
class MafiaGameNotifier extends Notifier<MafiaGameState> {
  @override
  MafiaGameState build() => const MafiaGameState();

  /// Starts a new game from the global player roster.
  void startNewGame(List<Player> globalPlayers) {
    if (globalPlayers.isEmpty) return;

    final count = globalPlayers.length;
    final int mafiaCount = max(1, (count / 4).floor());
    const int doctorCount = 1;
    final int detectiveCount = count >= 4 ? 1 : 0;
    final int citizenCount =
        max(0, count - mafiaCount - doctorCount - detectiveCount);

    final List<MafiaRole> rolePool = [];
    for (int i = 0; i < mafiaCount; i++) {
      rolePool.add(MafiaRole.mafia);
    }
    for (int i = 0; i < doctorCount; i++) {
      rolePool.add(MafiaRole.doctor);
    }
    for (int i = 0; i < detectiveCount; i++) {
      rolePool.add(MafiaRole.detective);
    }
    for (int i = 0; i < citizenCount; i++) {
      rolePool.add(MafiaRole.citizen);
    }

    rolePool.shuffle(Random());

    final List<MafiaPlayer> mafiaPlayers = [];
    for (int i = 0; i < count; i++) {
      mafiaPlayers.add(
        MafiaPlayer(
          id: globalPlayers[i].id,
          name: globalPlayers[i].name,
          avatarColor: globalPlayers[i].avatarColor,
          role: rolePool[i],
          isAlive: true,
          score: 0,
        ),
      );
    }

    state = MafiaGameState(
      phase: MafiaPhase.revealRoles,
      players: mafiaPlayers,
      currentRevealIndex: 0,
      isCardRevealed: false,
      roundNumber: 1,
    );
  }

  /// Toggles revealing the secret card for the current player in initial reveal.
  void toggleRevealCard() {
    state = state.copyWith(isCardRevealed: !state.isCardRevealed);
  }

  /// Advances to next player in initial role reveal.
  void nextRoleReveal() {
    if (state.currentRevealIndex + 1 < state.players.length) {
      state = state.copyWith(
        currentRevealIndex: state.currentRevealIndex + 1,
        isCardRevealed: false,
      );
    } else {
      // All players saw their roles -> start Night turn-by-turn sequence
      _startNightPhase();
    }
  }

  /// Prepares and enters the Night turn-by-turn phase.
  void _startNightPhase() {
    state = state.copyWith(
      phase: MafiaPhase.nightTurns,
      currentNightPlayerIndex: 0,
      isNightActionRevealed: false,
      mafiaTargetId: null,
      doctorProtectedId: null,
      detectiveCheckedId: null,
      detectiveInspectionResult: null,
      lastKilledPlayer: null,
      wasSavedByDoctor: false,
    );
  }

  /// Current night player taps "Start My Night Turn"
  void revealNightAction() {
    state = state.copyWith(isNightActionRevealed: true);
  }

  /// Submits an action for the current night player and advances to next player.
  void submitCurrentNightTurn({
    String? selectedTargetId,
  }) {
    final player = state.currentNightPlayer;
    if (player == null) return;

    String? newMafiaTarget = state.mafiaTargetId;
    String? newDoctorProtect = state.doctorProtectedId;
    String? newDetectiveChecked = state.detectiveCheckedId;
    bool? newDetectiveResult = state.detectiveInspectionResult;

    if (player.role == MafiaRole.mafia && selectedTargetId != null) {
      newMafiaTarget = selectedTargetId;
    } else if (player.role == MafiaRole.doctor && selectedTargetId != null) {
      newDoctorProtect = selectedTargetId;
    } else if (player.role == MafiaRole.detective && selectedTargetId != null) {
      newDetectiveChecked = selectedTargetId;
      final inspected = state.players.firstWhere((p) => p.id == selectedTargetId);
      newDetectiveResult = inspected.role == MafiaRole.mafia;
    }

    state = state.copyWith(
      mafiaTargetId: newMafiaTarget,
      doctorProtectedId: newDoctorProtect,
      detectiveCheckedId: newDetectiveChecked,
      detectiveInspectionResult: newDetectiveResult,
    );

    // Advance to next alive player or resolve night
    final alive = state.alivePlayers;
    if (state.currentNightPlayerIndex + 1 < alive.length) {
      state = state.copyWith(
        currentNightPlayerIndex: state.currentNightPlayerIndex + 1,
        isNightActionRevealed: false,
      );
    } else {
      // Everyone finished night turn -> resolve night to dawn
      _resolveNight();
    }
  }

  /// Resolves the night actions and transitions to Dawn report.
  void _resolveNight() {
    final targetId = state.mafiaTargetId;
    final protectedId = state.doctorProtectedId;

    bool saved = false;
    MafiaPlayer? killedPlayer;

    if (targetId != null) {
      if (targetId == protectedId) {
        saved = true;
      } else {
        final index = state.players.indexWhere((p) => p.id == targetId);
        if (index != -1) {
          killedPlayer = state.players[index];
          final updated = List<MafiaPlayer>.from(state.players);
          updated[index] = updated[index].copyWith(isAlive: false);
          state = state.copyWith(players: updated);
        }
      }
    }

    state = state.copyWith(
      phase: MafiaPhase.dawnReport,
      lastKilledPlayer: killedPlayer,
      wasSavedByDoctor: saved,
      isNightActionRevealed: false,
    );

    _checkWinCondition();
  }

  /// Moves from Dawn report to Day discussion.
  void proceedToDayDiscussion() {
    state = state.copyWith(phase: MafiaPhase.dayDiscussion);
  }

  /// Moves from Day discussion to Day voting.
  void proceedToDayVoting() {
    state = state.copyWith(
      phase: MafiaPhase.dayVoting,
      votes: {},
      lastExecutedPlayer: null,
    );
  }

  /// Submits an execution vote from discussion.
  void executePlayer(String targetId) {
    final index = state.players.indexWhere((p) => p.id == targetId);
    if (index != -1) {
      final executed = state.players[index];
      final updated = List<MafiaPlayer>.from(state.players);
      updated[index] = updated[index].copyWith(isAlive: false);

      state = state.copyWith(
        players: updated,
        lastExecutedPlayer: executed,
      );

      final hasWon = _checkWinCondition();
      if (!hasWon) {
        _prepareNextNight();
      }
    }
  }

  /// Skips voting without executing anyone.
  void skipDayVoting() {
    state = state.copyWith(lastExecutedPlayer: null);
    _prepareNextNight();
  }

  /// Clears transient targets and enters next night.
  void _prepareNextNight() {
    state = state.copyWith(
      phase: MafiaPhase.nightTurns,
      roundNumber: state.roundNumber + 1,
      currentNightPlayerIndex: 0,
      isNightActionRevealed: false,
      mafiaTargetId: null,
      doctorProtectedId: null,
      detectiveCheckedId: null,
      detectiveInspectionResult: null,
      lastKilledPlayer: null,
      wasSavedByDoctor: false,
    );
  }

  /// Checks if either team has won. Returns true if game is over.
  bool _checkWinCondition() {
    final aliveMafiaCount = state.aliveMafia.length;
    final aliveCitizensCount = state.aliveCitizens.length;

    if (aliveMafiaCount == 0) {
      final updated = state.players.map((p) {
        if (p.role.team == MafiaTeam.citizens && p.isAlive) {
          return p.copyWith(score: p.score + 70);
        }
        return p;
      }).toList();

      state = state.copyWith(
        phase: MafiaPhase.gameOver,
        players: updated,
        winner: MafiaTeam.citizens,
        winnerReason: 'تم القضاء على جميع أفراد المافيا! انتصر مواطنو القرية!',
      );
      return true;
    }

    if (aliveMafiaCount >= aliveCitizensCount) {
      final updated = state.players.map((p) {
        if (p.role == MafiaRole.mafia && p.isAlive) {
          return p.copyWith(score: p.score + 70);
        }
        return p;
      }).toList();

      state = state.copyWith(
        phase: MafiaPhase.gameOver,
        players: updated,
        winner: MafiaTeam.mafia,
        winnerReason: 'تغلبت المافيا وسيطرت على القرية بالكامل!',
      );
      return true;
    }

    return false;
  }

  /// Resets to rules screen.
  void resetGame() {
    state = const MafiaGameState(phase: MafiaPhase.rules);
  }
}

final mafiaGameProvider =
    NotifierProvider<MafiaGameNotifier, MafiaGameState>(
  MafiaGameNotifier.new,
);
