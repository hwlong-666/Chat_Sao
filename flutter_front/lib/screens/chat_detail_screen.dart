import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ChatMessageItem {
  final int msgId;
  final int senderId;
  final int receiverId;
  final String content;
  final String sendTime;
  final bool isFromMe;

  ChatMessageItem({
    required this.msgId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sendTime,
    required this.isFromMe,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final VoidCallback onBack;
  final int? friendId;
  final String? friendName;

  const ChatDetailScreen({
    super.key,
    required this.onBack,
    this.friendId,
    this.friendName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final WebSocketService _wsService = WebSocketService();

  List<ChatMessageItem> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _wsSubscription;
  int? _currentUserId;

  int get _friendId => widget.friendId ?? 0;
  String get _friendName => widget.friendName ?? 'Unknown';

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.userId;
    _initChat();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    if (!_wsService.isConnected) {
      _wsService.connect();
    }

    _wsSubscription = _wsService.messageStream.listen(_onMessageReceived);

    try {
      await ChatService.markAsRead(_friendId);
    } catch (_) {}

    try {
      final history = await ChatService.getChatHistory(_friendId);
      setState(() {
        _messages = history.map((m) => ChatMessageItem(
              msgId: m.msgId,
              senderId: m.senderId,
              receiverId: m.receiverId,
              content: m.content,
              sendTime: m.sendTime,
              isFromMe: m.senderId == _currentUserId,
            )).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    final senderId = data['senderId'] as int?;
    final receiverId = data['receiverId'] as int?;
    if (senderId == null || receiverId == null) return;

    final isRelevant = (senderId == _friendId && receiverId == _currentUserId) ||
        (senderId == _currentUserId && receiverId == _friendId);
    if (!isRelevant) return;

    final msg = ChatMessageItem(
      msgId: data['msgId'] as int,
      senderId: senderId,
      receiverId: receiverId,
      content: data['content'] as String,
      sendTime: data['sendTime'] as String,
      isFromMe: senderId == _currentUserId,
    );

    final exists = _messages.any((m) => m.msgId == msg.msgId);
    if (exists) return;

    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _wsService.sendMessage({
      'receiverId': _friendId,
      'content': text,
    });

    _inputController.clear();
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFF8B5CF6), Color(0xFF3B82F6), Color(0xFFEC4899),
      Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFFEF4444), Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }

  String _formatTime(String timeStr) {
    try {
      final dt = DateTime.parse(timeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.creamBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _isLoading ? _buildLoading() : _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary));
  }

  Widget _buildHeader() {
    final color = _avatarColor(_friendId.hashCode.abs());
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: AvatarBlob(
              size: 48,
              backgroundColor: Colors.white,
              border: Border.all(color: Colors.white, width: 0),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
              ],
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  AvatarBlob(
                    size: 40,
                    backgroundColor: color.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [],
                    child: Center(
                      child: Text(
                        _friendName[0].toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _friendName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _wsService.isConnected ? AppColors.onlineGreen : AppColors.textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _wsService.isConnected ? 'CONNECTED' : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AvatarBlob(
            size: 48,
            backgroundColor: Colors.white,
            border: Border.all(color: Colors.white, width: 0),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
            ],
            child: const Icon(Icons.more_horiz, size: 18, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_outlined, size: 48, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('开始和 $_friendName 聊天吧', style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: msg.isFromMe ? _buildSentMessage(msg) : _buildReceivedMessage(msg),
        );
      },
    );
  }

  Widget _buildSentMessage(ChatMessageItem msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          OrganicBubbleUser(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              msg.content,
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(msg.sendTime),
            style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(ChatMessageItem msg) {
    final color = _avatarColor(_friendId.hashCode.abs());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarBlob(
          size: 36,
          backgroundColor: color.withValues(alpha: 0.2),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
          child: Center(
            child: Text(
              _friendName[0].toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrganicBubbleAi(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  msg.content,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(msg.sendTime),
                style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: GlassmorphismContainer.messageInput(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Talk to $_friendName...',
                  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _inputAction(Icons.add, color: AppColors.textLight),
                      const SizedBox(width: 16),
                      _inputAction(Icons.attach_file, size: 18, color: AppColors.textLight),
                      const SizedBox(width: 16),
                      _inputAction(Icons.auto_awesome, size: 18, color: AppColors.orange200),
                    ],
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AvatarBlob(
                      size: 48,
                      backgroundColor: AppColors.brandPrimary,
                      border: Border.all(color: AppColors.brandPrimary, width: 0),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                      child: const Icon(Icons.send, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputAction(IconData icon, {double size = 20, Color? color}) {
    return Icon(icon, size: size, color: color ?? AppColors.textLight);
  }
}
