import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import '../models/who_among_us_game_state.dart';
import '../models/who_among_us_questions.dart';

class WhoAmongUsGameNotifier extends Notifier<WhoAmongUsGameState> {
  @override
  WhoAmongUsGameState build() {
    return const WhoAmongUsGameState();
  }

  void startNewGame() {
    final allPlayers = ref.read(playersProvider);
    if (allPlayers.length < 3) return;

    final shuffledQuestions = List<String>.from(kWhoAmongUsQuestions)..shuffle();

    state = WhoAmongUsGameState(
      phase: WhoAmongUsPhase.questionDisplay,
      players: allPlayers,
      questionsPool: shuffledQuestions,
      currentQuestionIndex: 0,
      currentVoterIndex: 0,
      roundVotes: {},
      totalVotes: {for (var p in allPlayers) p.id: 0},
      roundWinnerId: null,
    );
  }

  void beginVoting() {
    state = state.copyWith(
      phase: WhoAmongUsPhase.voting,
      currentVoterIndex: 0,
      roundVotes: {for (var p in state.players) p.id: 0},
    );
  }

  void castVote(String targetPlayerId) {
    final currentVotes = Map<String, int>.from(state.roundVotes);
    currentVotes[targetPlayerId] = (currentVotes[targetPlayerId] ?? 0) + 1;

    if (state.currentVoterIndex < state.players.length - 1) {
      state = state.copyWith(
        currentVoterIndex: state.currentVoterIndex + 1,
        roundVotes: currentVotes,
      );
    } else {
      // All players voted! Calculate round winner and update totals
      final newTotalVotes = Map<String, int>.from(state.totalVotes);
      String? winnerId;
      int maxVotes = -1;

      currentVotes.forEach((pId, votes) {
        newTotalVotes[pId] = (newTotalVotes[pId] ?? 0) + votes;
        if (votes > maxVotes) {
          maxVotes = votes;
          winnerId = pId;
        }
      });

      state = state.copyWith(
        phase: WhoAmongUsPhase.results,
        roundVotes: currentVotes,
        totalVotes: newTotalVotes,
        roundWinnerId: winnerId,
      );
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questionsPool.length - 1) {
      state = state.copyWith(
        phase: WhoAmongUsPhase.questionDisplay,
        currentQuestionIndex: state.currentQuestionIndex + 1,
        currentVoterIndex: 0,
        roundVotes: {},
        roundWinnerId: null,
      );
    } else {
      showLeaderboard();
    }
  }

  void showLeaderboard() {
    state = state.copyWith(phase: WhoAmongUsPhase.leaderboard);
  }

  void reset() {
    state = const WhoAmongUsGameState();
  }
}

final whoAmongUsGameProvider =
    NotifierProvider<WhoAmongUsGameNotifier, WhoAmongUsGameState>(() {
  return WhoAmongUsGameNotifier();
});
