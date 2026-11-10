import 'mafia_role.dart';

/// Represents a participant in an active Mafia game session.
class MafiaPlayer {
  final String id;
  final String name;
  final int avatarColor;
  final MafiaRole role;
  final bool isAlive;
  final int score;

  const MafiaPlayer({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.role,
    this.isAlive = true,
    this.score = 0,
  });

  MafiaPlayer copyWith({
    String? id,
    String? name,
    int? avatarColor,
    MafiaRole? role,
    bool? isAlive,
    int? score,
  }) {
    return MafiaPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColor: avatarColor ?? this.avatarColor,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      score: score ?? this.score,
    );
  }
}
