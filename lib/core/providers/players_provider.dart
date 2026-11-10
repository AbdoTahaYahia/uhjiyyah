/// Global player-list state management for the Uhjiyyah app with local persistence.
///
/// Uses Riverpod's [Notifier] to expose the list of [Player]s that
/// have been added. All changes are automatically persisted to [SharedPreferences]
/// so players remain saved across app closures and restarts.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/player.dart';

// ---------------------------------------------------------------------------
// Constants & Storage
// ---------------------------------------------------------------------------

/// Storage key for persisting the player roster.
const String _kPlayersStorageKey = 'uhjiyyah_saved_players';

/// Provider for pre-initialized [SharedPreferences] instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

/// A fixed palette of elegant grayscale avatar tones (as 0xAARRGGBB int values).
const List<int> _kAvatarColors = <int>[
  0xFF383838,
  0xFF4A4A4A,
  0xFF5C5C5C,
  0xFF6E6E6E,
  0xFF808080,
  0xFF455A64,
  0xFF546E7A,
  0xFF37474F,
];

/// Reusable UUID generator (v4).
const Uuid _uuid = Uuid();

/// Shared [Random] instance for avatar-colour selection.
final Random _random = Random();

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages the global list of [Player]s with synchronous instant restoration
/// from [SharedPreferences] on app startup.
class GlobalPlayerListNotifier extends Notifier<List<Player>> {
  late SharedPreferences _prefs;

  @override
  List<Player> build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final String? rawJson = _prefs.getString(_kPlayersStorageKey);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        return decoded
            .map((item) => Player.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error loading saved players: $e');
      }
    }
    return <Player>[];
  }

  /// Persists current player roster to storage.
  Future<void> _saveToStorage() async {
    try {
      final String encoded = jsonEncode(state.map((p) => p.toJson()).toList());
      await _prefs.setString(_kPlayersStorageKey, encoded);
    } catch (e) {
      debugPrint('Error saving players to storage: $e');
    }
  }

  /// Adds a new [Player] with the given [name] and persists the list.
  void addPlayer(String name) {
    final int colorValue =
        _kAvatarColors[_random.nextInt(_kAvatarColors.length)];

    final Player player = Player(
      id: _uuid.v4(),
      name: name,
      avatarColor: colorValue,
    );

    state = [...state, player];
    _saveToStorage();
  }

  /// Removes the player whose [id] matches [playerId] and persists.
  void removePlayer(String playerId) {
    state = state.where((Player p) => p.id != playerId).toList();
    _saveToStorage();
  }

  /// Removes **all** players from the list and clears storage.
  void clearAll() {
    state = <Player>[];
    _saveToStorage();
  }

  /// The current number of players in the list.
  int get playerCount => state.length;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// A [NotifierProvider] that exposes the persisted global player list.
final NotifierProvider<GlobalPlayerListNotifier, List<Player>> playersProvider =
    NotifierProvider<GlobalPlayerListNotifier, List<Player>>(
  GlobalPlayerListNotifier.new,
);
