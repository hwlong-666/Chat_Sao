import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onLogout;

  const SettingsScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSettingsItems(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = User.currentUser;
    return Column(
      children: [
        SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFEBB4),
                      Color(0xFFFFBEBE),
                      Color(0xFFA0D2FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange200.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AvatarBlob(
                  size: 120,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [],
                  child: Container(
                    color: user.avatarColor.withValues(alpha: 0.1),
                    child: Icon(
                      user.avatarIcon,
                      size: 48,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFDF8F0),
                      width: 4,
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
                    Icons.edit,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.handle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItems() {
    final items = [
      _SettingItem(icon: Icons.person_outline, label: 'Profile Information'),
      _SettingItem(icon: Icons.chat_bubble_outline, label: 'Chat Wallpapers'),
      _SettingItem(icon: Icons.auto_awesome, label: 'AI Preferences'),
      _SettingItem(icon: Icons.security_outlined, label: 'Privacy & Security'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassmorphismContainer.glass(
              borderRadius: 28,
              padding: const EdgeInsets.all(16),
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40 * 0.4),
                        topRight: Radius.circular(40 * 0.6),
                        bottomLeft: Radius.circular(40 * 0.55),
                        bottomRight: Radius.circular(40 * 0.45),
                      ),
                    ),
                    child: Icon(item.icon, size: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFFD1D5DB),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onLogout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: const Center(
            child: Text(
              'Logout Session',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;

  const _SettingItem({required this.icon, required this.label});
}
