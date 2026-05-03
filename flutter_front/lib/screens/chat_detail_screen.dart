import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../services/file_upload_service.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ChatMessageItem {
  final int msgId;
  final int senderId;
  final int receiverId;
  final String content;
  final String sendTime;
  final bool isFromMe;
  final int msgType;

  ChatMessageItem({
    required this.msgId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sendTime,
    required this.isFromMe,
    this.msgType = 0,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final VoidCallback onBack;
  final int? friendId;
  final String? friendName;
  final String? friendAvatarUrl;

  const ChatDetailScreen({
    super.key,
    required this.onBack,
    this.friendId,
    this.friendName,
    this.friendAvatarUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final WebSocketService _wsService = WebSocketService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<ChatMessageItem> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _wsSubscription;
  int? _currentUserId;

  bool _isRecording = false;
  bool _isUploading = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  int? _playingMsgId;
  late AnimationController _playAnimController;

  int get _friendId => widget.friendId ?? 0;
  String get _friendName => widget.friendName ?? 'Unknown';
  String? get _friendAvatarUrl => widget.friendAvatarUrl;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.userId;
    _playAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _playingMsgId = null);
        _playAnimController.stop();
      }
    });
    _initChat();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _recordingTimer?.cancel();
    _playAnimController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    _wsService.connect();
    await Future.delayed(const Duration(milliseconds: 300));
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
              msgType: m.msgType,
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
      msgType: data['msgType'] as int? ?? 0,
    );

    final exists = _messages.any((m) => m.msgId == msg.msgId);
    if (exists) return;

    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final sent = _wsService.sendMessage({
      'receiverId': _friendId,
      'content': text,
      'msgType': 0,
    });

    if (sent) {
      _inputController.clear();
      _focusNode.requestFocus();
    }
  }

  void _sendVoiceMessage(String url) {
    _wsService.sendMessage({
      'receiverId': _friendId,
      'content': url,
      'msgType': 3,
    });
  }

  void _sendImageMessage(String url) {
    _wsService.sendMessage({
      'receiverId': _friendId,
      'content': url,
      'msgType': 2,
    });
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (xFile == null) return;

      setState(() => _isUploading = true);

      final Uint8List bytes = await xFile.readAsBytes();
      final filename = xFile.name;

      final url = await FileUploadService.uploadImage(bytes, filename: filename);
      if (url != null) {
        _sendImageMessage(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图片上传失败，请重试')),
          );
        }
      }
    } catch (e) {
      debugPrint('pickAndSendImage error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndSend();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _audioRecorder.hasPermission();
        if (!hasPermission) return;
      }

      String path;
      if (kIsWeb) {
        path = '';
      } else {
        final dir = await getTemporaryDirectory();
        path =
            '${dir.path}${Platform.pathSeparator}voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      final config = kIsWeb
          ? const RecordConfig(encoder: AudioEncoder.opus)
          : const RecordConfig(encoder: AudioEncoder.aacLc);

      await _audioRecorder.start(config, path: path);

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        }
      });
    } catch (e) {
      debugPrint('startRecording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音启动失败: $e')),
        );
      }
    }
  }

  Future<void> _stopRecordingAndSend() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isUploading = true;
      });

      if (path != null && path.isNotEmpty) {
        final url = await FileUploadService.uploadAudio(path);
        if (url != null) {
          _sendVoiceMessage(url);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('语音上传失败，请重试')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('stopRecording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音停止失败: $e')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
        _recordingDuration = Duration.zero;
      });
    }
  }

  void _cancelRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      await _audioRecorder.stop();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
    }
  }

  Future<void> _playVoice(ChatMessageItem msg) async {
    if (_playingMsgId == msg.msgId) {
      await _audioPlayer.stop();
      setState(() => _playingMsgId = null);
      _playAnimController.stop();
      return;
    }

    setState(() => _playingMsgId = msg.msgId);
    _playAnimController.repeat();
    try {
      await _audioPlayer.play(UrlSource(msg.content));
    } catch (e) {
      debugPrint('playVoice error: $e');
      if (mounted) {
        setState(() => _playingMsgId = null);
        _playAnimController.stop();
      }
    }
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
            if (_isRecording) _buildRecordingBar(),
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
                    child: _friendAvatarUrl != null && _friendAvatarUrl!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _friendAvatarUrl!,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              placeholder: (_, __) => Center(
                                child: Text(
                                  _friendName[0].toUpperCase(),
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  _friendName[0].toUpperCase(),
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        : Center(
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
          msg.msgType == 3
              ? _buildVoiceBubble(msg, isFromMe: true)
              : msg.msgType == 2
                  ? _buildImageBubble(msg, isFromMe: true)
                  : OrganicBubbleUser(
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
          child: _friendAvatarUrl != null && _friendAvatarUrl!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _friendAvatarUrl!,
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                    placeholder: (_, __) => Center(
                      child: Text(
                        _friendName[0].toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        _friendName[0].toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                )
              : Center(
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
              msg.msgType == 3
                  ? _buildVoiceBubble(msg, isFromMe: false)
                  : msg.msgType == 2
                      ? _buildImageBubble(msg, isFromMe: false)
                      : OrganicBubbleAi(
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

  Widget _buildImageBubble(ChatMessageItem msg, {required bool isFromMe}) {
    return GestureDetector(
      onTap: () => _showImagePreview(msg.content),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: Radius.circular(isFromMe ? 8 : 20),
          bottomLeft: Radius.circular(isFromMe ? 20 : 8),
          bottomRight: const Radius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
          child: CachedNetworkImage(
            imageUrl: msg.content,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 120,
              height: 120,
              color: Colors.grey[200],
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 120,
              height: 80,
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 24, color: Colors.grey),
                  SizedBox(height: 4),
                  Text('加载失败', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, _, __) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildVoiceBubble(ChatMessageItem msg, {required bool isFromMe}) {
    final isPlaying = _playingMsgId == msg.msgId;

    return GestureDetector(
      onTap: () => _playVoice(msg),
      child: isFromMe
          ? OrganicBubbleUser(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: _voiceBubbleContent(isPlaying, isFromMe),
            )
          : OrganicBubbleAi(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: _voiceBubbleContent(isPlaying, isFromMe),
            ),
    );
  }

  Widget _voiceBubbleContent(bool isPlaying, bool isFromMe) {
    final accentColor = isFromMe ? const Color(0xFF3B82F6) : const Color(0xFFE8A87C);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isFromMe) ...[
          _buildWaveform(isPlaying, accentColor),
          const SizedBox(width: 10),
        ],
        Icon(
          isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
          size: 28,
          color: accentColor,
        ),
        const SizedBox(width: 8),
        Text(
          '语音消息',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isFromMe) ...[
          const SizedBox(width: 10),
          _buildWaveform(isPlaying, accentColor),
        ],
      ],
    );
  }

  Widget _buildWaveform(bool isPlaying, Color color) {
    return SizedBox(
      width: 60,
      height: 24,
      child: AnimatedBuilder(
        animation: _playAnimController,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaveformPainter(
              animationValue: isPlaying ? _playAnimController.value : 0,
              color: color,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B6B).withValues(alpha: 0.15),
            const Color(0xFFEE5A5A).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(24),
        ),
        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B6B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '录音中',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(_recordingDuration),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _cancelRecording,
            child: const Icon(Icons.close, size: 18, color: AppColors.textLight),
          ),
        ],
      ),
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
                      GestureDetector(
                        onTap: _pickAndSendImage,
                        child: _inputAction(Icons.image, size: 20, color: AppColors.brandPrimary),
                      ),
                      const SizedBox(width: 16),
                      _inputAction(Icons.auto_awesome, size: 18, color: AppColors.orange200),
                      const SizedBox(width: 16),
                      _buildMicButton(),
                    ],
                  ),
                  _isUploading
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPrimary),
                            ),
                          ),
                        )
                      : GestureDetector(
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

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AvatarBlob(
        size: 36,
        backgroundColor: _isRecording
            ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
            : AppColors.brandPrimary.withValues(alpha: 0.1),
        border: Border.all(
          color: _isRecording
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.4)
              : AppColors.brandPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: _isRecording
            ? [BoxShadow(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
            : const [],
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          size: 16,
          color: _isRecording ? const Color(0xFFFF6B6B) : AppColors.brandPrimary,
        ),
      ),
    );
  }

  Widget _inputAction(IconData icon, {double size = 20, Color? color}) {
    return Icon(icon, size: size, color: color ?? AppColors.textLight);
  }
}

class _WaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _WaveformPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    final barCount = 8;
    final barWidth = 3.0;
    final gap = (size.width - barCount * barWidth) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + gap);

      double baseHeight;
      if (animationValue > 0) {
        final phase = (animationValue * barCount + i) % barCount;
        final wave = (phase / barCount);
        baseHeight = 4 + wave * (size.height - 6);
      } else {
        baseHeight = 4 + (i % 3 == 0 ? 8 : i % 2 == 0 ? 5 : 3).toDouble();
      }

      final y = (size.height - baseHeight) / 2;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, baseHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
