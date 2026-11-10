import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Represents a player in the Uhjiyyah party game.
///
/// Each player has a unique [id], a display [name], and an [avatarColor]
/// used to visually distinguish them in the UI.
@freezed
abstract class Player with _$Player {
  const factory Player({
    /// Unique identifier for the player. Assigned by the provider.
    @Default('') String id,

    /// The player's display name.
    required String name,

    /// ARGB color value for the player's avatar.
    /// Defaults to gold (0xFFE0A526).
    @Default(0xFFE0A526) int avatarColor,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

/// Preset list of vibrant avatar colors to randomly assign to players.
const List<int> kAvatarColors = [
  0xFFE0A526, // Gold
  0xFFE53935, // Red
  0xFF43A047, // Green
  0xFF1E88E5, // Blue
  0xFF8E24AA, // Purple
  0xFFFB8C00, // Orange
  0xFF00ACC1, // Cyan
  0xFFD81B60, // Pink
  0xFF3949AB, // Indigo
  0xFF00897B, // Teal
];
