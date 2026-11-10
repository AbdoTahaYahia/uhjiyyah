import 'mafia_player.dart';
import 'mafia_role.dart';

/// The sequential phases of a Mafia game cycle.
enum MafiaPhase {
  rules,
  revealRoles,
  nightTurns, // Each alive player takes the phone in turn to eliminate metagaming
  dawnReport,
  dayDiscussion,
  dayVoting,
  gameOver,
}

/// The immutable state of an ongoing Mafia game.
class MafiaGameState {
  final MafiaPhase phase;
  final List<MafiaPlayer> players;
  final int currentRevealIndex;
  final bool isCardRevealed;
  final int roundNumber;

  // Night turn-by-turn state
  final int currentNightPlayerIndex;
  final bool isNightActionRevealed; // whether current player pressed "start my night turn"

  // Night phase accumulated actions
  final String? mafiaTargetId;
  final String? doctorProtectedId;
  final String? detectiveCheckedId;
  final bool? detectiveInspectionResult; // true if checked player is Mafia

  // Resolution
  final MafiaPlayer? lastKilledPlayer;
  final bool wasSavedByDoctor;
  final MafiaPlayer? lastExecutedPlayer;

  // Day voting
  final Map<String, int> votes; // playerId -> vote count
  final String? voterSkipChoice;

  // End game
  final MafiaTeam? winner;
  final String? winnerReason;

  const MafiaGameState({
    this.phase = MafiaPhase.rules,
    this.players = const [],
    this.currentRevealIndex = 0,
    this.isCardRevealed = false,
    this.roundNumber = 1,
    this.currentNightPlayerIndex = 0,
    this.isNightActionRevealed = false,
    this.mafiaTargetId,
    this.doctorProtectedId,
    this.detectiveCheckedId,
    this.detectiveInspectionResult,
    this.lastKilledPlayer,
    this.wasSavedByDoctor = false,
    this.lastExecutedPlayer,
    this.votes = const {},
    this.voterSkipChoice,
    this.winner,
    this.winnerReason,
  });

  /// Players still alive.
  List<MafiaPlayer> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  /// Players eliminated.
  List<MafiaPlayer> get deadPlayers =>
      players.where((p) => !p.isAlive).toList();

  /// Alive Mafia members.
  List<MafiaPlayer> get aliveMafia =>
      alivePlayers.where((p) => p.role == MafiaRole.mafia).toList();

  /// Alive Citizens (including Doctor & Detective).
  List<MafiaPlayer> get aliveCitizens =>
      alivePlayers.where((p) => p.role.team == MafiaTeam.citizens).toList();

  /// Whether the doctor is still alive.
  bool get isDoctorAlive =>
      alivePlayers.any((p) => p.role == MafiaRole.doctor);

  /// Whether the detective is still alive.
  bool get isDetectiveAlive =>
      alivePlayers.any((p) => p.role == MafiaRole.detective);

  /// Current player taking their night turn.
  MafiaPlayer? get currentNightPlayer {
    final alive = alivePlayers;
    if (currentNightPlayerIndex >= 0 &&
        currentNightPlayerIndex < alive.length) {
      return alive[currentNightPlayerIndex];
    }
    return null;
  }

  MafiaGameState copyWith({
    MafiaPhase? phase,
    List<MafiaPlayer>? players,
    int? currentRevealIndex,
    bool? isCardRevealed,
    int? roundNumber,
    int? currentNightPlayerIndex,
    bool? isNightActionRevealed,
    String? mafiaTargetId,
    String? doctorProtectedId,
    String? detectiveCheckedId,
    bool? detectiveInspectionResult,
    MafiaPlayer? lastKilledPlayer,
    bool? wasSavedByDoctor,
    MafiaPlayer? lastExecutedPlayer,
    Map<String, int>? votes,
    String? voterSkipChoice,
    MafiaTeam? winner,
    String? winnerReason,
  }) {
    return MafiaGameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      isCardRevealed: isCardRevealed ?? this.isCardRevealed,
      roundNumber: roundNumber ?? this.roundNumber,
      currentNightPlayerIndex:
          currentNightPlayerIndex ?? this.currentNightPlayerIndex,
      isNightActionRevealed:
          isNightActionRevealed ?? this.isNightActionRevealed,
      mafiaTargetId: mafiaTargetId ?? this.mafiaTargetId,
      doctorProtectedId: doctorProtectedId ?? this.doctorProtectedId,
      detectiveCheckedId: detectiveCheckedId ?? this.detectiveCheckedId,
      detectiveInspectionResult:
          detectiveInspectionResult ?? this.detectiveInspectionResult,
      lastKilledPlayer: lastKilledPlayer ?? this.lastKilledPlayer,
      wasSavedByDoctor: wasSavedByDoctor ?? this.wasSavedByDoctor,
      lastExecutedPlayer: lastExecutedPlayer ?? this.lastExecutedPlayer,
      votes: votes ?? this.votes,
      voterSkipChoice: voterSkipChoice ?? this.voterSkipChoice,
      winner: winner ?? this.winner,
      winnerReason: winnerReason ?? this.winnerReason,
    );
  }
}
