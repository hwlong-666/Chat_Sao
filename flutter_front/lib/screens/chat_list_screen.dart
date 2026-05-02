import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ChatListScreen extends StatefulWidget {
  final Function(int friendId, String friendName) onChatSelect;

  const ChatListScreen({super.key, required this.onChatSelect});

  @override
  State<ChatListScreen> createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  List<ChatSessionVO> _sessions = [];
  List<ChatSessionVO> _filteredSessions = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _wsSubscription;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.userId;
    loadSessions();
    _searchController.addListener(_onSearchChanged);
    _wsSubscription = WebSocketService().messageStream.listen(_onWsMessage);
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onWsMessage(Map<String, dynamic> data) {
    final senderId = data['senderId'] as int?;
    final receiverId = data['receiverId'] as int?;
    final content = data['content'] as String?;
    final sendTime = data['sendTime'] as String?;
    if (senderId == null || receiverId == null) return;

    final isFromMe = senderId == _currentUserId;
    final otherId = isFromMe ? receiverId : senderId;

    setState(() {
      final idx = _sessions.indexWhere((s) => s.friendId == otherId);
      if (idx != -1) {
        final session = _sessions[idx];
        session.lastMessage = content ?? '';
        session.lastTime = sendTime ?? '';
        if (!isFromMe) {
          session.unreadCount += 1;
        }
        _sessions.removeAt(idx);
        _sessions.insert(0, session);
      }
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredSessions = List.from(_sessions);
    } else {
      _filteredSessions = _sessions.where((s) => s.friendUsername.toLowerCase().contains(query)).toList();
    }
  }

  void _onSearchChanged() {
    setState(() => _applyFilter());
  }

  Future<void> loadSessions() async {
    try {
      final sessions = await ChatService.getChatSessions();
      setState(() {
        _sessions = sessions;
        _filteredSessions = List.from(sessions);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onChatTap(int friendId, String friendName) async {
    final idx = _sessions.indexWhere((s) => s.friendId == friendId);
    if (idx != -1) {
      setState(() {
        _sessions[idx].unreadCount = 0;
        _applyFilter();
      });
    }

    try {
      await ChatService.markAsRead(friendId);
    } catch (_) {}

    widget.onChatSelect(friendId, friendName);
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFF8B5CF6), Color(0xFFF59E0B), Color(0xFF3B82F6),
      Color(0xFFEC4899), Color(0xFF10B981), Color(0xFFEF4444), Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }

  IconData _avatarIcon(int index) {
    const icons = [
      Icons.person, Icons.palette, Icons.auto_awesome,
      Icons.smart_toy, Icons.woman, Icons.groups, Icons.favorite,
    ];
    return icons[index % icons.length];
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      }
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AvatarBlob(
                  size: 48,
                  backgroundColor: Colors.black87,
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.textPrimary),
                ),
                AvatarBlob(
                  size: 48,
                  backgroundColor: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                  child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GlassmorphismContainer.glass(
              borderRadius: 32,
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(fontSize: 14.5, color: AppColors.textLight),
                  prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
                : _filteredSessions.isEmpty && _sessions.isNotEmpty
                    ? Center(child: Text('No results found', style: TextStyle(color: AppColors.textLight)))
                    : _sessions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textLight),
                                const SizedBox(height: 16),
                                Text('暂无消息', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadSessions,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                              itemCount: _filteredSessions.length,
                              itemBuilder: (context, index) {
                                final session = _filteredSessions[index];
                                final originalIndex = _sessions.indexOf(session);
                                final color = _avatarColor(originalIndex);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => _onChatTap(session.friendId, session.friendUsername),
                                    child: GlassmorphismContainer.glass(
                                      borderRadius: 28,
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              AvatarBlob(
                                                size: 56,
                                                backgroundColor: color.withValues(alpha: 0.18),
                                                border: Border.all(color: Colors.white, width: 2),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 3)),
                                                ],
                                                child: Icon(_avatarIcon(originalIndex), color: color, size: 26),
                                              ),
                                              Positioned(
                                                bottom: -2,
                                                right: -2,
                                                child: Container(
                                                  width: 18,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black87,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                                                  ),
                                                  child: Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          session.friendUsername,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Icon(Icons.verified, size: 16, color: Colors.blue.shade300),
                                                      ],
                                                    ),
                                                    Text(
                                                      _formatTime(session.lastTime),
                                                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        session.lastMessage.isNotEmpty ? session.lastMessage : '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.75)),
                                                      ),
                                                    ),
                                                    if (session.unreadCount > 0) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFFF5252),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${session.unreadCount}',
                                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
