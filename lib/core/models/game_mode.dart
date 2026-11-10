import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_mode.freezed.dart';
part 'game_mode.g.dart';

/// Represents a game mode available in the Uhjiyyah party game app.
///
/// Each mode has bilingual titles and descriptions (Arabic & English),
/// player count constraints, an icon, and a route for navigation.
@freezed
abstract class GameMode with _$GameMode {
  const factory GameMode({
    /// Unique identifier for the game mode.
    required String id,

    /// Arabic title of the game mode.
    required String titleAr,

    /// English title of the game mode.
    required String titleEn,

    /// Arabic description explaining the game mode.
    required String descriptionAr,

    /// English description explaining the game mode.
    required String descriptionEn,

    /// Icon representing the game mode in the UI.
    /// Excluded from JSON serialization since [IconData] is not serializable.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(Icons.games)
    IconData icon,

    /// Minimum number of players required for this mode.
    @Default(2) int minPlayers,

    /// Maximum number of players allowed in this mode.
    @Default(20) int maxPlayers,

    /// Whether this game mode is currently available to play.
    @Default(true) bool isAvailable,

    /// The named route used to navigate to this game mode's screen.
    required String routeName,
  }) = _GameMode;

  factory GameMode.fromJson(Map<String, dynamic> json) =>
      _$GameModeFromJson(json);
}
