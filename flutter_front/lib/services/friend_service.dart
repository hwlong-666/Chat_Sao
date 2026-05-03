import 'api_service.dart';

class FriendInfo {
  final int userId;
  final String username;
  final String? avatarUrl;

  FriendInfo({required this.userId, required this.username, this.avatarUrl});

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      userId: json['userId'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class FriendService {
  static Future<List<FriendInfo>> getFriendList() async {
    final result = await ApiService.get('/api/friend/list');
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '获取好友列表失败');
    }
    final data = result['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => FriendInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<FriendInfo>> searchUser(String username) async {
    final result = await ApiService.get('/api/friend/search', queryParameters: {'username': username});
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '搜索用户失败');
    }
    final data = result['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => FriendInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> addFriend(int friendId) async {
    final result = await ApiService.post('/api/friend/add', data: {'friendId': friendId});
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '添加好友失败');
    }
  }

  static Future<List<FriendInfo>> getFriendRequests() async {
    final result = await ApiService.get('/api/friend/requests');
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '获取好友请求失败');
    }
    final data = result['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => FriendInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> acceptFriend(int requesterId) async {
    final result = await ApiService.post('/api/friend/accept', data: {'friendId': requesterId});
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '接受好友请求失败');
    }
  }

  static Future<void> rejectFriend(int requesterId) async {
    final result = await ApiService.post('/api/friend/reject', data: {'friendId': requesterId});
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '拒绝好友请求失败');
    }
  }

  static Future<void> removeFriend(int friendId) async {
    final result = await ApiService.delete('/api/friend/remove', queryParameters: {'friendId': friendId});
    final code = result['code'] as int?;
    if (code != 200) {
      throw ApiException(result['message'] ?? '删除好友失败');
    }
  }
}
