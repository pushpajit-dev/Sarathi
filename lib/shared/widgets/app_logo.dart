import 'package:flutter/material.dart';

/// Curvy rounded Sarathi AI Logo.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 32,
    this.color,
    this.eyeColor = Colors.white,
    this.showGlow = true,
    this.borderRadius,
  });

  final double size;
  final Color? color;
  final Color eyeColor;
  final bool showGlow;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: size * 0.25,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: primaryColor.withValues(alpha: 0.2),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                size: size * 0.5,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
