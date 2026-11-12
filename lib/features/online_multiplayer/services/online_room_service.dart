import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/online_room.dart';

class OnlineRoomService {
  static final OnlineRoomService _instance = OnlineRoomService._internal();
  factory OnlineRoomService() => _instance;
  OnlineRoomService._internal();

  static const _timeout = Duration(milliseconds: 2000);

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  // In-memory fallback if Firebase is not connected or in offline test mode
  final Map<String, OnlineRoom> _localRooms = {};
  final Map<String, StreamController<OnlineRoom?>> _localRoomControllers = {};

  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(5, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<OnlineRoom> createRoom({
    required String hostName,
    required String hostId,
    String gameModeId = 'mafia',
  }) async {
    final code = generateRoomCode();
    final host = OnlinePlayer(
      id: hostId,
      name: hostName,
      isHost: true,
      isReady: true,
    );

    final room = OnlineRoom(
      code: code,
      hostId: hostId,
      gameModeId: gameModeId,
      status: 'waiting',
      players: [host],
    );

    final db = _firestore;
    if (db != null) {
      try {
        await db.collection('rooms').doc(code).set(room.toMap()).timeout(_timeout);
        return room;
      } catch (_) {}
    }

    // Local fallback
    _localRooms[code] = room;
    _getOrCreateLocalController(code).add(room);
    return room;
  }

  Future<OnlineRoom?> joinRoom({
    required String code,
    required String playerName,
    required String playerId,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        final docRef = db.collection('rooms').doc(normalizedCode);
        final doc = await docRef.get().timeout(_timeout);
        if (!doc.exists) return null;

        final currentRoom = OnlineRoom.fromMap(doc.data()!);
        if (currentRoom.status != 'waiting') return null;

        // Check if player already in room
        final alreadyIn = currentRoom.players.any((p) => p.id == playerId);
        List<OnlinePlayer> updatedPlayers;

        if (alreadyIn) {
          updatedPlayers = currentRoom.players;
        } else {
          updatedPlayers = [
            ...currentRoom.players,
            OnlinePlayer(id: playerId, name: playerName),
          ];
        }

        final updatedRoom = currentRoom.copyWith(players: updatedPlayers);
        await docRef
            .update({'players': updatedPlayers.map((p) => p.toMap()).toList()})
            .timeout(_timeout);
        return updatedRoom;
      } catch (_) {}
    }

    // Local fallback
    final room = _localRooms[normalizedCode];
    if (room == null || room.status != 'waiting') return null;

    final alreadyIn = room.players.any((p) => p.id == playerId);
    final updatedPlayers = alreadyIn
        ? room.players
        : [...room.players, OnlinePlayer(id: playerId, name: playerName)];

    final updated = room.copyWith(players: updatedPlayers);
    _localRooms[normalizedCode] = updated;
    _getOrCreateLocalController(normalizedCode).add(updated);
    return updated;
  }

  Future<OnlineRoom?> joinRandomRoom({
    required String playerName,
    required String playerId,
  }) async {
    final db = _firestore;
    if (db != null) {
      try {
        final query = await db
            .collection('rooms')
            .where('status', isEqualTo: 'waiting')
            .limit(10)
            .get()
            .timeout(_timeout);

        for (final doc in query.docs) {
          final room = OnlineRoom.fromMap(doc.data());
          if (room.players.length < 12) {
            return await joinRoom(
              code: room.code,
              playerName: playerName,
              playerId: playerId,
            );
          }
        }
      } catch (_) {}
    }

    // Local fallback search
    final waitingRooms = _localRooms.values
        .where((r) => r.status == 'waiting' && r.players.length < 12)
        .toList();

    if (waitingRooms.isNotEmpty) {
      return await joinRoom(
        code: waitingRooms.first.code,
        playerName: playerName,
        playerId: playerId,
      );
    }

    // If no room is waiting, create one automatically
    return await createRoom(
      hostName: playerName,
      hostId: playerId,
    );
  }

