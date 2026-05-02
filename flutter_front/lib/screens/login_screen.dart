import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMode { login, register }

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  AuthMode _authMode = AuthMode.login;
  late AnimationController _floatController;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '请填写用户名和密码');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_authMode == AuthMode.register) {
        await AuthService.register(username, password);
        setState(() => _errorMessage = '注册成功，请登录');
        _authMode = AuthMode.login;
      } else {
        await AuthService.login(username, password);
        widget.onLogin();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  final offsetY = _floatController.value * -10;
                  return Transform.translate(
                    offset: Offset(0, offsetY),
                    child: child,
                  );
                },
                child: Container(
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
                    size: 128,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [],
                    child: Container(
                      color: AppColors.brandPrimary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _authMode == AuthMode.login ? 'Welcome Back!' : 'Create Account',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 280,
                child: Text(
                  _authMode == AuthMode.login
                      ? 'Log in to continue your conversation with AI and friends.'
                      : 'Sign up to start chatting with AI and friends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              OrganicInput(
                prefixIcon: const Text('👤', style: TextStyle(fontSize: 18)),
                hintText: 'Username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              OrganicInput(
                prefixIcon: const Text('🔒', style: TextStyle(fontSize: 18)),
                hintText: 'Password',
                controller: _passwordController,
                obscureText: !_showPassword,
                suffixIcon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppColors.textLight,
                ),
                onSuffixTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.redBadge,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.orange200, AppColors.redPink],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9664).withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _authMode == AuthMode.login ? 'Log In' : 'Sign Up',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.15))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.15))),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _socialButton(Icons.language),
                  const SizedBox(width: 16),
                  _socialButton(Icons.apple),
                  const SizedBox(width: 16),
                  _socialButton(Icons.phone_iphone),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _authMode == AuthMode.login
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: TextStyle(color: AppColors.textLight, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _authMode = _authMode == AuthMode.login
                            ? AuthMode.register
                            : AuthMode.login;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _authMode == AuthMode.login ? 'Sign Up' : 'Log In',
                      style: TextStyle(
                        color: AppColors.orange400,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(22),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 28, color: AppColors.textPrimary.withValues(alpha: 0.7)),
      ),
    );
  }
}
