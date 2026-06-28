class ChatMessageSentEvent {
  ChatMessageSentEvent({
    required this.id,
    required this.chatRoomId,
    required this.userId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.user,
  });

  factory ChatMessageSentEvent.fromJson(Map<String, dynamic> json) {
    return ChatMessageSentEvent(
      id: _toInt(json['id']),
      chatRoomId: _toInt(json['chat_room_id']),
      userId: _toInt(json['user_id']),
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      user: ChatMessageUser.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  final int id;
  final int chatRoomId;
  final int userId;
  final String message;
  final bool isRead;
  final String createdAt;
  final ChatMessageUser user;
}

class ChatMessageUser {
  ChatMessageUser({
    required this.id,
    required this.name,
    required this.profilePhoto,
  });

  factory ChatMessageUser.fromJson(Map<String, dynamic> json) {
    return ChatMessageUser(
      id: _toInt(json['id']),
      name: json['name'] as String? ?? '',
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  final int id;
  final String name;
  final String? profilePhoto;
}

class ChatMessageReadEvent {
  ChatMessageReadEvent({
    required this.chatRoomId,
    required this.messageIds,
    required this.readerId,
  });

  factory ChatMessageReadEvent.fromJson(Map<String, dynamic> json) {
    final dynamic messageIdsRaw = json['message_ids'];
    final List<int> ids = messageIdsRaw is List
        ? messageIdsRaw.map((dynamic item) => _toInt(item)).toList()
        : const <int>[];
    return ChatMessageReadEvent(
      chatRoomId: _toInt(json['chat_room_id']),
      messageIds: ids,
      readerId: _toInt(json['reader_id']),
    );
  }

  final int chatRoomId;
  final List<int> messageIds;
  final int readerId;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}