  Stream<OnlineRoom?> streamRoom(String code) {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        return db.collection('rooms').doc(normalizedCode).snapshots().map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;
          return OnlineRoom.fromMap(snapshot.data()!);
        });
      } catch (_) {}
    }

    return _getOrCreateLocalController(normalizedCode).stream;
  }

  Future<void> updateGameMode(String code, String gameModeId) async {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        await db
            .collection('rooms')
            .doc(normalizedCode)
            .update({'gameModeId': gameModeId}).timeout(_timeout);
        return;
      } catch (_) {}
    }

    final room = _localRooms[normalizedCode];
    if (room != null) {
      final updated = room.copyWith(gameModeId: gameModeId);
      _localRooms[normalizedCode] = updated;
      _getOrCreateLocalController(normalizedCode).add(updated);
    }
  }

  Future<void> setPlayerReady(String code, String playerId, bool isReady) async {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        final docRef = db.collection('rooms').doc(normalizedCode);
        final doc = await docRef.get().timeout(_timeout);
        if (doc.exists) {
          final room = OnlineRoom.fromMap(doc.data()!);
          final updated = room.players.map((p) {
            return p.id == playerId ? p.copyWith(isReady: isReady) : p;
          }).toList();
          await docRef
              .update({'players': updated.map((p) => p.toMap()).toList()})
              .timeout(_timeout);
          return;
        }
      } catch (_) {}
    }

    final room = _localRooms[normalizedCode];
    if (room != null) {
      final updated = room.copyWith(
        players: room.players.map((p) {
          return p.id == playerId ? p.copyWith(isReady: isReady) : p;
        }).toList(),
      );
      _localRooms[normalizedCode] = updated;
      _getOrCreateLocalController(normalizedCode).add(updated);
    }
  }

  Future<void> startGame(String code, Map<String, dynamic> initialGameState) async {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        await db.collection('rooms').doc(normalizedCode).update({
          'status': 'in_game',
          'gameState': initialGameState,
        }).timeout(_timeout);
        return;
      } catch (_) {}
    }

    final room = _localRooms[normalizedCode];
    if (room != null) {
      final updated = room.copyWith(
        status: 'in_game',
        gameState: initialGameState,
      );
      _localRooms[normalizedCode] = updated;
      _getOrCreateLocalController(normalizedCode).add(updated);
    }
  }

  Future<void> leaveRoom(String code, String playerId) async {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        final docRef = db.collection('rooms').doc(normalizedCode);
        final doc = await docRef.get();
        if (doc.exists) {
          final room = OnlineRoom.fromMap(doc.data()!);
          final remaining = room.players.where((p) => p.id != playerId).toList();
          if (remaining.isEmpty) {
            await docRef.delete();
          } else {
            await docRef.update({
              'players': remaining.map((p) => p.toMap()).toList(),
              if (room.hostId == playerId) 'hostId': remaining.first.id,
            });
          }
          return;
        }
      } catch (_) {}
    }

    final room = _localRooms[normalizedCode];
    if (room != null) {
      final remaining = room.players.where((p) => p.id != playerId).toList();
      if (remaining.isEmpty) {
        _localRooms.remove(normalizedCode);
      } else {
        final updated = room.copyWith(
          players: remaining,
          hostId: room.hostId == playerId ? remaining.first.id : room.hostId,
        );
        _localRooms[normalizedCode] = updated;
        _getOrCreateLocalController(normalizedCode).add(updated);
      }
    }
  }

  Future<void> sendChatMessage({
    required String code,
    required RoomChatMessage message,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final db = _firestore;

    if (db != null) {
      try {
        final docRef = db.collection('rooms').doc(normalizedCode);
        await docRef.update({
          'messages': FieldValue.arrayUnion([message.toMap()]),
        }).timeout(_timeout);
        return;
      } catch (_) {}
    }

    final room = _localRooms[normalizedCode];
    if (room != null) {
      final updated = room.copyWith(
        messages: [...room.messages, message],
      );
      _localRooms[normalizedCode] = updated;
      _getOrCreateLocalController(normalizedCode).add(updated);
    }
  }

  StreamController<OnlineRoom?> _getOrCreateLocalController(String code) {
    return _localRoomControllers.putIfAbsent(
      code,
      () => StreamController<OnlineRoom?>.broadcast(),
    );
  }
}
