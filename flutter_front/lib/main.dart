import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/app_card.dart';
import 'widgets/glassmorphism/glassmorphism_container.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const ChatSaoApp());
}

class ChatSaoApp extends StatelessWidget {
  const ChatSaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatSao - IM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'login';

  void _navigateTo(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  bool get _showBottomNav =>
      _currentScreen == 'chatList' ||
      _currentScreen == 'contacts' ||
      _currentScreen == 'settings';

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(_currentScreen),
                child: _buildScreen(),
              ),
            ),
            if (_showBottomNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Center(
                  child: _buildBottomNav(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case 'login':
        return LoginScreen(
          onLogin: () => _navigateTo('chatList'),
        );
      case 'chatList':
        return ChatListScreen(
          onChatSelect: () => _navigateTo('chat'),
        );
      case 'chat':
        return ChatDetailScreen(
          onBack: () => _navigateTo('chatList'),
        );
      case 'contacts':
        return const ContactsScreen();
      case 'settings':
        return SettingsScreen(
          onLogout: () => _navigateTo('login'),
        );
      default:
        return LoginScreen(
          onLogin: () => _navigateTo('chatList'),
        );
    }
  }

  Widget _buildBottomNav() {
    return GlassmorphismContainer.bottomNav(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _navItem(Icons.chat_bubble, isActive: _currentScreen == 'chatList', onTap: () => _navigateTo('chatList')),
            const SizedBox(width: 28),
            _navItem(Icons.people_outline, isActive: _currentScreen == 'contacts', onTap: () => _navigateTo('contacts')),
            const SizedBox(width: 28),
            _navItem(Icons.settings_outlined, isActive: _currentScreen == 'settings', onTap: () => _navigateTo('settings')),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, {required bool isActive, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: Radius.circular(isActive ? 36 : 24),
            bottomLeft: Radius.circular(isActive ? 30 : 24),
            bottomRight: const Radius.circular(24),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.textLight,
          size: 26,
        ),
      ),
    );
  }
}
