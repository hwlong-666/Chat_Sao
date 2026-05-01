import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ContactsScreen extends StatelessWidget {
  final VoidCallback? onNavigateBack;

  const ContactsScreen({super.key, this.onNavigateBack});

  static const _contacts = [
    User.alex,
    User.chloe,
    User.david,
    User.sarah,
    User.aiAssistant,
  ];

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
                const Text(
                  'Contacts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
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
                  child: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final offsetX = index.isEven ? -4.0 : 4.0;
                return Padding(
                  padding: EdgeInsets.only(
                    left: offsetX > 0 ? offsetX : 0,
                    right: offsetX < 0 ? offsetX.abs() : 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassmorphismContainer.glass(
                      borderRadius: 32,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AvatarBlob(
                                size: 56,
                                backgroundColor: contact.avatarColor.withValues(alpha: 0.15),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                child: Center(
                                  child: Icon(
                                    contact.avatarIcon,
                                    color: contact.avatarColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                              if (contact.isOnline)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4ADE80),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
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
                                  children: [
                                    Text(
                                      contact.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (contact.isAi) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.auto_awesome,
                                        size: 12,
                                        color: Color(0xFFF97316),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  contact.statusText ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40 * 0.4),
                                topRight: Radius.circular(40 * 0.6),
                                bottomLeft: Radius.circular(40 * 0.55),
                                bottomRight: Radius.circular(40 * 0.45),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 14,
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
        ],
      ),
    );
  }
}
