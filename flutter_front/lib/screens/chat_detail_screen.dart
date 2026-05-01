import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ChatDetailScreen extends StatelessWidget {
  final VoidCallback onBack;
  final User? peer;
  final List<Message>? messages;

  const ChatDetailScreen({
    super.key,
    required this.onBack,
    this.peer,
    this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final chatPeer = peer ?? User.smith;
    final chatMessages = messages ?? Message.sampleThread1();
    return Container(
      color: AppColors.creamBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(chatPeer),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                itemCount: chatMessages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Center(
                          child: Text(
                            'TODAY, 9:40 AM',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  final msg = chatMessages[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMessageBubble(msg, chatPeer),
                  );
                },
              ),
            ),
            _buildMessageInput(chatPeer),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, User chatPeer) {
    switch (msg.type) {
      case MessageType.text:
        return msg.isFromMe
            ? _buildSentTextMessage(msg)
            : _buildReceivedTextMessage(msg, chatPeer);
      case MessageType.voice:
        return _buildVoiceMessage(msg);
      case MessageType.aiConcept:
        return _buildAiConceptCard(msg);
    }
  }

  Widget _buildHeader(User chatPeer) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: AvatarBlob(
              size: 48,
              backgroundColor: Colors.white,
              border: Border.all(color: Colors.white, width: 0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
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
                    backgroundColor: chatPeer.avatarColor.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [],
                    child: Center(
                      child: Icon(chatPeer.avatarIcon, color: chatPeer.avatarColor, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    chatPeer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
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
                      color: chatPeer.isOnline ? AppColors.onlineGreen : AppColors.textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    chatPeer.isOnline ? 'ACTIVE' : 'OFFLINE',
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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            child: const Icon(Icons.more_horiz, size: 18, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedTextMessage(Message msg, User chatPeer) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarBlob(
          size: 36,
          backgroundColor: chatPeer.avatarColor.withValues(alpha: 0.2),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          child: Center(
            child: Icon(chatPeer.avatarIcon, color: chatPeer.avatarColor, size: 14),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: OrganicBubbleAi(
            padding: const EdgeInsets.all(16),
            child: Text(
              msg.text ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentTextMessage(Message msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: OrganicBubbleUser(
        padding: const EdgeInsets.all(16),
        child: Text(
          msg.text ?? '',
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(Message msg) {
    final heights = msg.waveformHeights ?? [3, 5, 2, 6, 4, 7, 5, 8, 4, 6, 3, 5, 4, 6];
    final playedCount = msg.waveformPlayedCount ?? 0;
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 240),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.aiBubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(26),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildWaveform(heights, playedCount),
                const SizedBox(width: 12),
                Text(
                  msg.voiceDuration ?? '0:00',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AvatarBlob(
            size: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.orange200),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(List<int> heights, int playedCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.asMap().entries.map((entry) {
        final isPlayed = entry.key < playedCount;
        return Container(
          width: 2,
          height: entry.value * 3.6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isPlayed
                ? AppColors.orange200.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAiConceptCard(Message msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.aiBubbleBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(36),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(22),
                      ),
                      color: const Color(0xFF161822),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.home_outlined,
                        size: 48,
                        color: AppColors.orange200.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.conceptTitle ?? 'AI CONCEPT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange200Text,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            msg.conceptDescription ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            'SEEN 9:41 AM',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(User chatPeer) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: GlassmorphismContainer.messageInput(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Talk to ${chatPeer.name}...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
                  Row(
                    children: [
                      AvatarBlob(
                        size: 48,
                        backgroundColor: Colors.white,
                        border: Border.all(color: Colors.white, width: 0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        child: const Icon(Icons.mic, size: 20, color: AppColors.textLight),
                      ),
                      const SizedBox(width: 8),
                      AvatarBlob(
                        size: 48,
                        backgroundColor: AppColors.brandPrimary,
                        border: Border.all(color: AppColors.brandPrimary, width: 0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        child: const Icon(
                          Icons.chat_bubble,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
