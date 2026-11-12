import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uhjiyyah/features/charades_mode/views/charades_game_screen.dart';
import 'package:uhjiyyah/features/charades_mode/views/charades_rules_screen.dart';
import 'package:uhjiyyah/features/heads_up_mode/views/heads_up_game_screen.dart';
import 'package:uhjiyyah/features/heads_up_mode/views/heads_up_rules_screen.dart';
import 'package:uhjiyyah/features/home/home_screen.dart';
import 'package:uhjiyyah/features/mafia_mode/views/mafia_game_screen.dart';
import 'package:uhjiyyah/features/mafia_mode/views/mafia_rules_screen.dart';
import 'package:uhjiyyah/features/online_multiplayer/views/online_lobby_screen.dart';
import 'package:uhjiyyah/features/online_multiplayer/views/online_room_screen.dart';
import 'package:uhjiyyah/features/out_of_context_mode/views/out_of_context_game_screen.dart';
import 'package:uhjiyyah/features/out_of_context_mode/views/out_of_context_rules_screen.dart';
import 'package:uhjiyyah/features/players_setup/players_setup_screen.dart';
import 'package:uhjiyyah/features/splash/splash_screen.dart';
import 'package:uhjiyyah/features/spy_mode/views/spy_game_screen.dart';
import 'package:uhjiyyah/features/spy_mode/views/spy_rules_screen.dart';
import 'package:uhjiyyah/features/who_among_us_mode/views/who_among_us_game_screen.dart';
import 'package:uhjiyyah/features/who_among_us_mode/views/who_among_us_rules_screen.dart';
import 'package:uhjiyyah/features/wink_mode/views/wink_game_screen.dart';
import 'package:uhjiyyah/features/wink_mode/views/wink_rules_screen.dart';

CustomTransitionPage<T> _buildPageTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Application-wide router configuration using GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'players_setup',
      pageBuilder: (context, state) => _buildPageTransition(
        context: context,
        state: state,
        child: const PlayersSetupScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _buildPageTransition(
        context: context,
        state: state,
        child: const HomeScreen(),
      ),
    ),

    // Online Multiplayer
    GoRoute(
      path: '/online',
      name: 'online_lobby',
      pageBuilder: (context, state) => _buildPageTransition(
        context: context,
        state: state,
        child: const OnlineLobbyScreen(),
      ),
    ),
    GoRoute(
      path: '/online/room',
      name: 'online_room',
      pageBuilder: (context, state) => _buildPageTransition(
        context: context,
        state: state,
        child: const OnlineRoomScreen(),
      ),
    ),

    // 1. Mafia Mode
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

    // 2. Spy Mode
    GoRoute(
      path: '/spy',
      name: 'spy',
      builder: (context, state) => const SpyRulesScreen(),
    ),
    GoRoute(
      path: '/spy/play',
      name: 'spy_play',
      builder: (context, state) => const SpyGameScreen(),
    ),

    // 3. Out of Context Mode
    GoRoute(
      path: '/out-of-context',
      name: 'out_of_context',
      builder: (context, state) => const OutOfContextRulesScreen(),
    ),
    GoRoute(
      path: '/out-of-context/play',
      name: 'out_of_context_play',
      builder: (context, state) => const OutOfContextGameScreen(),
    ),

    // 4. Heads Up Mode
    GoRoute(
      path: '/heads-up',
      name: 'heads_up',
      builder: (context, state) => const HeadsUpRulesScreen(),
    ),
    GoRoute(
      path: '/heads-up/play',
      name: 'heads_up_play',
      builder: (context, state) => const HeadsUpGameScreen(),
    ),

    // 5. Who Among Us Mode
    GoRoute(
      path: '/who-among-us',
      name: 'who_among_us',
      builder: (context, state) => const WhoAmongUsRulesScreen(),
    ),
    GoRoute(
      path: '/who-among-us/play',
      name: 'who_among_us_play',
      builder: (context, state) => const WhoAmongUsGameScreen(),
    ),

    // 6. Charades Mode
    GoRoute(
      path: '/charades',
      name: 'charades',
      builder: (context, state) => const CharadesRulesScreen(),
    ),
    GoRoute(
      path: '/charades/play',
      name: 'charades_play',
      builder: (context, state) => const CharadesGameScreen(),
    ),

    // 7. Wink Mode
    GoRoute(
      path: '/wink',
      name: 'wink',
      builder: (context, state) => const WinkRulesScreen(),
    ),
    GoRoute(
      path: '/wink/play',
      name: 'wink_play',
      builder: (context, state) => const WinkGameScreen(),
    ),
  ],
);
