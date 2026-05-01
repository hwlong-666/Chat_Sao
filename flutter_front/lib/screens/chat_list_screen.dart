import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/chat_thread.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ChatListScreen extends StatelessWidget {
  final VoidCallback onChatSelect;

  const ChatListScreen({super.key, required this.onChatSelect});

  @override
  Widget build(BuildContext context) {
    final threads = ChatThread.sampleThreads;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AvatarBlob(
                  size: 44,
                  backgroundColor: AppColors.brandPrimary,
                  border: Border.all(color: AppColors.brandPrimary, width: 0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
                AvatarBlob(
                  size: 44,
                  backgroundColor: Colors.white,
                  border: Border.all(color: Colors.white, width: 0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  child: const Icon(Icons.edit_outlined, color: AppColors.brandPrimary, size: 18),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: OrganicInput(
              prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textLight),
              hintText: 'Search messages...',
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                final peer = thread.peer;
                final offsetX = index.isEven ? -4.0 : 4.0;
                return Padding(
                  padding: EdgeInsets.only(left: offsetX > 0 ? offsetX : 0, right: offsetX < 0 ? offsetX.abs() : 0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: onChatSelect,
                      child: GlassmorphismContainer.glass(
                        borderRadius: 32,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AvatarBlob(
                                  size: 64,
                                  backgroundColor: peer.avatarColor.withValues(alpha: 0.2),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  child: Center(
                                    child: Icon(peer.avatarIcon, color: peer.avatarColor, size: 28),
                                  ),
                                ),
                                if (peer.isAi)
                                  Positioned(
                                    right: -4,
                                    bottom: -4,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.brandPrimary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
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
                                            peer.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (peer.verified) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDBEAFE),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                size: 10,
                                                color: Color(0xFF3B82F6),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        thread.timeLabel,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textLight,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          thread.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                      if (thread.unreadCount > 0)
                                        LiquidBadge(count: thread.unreadCount),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
