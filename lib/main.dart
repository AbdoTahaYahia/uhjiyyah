import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/router/app_router.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';

/// أُحْجِيَّة — Main entry point for the local multiplayer party game hub.
///
/// Pre-initializes [SharedPreferences] before [runApp] to guarantee
/// instant, synchronous restoration of the player roster on launch.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const UhjiyyahApp(),
    ),
  );
}

/// Root application widget.
///
/// Features:
/// - Full Arabic (RTL) localization delegates
/// - Minimalist monochrome theme with Tajawal font
/// - Declarative routing via [appRouter]
class UhjiyyahApp extends StatelessWidget {
  const UhjiyyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'أُحْجِيَّة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
