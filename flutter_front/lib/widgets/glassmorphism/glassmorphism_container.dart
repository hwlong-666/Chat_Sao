import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double blurIntensity;
  final double opacity;
  final BorderRadius borderRadius;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BoxShadow? customShadow;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.blurIntensity = 10,
    this.opacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.customShadow,
    this.backgroundColor,
    this.width,
    this.height,
    this.onTap,
  });

  factory GlassmorphismContainer.glass({
    required Widget child,
    double borderRadius = 32,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return GlassmorphismContainer(
      opacity: 0.4,
      blurIntensity: 20,
      borderRadius: BorderRadius.circular(borderRadius),
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? EdgeInsets.zero,
      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
      customShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      onTap: onTap,
      child: child,
    );
  }

  factory GlassmorphismContainer.bottomNav({
    required Widget child,
  }) {
    return GlassmorphismContainer(
      opacity: 0.4,
      blurIntensity: 24,
      borderRadius: BorderRadius.circular(48),
      padding: const EdgeInsets.all(8),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
      customShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 50,
        offset: const Offset(0, 20),
      ),
      child: child,
    );
  }

  factory GlassmorphismContainer.messageInput({
    required Widget child,
  }) {
    return GlassmorphismContainer(
      opacity: 0.4,
      blurIntensity: 20,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(22),
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(22),
      ),
      padding: const EdgeInsets.all(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
      customShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 40,
        offset: const Offset(0, 15),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget glassWidget = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurIntensity,
          sigmaY: blurIntensity,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassColorWithOpacity(opacity),
            borderRadius: borderRadius,
            border: border ?? Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              customShadow ?? BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != EdgeInsets.zero) {
      glassWidget = Padding(
        padding: margin,
        child: glassWidget,
      );
    }

    if (onTap != null) {
      glassWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: glassWidget,
        ),
      );
    }

    return glassWidget;
  }
}
