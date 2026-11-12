enum WinkRole {
  detective, // المحقق (مكشوف للجميع)
  winker,    // الغامز (سري)
  citizen,   // مواطن (سري)
}

class WinkPlayer {
  final String id;
  final String name;
  final int avatarColor;
  final WinkRole role;
  final bool isAlive;

  const WinkPlayer({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.role,
    this.isAlive = true,
  });

  WinkPlayer copyWith({
    String? id,
    String? name,
    int? avatarColor,
    WinkRole? role,
    bool? isAlive,
  }) {
    return WinkPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColor: avatarColor ?? this.avatarColor,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
    );
  }
}

enum WinkPhase {
  roleReveal, // Pass & play to view roles
  inGame,     // Live game circle tracking
  detectiveAccusing, // Detective selects an accused player
  gameOver,
}

class WinkGameState {
  final WinkPhase phase;
  final List<WinkPlayer> players;
  final int currentRevealIndex;
  final bool isCardRevealed;
  final int remainingAccusations;
  final String? winner; // 'detective' or 'winker'
  final String? winnerReason;

  const WinkGameState({
    this.phase = WinkPhase.roleReveal,
    this.players = const [],
    this.currentRevealIndex = 0,
    this.isCardRevealed = false,
    this.remainingAccusations = 2,
    this.winner,
    this.winnerReason,
  });

  WinkPlayer get detective =>
      players.firstWhere((p) => p.role == WinkRole.detective, orElse: () => players.first);

  WinkPlayer get winker =>
      players.firstWhere((p) => p.role == WinkRole.winker, orElse: () => players.first);

  int get aliveCitizensCount =>
      players.where((p) => p.role == WinkRole.citizen && p.isAlive).length;

  WinkGameState copyWith({
    WinkPhase? phase,
    List<WinkPlayer>? players,
    int? currentRevealIndex,
    bool? isCardRevealed,
    int? remainingAccusations,
    String? winner,
    String? winnerReason,
  }) {
    return WinkGameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      isCardRevealed: isCardRevealed ?? this.isCardRevealed,
      remainingAccusations: remainingAccusations ?? this.remainingAccusations,
      winner: winner ?? this.winner,
      winnerReason: winnerReason ?? this.winnerReason,
    );
  }
}
