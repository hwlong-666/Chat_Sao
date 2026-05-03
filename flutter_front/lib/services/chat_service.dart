import 'api_service.dart';

class ChatSessionVO {
  int friendId;
  String friendUsername;
  String? friendAvatarUrl;
  String lastMessage;
  int? lastMsgType;
  int unreadCount;
  String lastTime;

  ChatSessionVO({
    required this.friendId,
    required this.friendUsername,
    this.friendAvatarUrl,
    required this.lastMessage,
    this.lastMsgType,
    required this.unreadCount,
    required this.lastTime,
  });

  factory ChatSessionVO.fromJson(Map<String, dynamic> json) {
    return ChatSessionVO(
      friendId: json['friendId'] as int,
      friendUsername: json['friendUsername'] as String? ?? 'Unknown',
      friendAvatarUrl: json['friendAvatarUrl'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMsgType: json['lastMsgType'] as int?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastTime: json['lastTime'] as String? ?? '',
    );
  }
}

class ChatMessageVO {
  final int msgId;
  final int senderId;
  final int receiverId;
  final int chatType;
  final int msgType;
  final String content;
  final int isRead;
  final String sendTime;

  ChatMessageVO({
    required this.msgId,
    required this.senderId,
    required this.receiverId,
    required this.chatType,
    required this.msgType,
    required this.content,
    required this.isRead,
    required this.sendTime,
  });

  factory ChatMessageVO.fromJson(Map<String, dynamic> json) {
    return ChatMessageVO(
      msgId: json['msgId'] as int,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      chatType: json['chatType'] as int,
      msgType: json['msgType'] as int,
      content: json['content'] as String,
      isRead: json['isRead'] as int,
      sendTime: json['sendTime'] as String,
    );
  }
}

class ChatService {
  static Future<List<ChatSessionVO>> getChatSessions() async {
    final result = await ApiService.get('/api/chat/sessions');
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '获取会话列表失败');
    }
    final data = result['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => ChatSessionVO.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<ChatMessageVO>> getChatHistory(int friendId, {int limit = 50, int offset = 0}) async {
    final result = await ApiService.get('/api/chat/history', queryParameters: {
      'friendId': friendId,
      'limit': limit,
      'offset': offset,
    });
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '获取聊天记录失败');
    }
    final data = result['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => ChatMessageVO.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> markAsRead(int friendId) async {
    await ApiService.put('/api/chat/read', queryParameters: {'friendId': friendId});
  }
}
