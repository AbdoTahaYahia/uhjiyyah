class OnlinePlayer {
  final String id;
  final String name;
  final bool isHost;
  final bool isReady;
  final String? assignedRole;
  final Map<String, dynamic> metadata;

  const OnlinePlayer({
    required this.id,
    required this.name,
    this.isHost = false,
    this.isReady = false,
    this.assignedRole,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isHost': isHost,
      'isReady': isReady,
      'assignedRole': assignedRole,
      'metadata': metadata,
    };
  }

  factory OnlinePlayer.fromMap(Map<String, dynamic> map) {
    return OnlinePlayer(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'لاعب',
      isHost: map['isHost'] as bool? ?? false,
      isReady: map['isReady'] as bool? ?? false,
      assignedRole: map['assignedRole'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  OnlinePlayer copyWith({
    String? id,
    String? name,
    bool? isHost,
    bool? isReady,
    String? assignedRole,
    Map<String, dynamic>? metadata,
  }) {
    return OnlinePlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      assignedRole: assignedRole ?? this.assignedRole,
      metadata: metadata ?? this.metadata,
    );
  }
}

class RoomChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final int timestamp; // epoch millis

  const RoomChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory RoomChatMessage.fromMap(Map<String, dynamic> map) {
    return RoomChatMessage(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'لاعب',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class OnlineRoom {
  final String code;
  final String hostId;
  final String gameModeId;
  final String status; // 'waiting', 'in_game', 'finished'
  final List<OnlinePlayer> players;
  final List<RoomChatMessage> messages;
  final Map<String, dynamic> gameState;

  const OnlineRoom({
    required this.code,
    required this.hostId,
    this.gameModeId = 'mafia',
    this.status = 'waiting',
    this.players = const [],
    this.messages = const [],
    this.gameState = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'hostId': hostId,
      'gameModeId': gameModeId,
      'status': status,
      'players': players.map((p) => p.toMap()).toList(),
      'messages': messages.map((m) => m.toMap()).toList(),
      'gameState': gameState,
    };
  }

  factory OnlineRoom.fromMap(Map<String, dynamic> map) {
    return OnlineRoom(
      code: map['code'] as String? ?? '',
      hostId: map['hostId'] as String? ?? '',
      gameModeId: map['gameModeId'] as String? ?? 'mafia',
      status: map['status'] as String? ?? 'waiting',
      players: (map['players'] as List<dynamic>? ?? [])
          .map((item) => OnlinePlayer.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      messages: (map['messages'] as List<dynamic>? ?? [])
          .map((item) => RoomChatMessage.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      gameState: Map<String, dynamic>.from(map['gameState'] as Map? ?? {}),
    );
  }

  OnlineRoom copyWith({
    String? code,
    String? hostId,
    String? gameModeId,
    String? status,
    List<OnlinePlayer>? players,
    List<RoomChatMessage>? messages,
    Map<String, dynamic>? gameState,
  }) {
    return OnlineRoom(
      code: code ?? this.code,
      hostId: hostId ?? this.hostId,
      gameModeId: gameModeId ?? this.gameModeId,
      status: status ?? this.status,
      players: players ?? this.players,
      messages: messages ?? this.messages,
      gameState: gameState ?? this.gameState,
    );
  }
}
