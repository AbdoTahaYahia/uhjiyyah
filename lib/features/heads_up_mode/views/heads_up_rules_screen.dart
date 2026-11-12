import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/heads_up_deck.dart';
import '../providers/heads_up_game_provider.dart';

class HeadsUpRulesScreen extends ConsumerWidget {
  const HeadsUpRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('احزر الكلمة (Heads Up) 📱'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      'اختر تصنيف الكلمات وابدأ التحدي',
                      style: TextStyle(
                        color: AppColors.pureWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 350.ms),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: const Text(
                        'قواعد سريعة: ارفع الهاتف على جبهتك بحيث يرى أصدقاؤك الكلمة وأنت لا تراها!',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 60.ms),
                    const SizedBox(height: 20),

                    const Text(
                      'التصنيفات المتاحة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    ...kHeadsUpCategories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: players.length < 2
                              ? null
                              : () {
                                  ref.read(headsUpGameProvider.notifier).selectCategory(category);
                                  context.push('/heads-up/play');
                                },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                Text(category.emoji, style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.nameAr,
                                        style: const TextStyle(
                                          color: AppColors.pureWhite,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category.descriptionAr,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    const Text(
                      'طريقة اللعب:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('يمسك أحد اللاعبين الهاتف على رأسه، ويعطيه أصدقاؤه تلميحات وأوصاف.'),
                    _buildBullet('إذا حزرت الكلمة، اضغط على زر "صح" لكسب نقطة فورية.'),
                    _buildBullet('إذا كانت الكلمة صعبة، اضغط "تخطي" للانتقال للكلمة التالية.'),
                    _buildBullet('لديك 60 ثانية لجمع أكبر عدد ممكن من النقاط!'),
                  ],
                ),
              ),

              if (players.length < 2)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'يلزم تسجيل لاعبين اثنين على الأقل لبدء اللعب',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, height: 1.2)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
