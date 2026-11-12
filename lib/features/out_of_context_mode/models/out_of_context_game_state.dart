import 'out_of_context_topics.dart';

class OutOfContextPlayer {
  final String id;
  final String name;
  final int avatarColor;
  final bool isOut; // True if this player is the imposter ("out of context")

  const OutOfContextPlayer({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.isOut,
  });
}

enum OutOfContextPhase {
  reveal, // Passing phone to see role / word
  discussion, // Asking questions around the circle
  voting, // Pointing or voting on the suspected imposter
  imposterGuess, // If imposter was caught, they can guess the word
  gameOver,
}

class OutOfContextGameState {
  final OutOfContextPhase phase;
  final List<OutOfContextPlayer> players;
  final OutOfContextTopic topic;
  final int currentRevealIndex;
  final bool isCardRevealed;
  final int secondsRemaining;
  final bool isTimerRunning;
  final String? accusedPlayerId;
  final String? winner; // 'civilians' or 'imposter'
  final String? winnerReason;

  const OutOfContextGameState({
    this.phase = OutOfContextPhase.reveal,
    this.players = const [],
    this.topic = const OutOfContextTopic(
      categoryAr: '',
      secretWordAr: '',
      decoyWordsAr: [],
      hintAr: '',
    ),
    this.currentRevealIndex = 0,
    this.isCardRevealed = false,
    this.secondsRemaining = 240,
    this.isTimerRunning = false,
    this.accusedPlayerId,
    this.winner,
    this.winnerReason,
  });

  OutOfContextGameState copyWith({
    OutOfContextPhase? phase,
    List<OutOfContextPlayer>? players,
    OutOfContextTopic? topic,
    int? currentRevealIndex,
    bool? isCardRevealed,
    int? secondsRemaining,
    bool? isTimerRunning,
    String? accusedPlayerId,
    String? winner,
    String? winnerReason,
  }) {
    return OutOfContextGameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      topic: topic ?? this.topic,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      isCardRevealed: isCardRevealed ?? this.isCardRevealed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      accusedPlayerId: accusedPlayerId ?? this.accusedPlayerId,
      winner: winner ?? this.winner,
      winnerReason: winnerReason ?? this.winnerReason,
    );
  }
}
