import 'package:flutter/material.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';

/// Maps a player's name / initial letter to a distinctive, sleek
/// monochrome icon symbol matching the Deep Space aesthetic.
IconData getPlayerIconForName(String name) {
  if (name.trim().isEmpty) return Icons.person_outline;

  final firstChar = name.trim().characters.first.toLowerCase();

  switch (firstChar) {
    case 'أ':
    case 'إ':
    case 'آ':
    case 'ا':
    case 'a':
      return Icons.auto_awesome;
    case 'ب':
    case 'b':
      return Icons.bolt_outlined;
    case 'ت':
    case 't':
      return Icons.stars_outlined;
    case 'ث':
      return Icons.diamond_outlined;
    case 'ج':
    case 'j':
      return Icons.military_tech_outlined;
    case 'ح':
    case 'h':
      return Icons.shield_outlined;
    case 'خ':
      return Icons.security_outlined;
    case 'د':
    case 'd':
      return Icons.fingerprint;
    case 'ذ':
      return Icons.token_outlined;
    case 'ر':
    case 'r':
      return Icons.rocket_launch_outlined;
    case 'ز':
    case 'z':
      return Icons.flare;
    case 'س':
    case 's':
      return Icons.smart_toy_outlined;
    case 'ش':
    case 'sh':
      return Icons.local_fire_department_outlined;
    case 'ص':
      return Icons.visibility_outlined;
    case 'ض':
      return Icons.psychology_outlined;
    case 'ط':
      return Icons.flight_outlined;
    case 'ظ':
      return Icons.dark_mode_outlined;
    case 'ع':
      return Icons.remove_red_eye_outlined;
    case 'غ':
    case 'g':
      return Icons.blur_on;
    case 'ف':
    case 'f':
      return Icons.lightbulb_outlined;
    case 'ق':
    case 'q':
      return Icons.offline_bolt_outlined;
    case 'ك':
    case 'k':
    case 'c':
      return Icons.hub_outlined;
    case 'ل':
    case 'l':
      return Icons.explore_outlined;
    case 'م':
    case 'm':
      return Icons.crisis_alert_outlined;
    case 'ن':
    case 'n':
      return Icons.adjust_outlined;
    case 'ه':
    case 'ة':
      return Icons.hdr_strong_outlined;
    case 'و':
    case 'w':
    case 'o':
    case 'u':
      return Icons.waves_outlined;
    case 'ي':
    case 'ى':
    case 'ئ':
    case 'y':
    case 'i':
    case 'e':
      return Icons.handshake_outlined;
    default:
      // Deterministic fallback based on hash
      const pool = [
        Icons.auto_awesome,
        Icons.bolt_outlined,
        Icons.stars_outlined,
        Icons.diamond_outlined,
        Icons.shield_outlined,
        Icons.rocket_launch_outlined,
        Icons.smart_toy_outlined,
        Icons.fingerprint,
        Icons.military_tech_outlined,
        Icons.crisis_alert_outlined,
        Icons.adjust_outlined,
        Icons.hub_outlined,
      ];
      final idx = name.hashCode.abs() % pool.length;
      return pool[idx];
  }
}

/// A sleek, minimalist monochrome avatar badge for players.
///
/// Instead of a plain letter, it shows a distinctive starlight symbol
/// tailored to the player's name/initial, with an optional miniature
/// initial badge.
class PlayerAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool showInitialBadge;
  final Color? iconColor;
  final Color? backgroundColor;

  const PlayerAvatar({
    super.key,
    required this.name,
    this.radius = 18,
    this.showInitialBadge = false,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final icon = getPlayerIconForName(name);
    final size = radius * 2;
    final initial = name.trim().isNotEmpty ? name.trim().characters.first : '?';

    Widget avatarCore = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.surfaceLight,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: radius > 24 ? 2 : 1.2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: radius * 1.05,
          color: iconColor ?? AppColors.pureWhite,
        ),
      ),
    );

    if (!showInitialBadge) {
      return avatarCore;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarCore,
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.surfaceBorder, width: 1),
            ),
            child: Text(
              initial,
              style: TextStyle(
                color: AppColors.pureWhite,
                fontSize: radius * 0.45,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
