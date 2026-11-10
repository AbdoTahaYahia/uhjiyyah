import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import 'package:uhjiyyah/features/home/home_screen.dart';
import 'package:uhjiyyah/features/mafia_mode/views/mafia_game_screen.dart';
import 'package:uhjiyyah/features/mafia_mode/views/mafia_rules_screen.dart';
import 'package:uhjiyyah/features/players_setup/players_setup_screen.dart';

/// Application-wide router configuration using GoRouter.
///
/// Route tree:
/// - `/` → [PlayersSetupScreen] — Initial screen for adding players
/// - `/home` → [HomeScreen] — Main game selection menu
/// - `/mafia` → placeholder (future)
/// - `/out-of-context` → placeholder (future)
/// - `/heads-up` → placeholder (future)
/// - `/who-among-us` → placeholder (future)
/// - `/charades` → placeholder (future)
/// - `/wink` → placeholder (future)
/// - `/spy` → placeholder (future)
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'players_setup',
      builder: (context, state) => const PlayersSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    // Placeholder routes for future game modes.
    // Each game mode will have its own isolated feature module.
    // Mafia Mode — Active Feature Module
    GoRoute(
      path: '/mafia',
      name: 'mafia',
      builder: (context, state) => const MafiaRulesScreen(),
    ),
    GoRoute(
      path: '/mafia/play',
      name: 'mafia_play',
      builder: (context, state) => const MafiaGameScreen(),
    ),
    GoRoute(
      path: '/out-of-context',
      name: 'out_of_context',
      builder: (context, state) => const _ComingSoonPlaceholder(title: 'خارج السياق'),
    ),
    GoRoute(
      path: '/heads-up',
      name: 'heads_up',
      builder: (context, state) => const _ComingSoonPlaceholder(title: 'احزر الكلمة'),
    ),
    GoRoute(
      path: '/who-among-us',
      name: 'who_among_us',
      builder: (context, state) => const _ComingSoonPlaceholder(title: 'مين فينا'),
    ),
    GoRoute(
      path: '/charades',
      name: 'charades',
      builder: (context, state) => const _ComingSoonPlaceholder(title: 'تمثيل'),
    ),
    GoRoute(
      path: '/wink',
      name: 'wink',
      builder: (context, state) => const _ComingSoonPlaceholder(title: 'الغمزة'),
    ),
    GoRoute(
      path: '/spy',
      name: 'spy',
      builder: (context, state) => const _ComingSoonPlaceholder(title: 'الجاسوس'),
    ),
  ],
);

/// Temporary placeholder screen for game modes not yet implemented.
class _ComingSoonPlaceholder extends StatelessWidget {
  final String title;
  const _ComingSoonPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, size: 70, color: AppColors.textSecondary),
            const SizedBox(height: 24),
            Text(
              'قريباً...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'هذه اللعبة قيد التطوير والإطلاق في التحديث القادم',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceBorder),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('العودة للقائمة'),
            ),
          ],
        ),
      ),
    );
  }
}
