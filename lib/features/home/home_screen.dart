import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/models/game_mode.dart';
import 'package:uhjiyyah/core/models/game_modes_registry.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';

/// Main game-selection menu with a vertically stacked list layout
/// and a strict minimalist monochrome aesthetic (black, white & subtle grays).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('أُحْجِيَّة'),
          leading: IconButton(
            tooltip: 'تعديل قائمة اللاعبين',
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.go('/'),
          ),
          actions: [
            // Active players chip
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 15,
                    color: AppColors.pureWhite,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${players.length}',
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'اختر اللعبة للبدء',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideX(begin: 0.05, end: 0),

              // Online Multiplayer Banner Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: InkWell(
                  onTap: () => context.push('/online'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.pureWhite, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Icon(Icons.wifi, color: AppColors.pureWhite, size: 22)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1.1, 1.1),
                                duration: 1200.ms,
                              ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'غرف اللعب أونلاين (Firebase)',
                                style: TextStyle(
                                  color: AppColors.pureWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'أنشئ غرفة أو انضم برمز للعب مع أصدقائك عن بُعد',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.pureWhite, size: 16),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),

              // Vertically stacked games list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: kGameModes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mode = kGameModes[index];
                    return _VerticalGameCard(
                      mode: mode,
                      playerCount: players.length,
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (index * 60).ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.18,
                          end: 0,
                          duration: 400.ms,
                          delay: (index * 60).ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wide, horizontally-oriented card component for vertically stacked games list.
class _VerticalGameCard extends StatelessWidget {
  final GameMode mode;
  final int playerCount;

  const _VerticalGameCard({
    required this.mode,
    required this.playerCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasEnoughPlayers = playerCount >= mode.minPlayers;
    final isPlayable = mode.isAvailable && hasEnoughPlayers;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: mode.isAvailable
            ? () {
                if (!hasEnoughPlayers) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surface,
                      content: Text(
                        'هذه اللعبة تتطلب ${mode.minPlayers} لاعبين على الأقل (الموجودين: $playerCount)',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  );
                  return;
                }
                context.go(mode.routeName);
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlayable
                  ? AppColors.surfaceBorder
                  : AppColors.surfaceBorder.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading Icon Container
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(
                  mode.icon,
                  size: 26,
                  color: mode.isAvailable
                      ? AppColors.pureWhite
                      : AppColors.textMuted,
                ),
              ),

              const SizedBox(width: 16),

              // Title, Description, and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mode.titleAr,
                          style: const TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!mode.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    AppColors.surfaceBorder.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text(
                              'قريباً',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.pureWhite.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Text(
                              'متاحة للعب',
                              style: TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mode.descriptionAr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: hasEnoughPlayers
                              ? AppColors.textSecondary
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${mode.minPlayers}+ لاعبين مطلوبين',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasEnoughPlayers
                                ? AppColors.textSecondary
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing arrow indicator
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isPlayable
                      ? AppColors.pureWhite
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
