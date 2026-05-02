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
import 'services/auth_service.dart';
import 'services/friend_service.dart';
import 'services/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
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
  String? _currentScreen;
  bool _isCheckingAuth = true;
  int? _chatFriendId;
  String? _chatFriendName;
  final GlobalKey<ChatListScreenState> _chatListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _currentScreen = AuthService.isLoggedIn ? 'chatList' : 'login';
      _isCheckingAuth = false;
    });
    if (AuthService.isLoggedIn) {
      WebSocketService().connect();
    }
  }

  void _navigateTo(String screen, {int? friendId, String? friendName}) {
    setState(() {
      _currentScreen = screen;
      if (friendId != null) {
        _chatFriendId = friendId;
        _chatFriendName = friendName;
      }
    });
    if (screen == 'chatList') {
      _chatListKey.currentState?.loadSessions();
    }
  }

  void _handleLogin() {
    WebSocketService().connect();
    _navigateTo('chatList');
  }

  Future<void> _handleLogout() async {
    WebSocketService().disconnect();
    await AuthService.logout();
    _navigateTo('login');
  }

  bool get _showBottomNav =>
      _currentScreen == 'chatList' ||
      _currentScreen == 'contacts' ||
      _currentScreen == 'settings';

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth || _currentScreen == null) {
      return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFEBB4),
                        Color(0xFFFFBEBE),
                        Color(0xFFA0D2FF),
                      ],
                    ),
                  ),
                  child: AvatarBlob(
                    size: 80,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [],
                    child: Container(
                      color: AppColors.brandPrimary.withValues(alpha: 0.1),
                      child: const Icon(Icons.auto_awesome, size: 32, color: AppColors.brandPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('ChatSao', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange200),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        return LoginScreen(onLogin: _handleLogin);
      case 'chatList':
        return ChatListScreen(key: _chatListKey, onChatSelect: (friendId, friendName) => _navigateTo('chat', friendId: friendId, friendName: friendName));
      case 'chat':
        return ChatDetailScreen(onBack: () => _navigateTo('chatList'), friendId: _chatFriendId, friendName: _chatFriendName);
      case 'contacts':
        return const ContactsScreen();
      case 'settings':
        return SettingsScreen(onLogout: _handleLogout);
      default:
        return LoginScreen(onLogin: _handleLogin);
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
        child: Icon(icon, color: isActive ? Colors.white : AppColors.textLight, size: 26),
      ),
    );
  }
}
