import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const SettingsScreen({super.key, this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final username = AuthService.username ?? 'User';
    final avatarUrl = AuthService.avatarUrl;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildProfileHeader(username, avatarUrl),
            const SizedBox(height: 24),
            _buildSettingsItems(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String username, String? avatarUrl) {
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
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            placeholder: (_, __) => Container(
                              color: AppColors.brandPrimary.withValues(alpha: 0.1),
                              child: const Icon(Icons.person, size: 48, color: AppColors.brandPrimary),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.brandPrimary.withValues(alpha: 0.1),
                              child: const Icon(Icons.person, size: 48, color: AppColors.brandPrimary),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.brandPrimary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, size: 48, color: AppColors.brandPrimary),
                        ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: GestureDetector(
                  onTap: _isUploading ? null : _showEditProfileDialog,
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
                    child: _isUploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${AuthService.userId ?? ""}',
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
      _SettingItem(icon: Icons.person_outline, label: 'Profile Information', onTap: _showEditProfileDialog),
      _SettingItem(icon: Icons.chat_bubble_outline, label: 'Chat Wallpapers', onTap: () {}),
      _SettingItem(icon: Icons.auto_awesome, label: 'AI Preferences', onTap: () {}),
      _SettingItem(icon: Icons.security_outlined, label: 'Privacy & Security', onTap: () {}),
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
              onTap: item.onTap,
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
        onTap: widget.onLogout,
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

  Future<void> _showEditProfileDialog() async {
    final usernameController = TextEditingController(text: AuthService.username ?? '');

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Profile',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 380,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF8F0), Color(0xFFF0F4FF)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.brandPrimary.withValues(alpha: 0.1), AppColors.orange200.withValues(alpha: 0.1)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.orange200, AppColors.redPink]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '编辑资料',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.pop(ctx),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: AppColors.textLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final url = await _pickAndUploadAvatar();
                                  if (url != null) {
                                    setDialogState(() {});
                                    if (mounted) setState(() {});
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFEBB4), Color(0xFFFFBEBE), Color(0xFFA0D2FF)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: AuthService.avatarUrl != null && AuthService.avatarUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: AuthService.avatarUrl!,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt, size: 28, color: AppColors.brandPrimary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '点击更换头像',
                                style: TextStyle(fontSize: 12, color: AppColors.textLight),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.15)),
                                ),
                                child: TextField(
                                  controller: usernameController,
                                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: '输入新昵称',
                                    hintStyle: TextStyle(fontSize: 15, color: AppColors.textLight.withValues(alpha: 0.5)),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    prefixIcon: Icon(Icons.person, size: 20, color: AppColors.brandPrimary.withValues(alpha: 0.6)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () async {
                                  final newUsername = usernameController.text.trim();
                                  if (newUsername.isEmpty) return;

                                  try {
                                    await AuthService.updateProfile(username: newUsername);
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                    if (mounted) setState(() {});
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('资料更新成功'),
                                          backgroundColor: AppColors.brandPrimary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: AppColors.redBadge,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppColors.brandPrimary, Color(0xFF6366F1)]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.brandPrimary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '保存',
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
    usernameController.dispose();
  }

  Future<String?> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (xFile == null) return null;

      setState(() => _isUploading = true);

      final Uint8List bytes = await xFile.readAsBytes();
      final url = await AuthService.uploadAvatar(bytes, filename: xFile.name);

      if (mounted) {
        setState(() => _isUploading = false);
        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('头像更新成功'),
              backgroundColor: AppColors.brandPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('头像上传失败'),
              backgroundColor: AppColors.redBadge,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return url;
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
      }
      return null;
    }
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingItem({required this.icon, required this.label, required this.onTap});
}
