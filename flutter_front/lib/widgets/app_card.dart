import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5E6),
            Color(0xFFFFEEE6),
            Color(0xFFF5EEFF),
            Color(0xFFE6F3FF),
          ],
          stops: [0.0, 0.33, 0.66, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _buildCornerGlow()),
          child,
        ],
      ),
    );
  }

  Widget _buildCornerGlow() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _glowCircle(200, const Color(0x30FFEBB4)),
        ),
        Positioned(
          top: -100,
          right: -100,
          child: _glowCircle(200, const Color(0x25FFBEBE)),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _glowCircle(200, const Color(0x25A0D2FF)),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: _glowCircle(200, const Color(0x25FFAADC)),
        ),
      ],
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class AvatarBlob extends StatelessWidget {
  final double size;
  final Widget? child;
  final Color backgroundColor;
  final BoxBorder border;
  final List<BoxShadow> boxShadow;

  const AvatarBlob({
    super.key,
    required this.size,
    this.child,
    this.backgroundColor = Colors.white,
    this.border = const Border.fromBorderSide(BorderSide.none),
    this.boxShadow = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.4),
          topRight: Radius.circular(size * 0.6),
          bottomLeft: Radius.circular(size * 0.55),
          bottomRight: Radius.circular(size * 0.45),
        ),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Center(child: child),
    );
  }
}

class OrganicBubbleAi extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const OrganicBubbleAi({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF5EB).withValues(alpha: 0.95),
            const Color(0xFFFEE8D6).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(24),
          topRight: const Radius.circular(32),
          bottomLeft: const Radius.circular(28),
          bottomRight: const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A87C).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OrganicBubbleUser extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const OrganicBubbleUser({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFDBEAFE).withValues(alpha: 0.95),
            const Color(0xFFBFDBFE).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(30),
          bottomLeft: const Radius.circular(22),
          bottomRight: const Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LiquidBadge extends StatelessWidget {
  final int count;

  const LiquidBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class OrganicInput extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;

  const OrganicInput({
    super.key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  State<OrganicInput> createState() => _OrganicInputState();
}

class _OrganicInputState extends State<OrganicInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          border: Border.all(
            color: _isFocused ? AppColors.brandPrimary : Colors.white.withValues(alpha: 0.6),
            width: 1.5,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(30),
            topRight: const Radius.circular(22),
            bottomLeft: const Radius.circular(28),
            bottomRight: const Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? AppColors.brandPrimary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isFocused ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.textLight.withValues(alpha: 0.65),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: widget.prefixIcon,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.suffixIcon,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            border: InputBorder.none,
          ),
          onChanged: (_) {},
          onTapOutside: (_) {
            if (_isFocused) setState(() => _isFocused = false);
            _focusController.reverse();
          },
          onTap: () {
            if (!_isFocused) setState(() => _isFocused = true);
            _focusController.forward();
          },
        ),
      ),
    );
  }
}
