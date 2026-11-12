import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/online_room.dart';
import '../services/online_room_service.dart';

class OnlineRoomState {
  final OnlineRoom? room;
  final String? myPlayerId;
  final String? myPlayerName;
  final bool isLoading;
  final String? errorMessage;

  const OnlineRoomState({
    this.room,
    this.myPlayerId,
    this.myPlayerName,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isHost =>
      room != null && myPlayerId != null && room!.hostId == myPlayerId;

  OnlineRoomState copyWith({
    OnlineRoom? room,
    String? myPlayerId,
    String? myPlayerName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnlineRoomState(
      room: room ?? this.room,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      myPlayerName: myPlayerName ?? this.myPlayerName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class OnlineRoomNotifier extends Notifier<OnlineRoomState> {
  final _service = OnlineRoomService();
  StreamSubscription<OnlineRoom?>? _roomSubscription;

  @override
  OnlineRoomState build() {
    ref.onDispose(() {
      _roomSubscription?.cancel();
    });
    return const OnlineRoomState();
  }

  Future<bool> createRoom({
    required String hostName,
    required String hostId,
    String gameModeId = 'mafia',
  }) async {
    _roomSubscription?.cancel();
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final room = await _service.createRoom(
        hostName: hostName,
        hostId: hostId,
        gameModeId: gameModeId,
      );

      state = OnlineRoomState(
        room: room,
        myPlayerId: hostId,
        myPlayerName: hostName,
        isLoading: false,
      );

      _listenToRoom(room.code);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر إنشاء الغرفة. يرجى المحاولة مرة أخرى.',
      );
      return false;
    }
  }

  Future<bool> joinRoom({
    required String code,
    required String playerName,
    required String playerId,
  }) async {
    _roomSubscription?.cancel();
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final room = await _service.joinRoom(
        code: code,
        playerName: playerName,
        playerId: playerId,
      );

      if (room == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'رمز الغرفة غير صحيح أو اللعبة قد بدأت بالفعل.',
        );
        return false;
      }

      state = OnlineRoomState(
        room: room,
        myPlayerId: playerId,
        myPlayerName: playerName,
        isLoading: false,
      );

      _listenToRoom(room.code);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء الانضمام للغرفة.',
      );
      return false;
    }
  }

  void _listenToRoom(String code) {
    _roomSubscription?.cancel();
    _roomSubscription = _service.streamRoom(code).listen((updatedRoom) {
      if (updatedRoom == null) {
        state = state.copyWith(
          room: null,
          errorMessage: 'تم إغلاق الغرفة من قبل المضيف.',
        );
      } else {
        state = state.copyWith(room: updatedRoom);
      }
    });
  }

  Future<void> changeGameMode(String gameModeId) async {
    final room = state.room;
    if (room == null || !state.isHost) return;
    await _service.updateGameMode(room.code, gameModeId);
  }

  Future<void> toggleReady() async {
    final room = state.room;
    final myId = state.myPlayerId;
    if (room == null || myId == null) return;

    final me = room.players.firstWhere((p) => p.id == myId);
    await _service.setPlayerReady(room.code, myId, !me.isReady);
  }

  Future<void> startGame() async {
    final room = state.room;
    if (room == null || !state.isHost) return;
    await _service.startGame(room.code, {
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> leaveRoom() async {
    final room = state.room;
    final myId = state.myPlayerId;
    _roomSubscription?.cancel();

    if (room != null && myId != null) {
      await _service.leaveRoom(room.code, myId);
    }
    state = const OnlineRoomState();
  }
}

final onlineRoomProvider =
    NotifierProvider<OnlineRoomNotifier, OnlineRoomState>(() {
  return OnlineRoomNotifier();
});
