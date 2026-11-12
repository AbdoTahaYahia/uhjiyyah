import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';

/// Animated splash screen featuring a sleek scale-up and glowing entrance
/// of the official monochrome "أُحْجِيَّة" emblem.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _startTimer() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Icon with smooth zoom-in entrance
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pureWhite.withValues(alpha: 0.14),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.35, 0.35),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 800.ms)
                  .then(delay: 200.ms)
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.06, 1.06),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 28),
              // App Title Entrance
              Text(
                'أُحْجِيَّة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 600.ms)
                  .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'ألعاب التجمعات والمرح',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 550.ms, duration: 600.ms)
                  .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}
