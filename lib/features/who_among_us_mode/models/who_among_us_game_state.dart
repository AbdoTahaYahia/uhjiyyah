import 'package:uhjiyyah/core/models/player.dart';

enum WhoAmongUsPhase {
  questionDisplay, // The question is shown to all players
  voting,          // Passing phone or secret voting for the question
  results,         // Votes are tallied and the winner/target of the question is revealed
  leaderboard,     // Overview of who got the most votes throughout all rounds
}

class WhoAmongUsGameState {
  final WhoAmongUsPhase phase;
  final List<Player> players;
  final List<String> questionsPool;
  final int currentQuestionIndex;
  final int currentVoterIndex; // for pass & play secret voting
  final Map<String, int> roundVotes; // playerId -> count of votes in current question
  final Map<String, int> totalVotes; // playerId -> total votes across all questions
  final String? roundWinnerId;

  const WhoAmongUsGameState({
    this.phase = WhoAmongUsPhase.questionDisplay,
    this.players = const [],
    this.questionsPool = const [],
    this.currentQuestionIndex = 0,
    this.currentVoterIndex = 0,
    this.roundVotes = const {},
    this.totalVotes = const {},
    this.roundWinnerId,
  });

  String get currentQuestion =>
      questionsPool.isNotEmpty && currentQuestionIndex < questionsPool.length
          ? questionsPool[currentQuestionIndex]
          : '';

  WhoAmongUsGameState copyWith({
    WhoAmongUsPhase? phase,
    List<Player>? players,
    List<String>? questionsPool,
    int? currentQuestionIndex,
    int? currentVoterIndex,
    Map<String, int>? roundVotes,
    Map<String, int>? totalVotes,
    String? roundWinnerId,
  }) {
    return WhoAmongUsGameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      questionsPool: questionsPool ?? this.questionsPool,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentVoterIndex: currentVoterIndex ?? this.currentVoterIndex,
      roundVotes: roundVotes ?? this.roundVotes,
      totalVotes: totalVotes ?? this.totalVotes,
      roundWinnerId: roundWinnerId ?? this.roundWinnerId,
    );
  }
}
