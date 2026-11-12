import 'heads_up_deck.dart';

enum HeadsUpGamePhase {
  categorySelection,
  readyToPlay,
  playing,
  roundSummary,
}

class HeadsUpGameState {
  final HeadsUpGamePhase phase;
  final HeadsUpCategory selectedCategory;
  final List<String> remainingWords;
  final String currentWord;
  final List<String> correctWords;
  final List<String> passedWords;
  final int secondsRemaining;
  final bool isTimerRunning;
  final int score;

  const HeadsUpGameState({
    this.phase = HeadsUpGamePhase.categorySelection,
    this.selectedCategory = const HeadsUpCategory(
      id: '',
      nameAr: '',
      descriptionAr: '',
      emoji: '',
      words: [],
    ),
    this.remainingWords = const [],
    this.currentWord = '',
    this.correctWords = const [],
    this.passedWords = const [],
    this.secondsRemaining = 60,
    this.isTimerRunning = false,
    this.score = 0,
  });

  HeadsUpGameState copyWith({
    HeadsUpGamePhase? phase,
    HeadsUpCategory? selectedCategory,
    List<String>? remainingWords,
    String? currentWord,
    List<String>? correctWords,
    List<String>? passedWords,
    int? secondsRemaining,
    bool? isTimerRunning,
    int? score,
  }) {
    return HeadsUpGameState(
      phase: phase ?? this.phase,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      remainingWords: remainingWords ?? this.remainingWords,
      currentWord: currentWord ?? this.currentWord,
      correctWords: correctWords ?? this.correctWords,
      passedWords: passedWords ?? this.passedWords,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      score: score ?? this.score,
    );
  }
}
