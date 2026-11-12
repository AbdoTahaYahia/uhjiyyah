import 'package:uhjiyyah/core/models/player.dart';
import 'charades_deck.dart';

enum CharadesPhase {
  teamSetup,
  roundReady,
  acting,
  roundSummary,
  gameOver,
}

enum CharadesTeam {
  teamA,
  teamB,
}

class CharadesGameState {
  final CharadesPhase phase;
  final String teamAName;
  final String teamBName;
  final List<Player> teamAPlayers;
  final List<Player> teamBPlayers;
  final int teamAActorIndex;
  final int teamBActorIndex;
  final int teamAScore;
  final int teamBScore;
  final CharadesTeam currentTeam;
  final int currentRound;
  final int totalRounds;
  final List<CharadesCard> cardsPool;
  final int currentCardIndex;
  final int secondsRemaining;
  final bool isTimerRunning;
  final bool? lastRoundSuccess; // null if pending, true if guessed, false if timeout/skip

  const CharadesGameState({
    this.phase = CharadesPhase.teamSetup,
    this.teamAName = 'الفريق الأول',
    this.teamBName = 'الفريق الثاني',
    this.teamAPlayers = const [],
    this.teamBPlayers = const [],
    this.teamAActorIndex = 0,
    this.teamBActorIndex = 0,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.currentTeam = CharadesTeam.teamA,
    this.currentRound = 1,
    this.totalRounds = 5,
    this.cardsPool = const [],
    this.currentCardIndex = 0,
    this.secondsRemaining = 90,
    this.isTimerRunning = false,
    this.lastRoundSuccess,
  });

  CharadesCard get currentCard =>
      cardsPool.isNotEmpty && currentCardIndex < cardsPool.length
          ? cardsPool[currentCardIndex]
          : const CharadesCard(title: '', categoryAr: '');

  String get currentActiveTeamName =>
      currentTeam == CharadesTeam.teamA ? teamAName : teamBName;

  List<Player> get currentActiveTeamPlayers =>
      currentTeam == CharadesTeam.teamA ? teamAPlayers : teamBPlayers;

  Player? get currentActor {
    final list = currentActiveTeamPlayers;
    if (list.isEmpty) return null;
    final idx = currentTeam == CharadesTeam.teamA ? teamAActorIndex : teamBActorIndex;
    return list[idx % list.length];
  }

  List<Player> get currentTeammates {
    final list = currentActiveTeamPlayers;
    final actor = currentActor;
    if (actor == null) return list;
    return list.where((p) => p.id != actor.id).toList();
  }

  CharadesGameState copyWith({
    CharadesPhase? phase,
    String? teamAName,
    String? teamBName,
    List<Player>? teamAPlayers,
    List<Player>? teamBPlayers,
    int? teamAActorIndex,
    int? teamBActorIndex,
    int? teamAScore,
    int? teamBScore,
    CharadesTeam? currentTeam,
    int? currentRound,
    int? totalRounds,
    List<CharadesCard>? cardsPool,
    int? currentCardIndex,
    int? secondsRemaining,
    bool? isTimerRunning,
    bool? lastRoundSuccess,
  }) {
    return CharadesGameState(
      phase: phase ?? this.phase,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      teamAActorIndex: teamAActorIndex ?? this.teamAActorIndex,
      teamBActorIndex: teamBActorIndex ?? this.teamBActorIndex,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      currentTeam: currentTeam ?? this.currentTeam,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      cardsPool: cardsPool ?? this.cardsPool,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      lastRoundSuccess: lastRoundSuccess,
    );
  }
}
