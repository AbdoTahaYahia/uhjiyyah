import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../providers/spy_game_provider.dart';

class SpyRulesScreen extends ConsumerWidget {
  const SpyRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('لعبة: الجاسوس 🕵️‍♂️'),
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
                      'قواعد ومهمة الجاسوس',
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
                        'عدد اللاعبين المقترح: 3 إلى 10 لاعبين',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 60.ms),
                    const SizedBox(height: 18),

                    const Text(
                      'فكرة اللعبة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'يحصل جميع اللاعبين سراً على نفس اسم المكان السري مع دور محدد داخله، باستثناء لاعب واحد يتم اختياره عشوائياً ليكون "الجاسوس" ولا يعلم أين يتواجد الجميع!',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'طريقة اللعب:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('يمرر الهاتف لكل لاعب بالدور ليكتشف سراً مكانه ودوره.'),
                    _buildBullet('يبدأ مؤقت النقاش، ويسأل كل لاعب زميلاً له سؤالاً غامضاً عن المكان دون كشف اسمه.'),
                    _buildBullet('مهمة أهل المكان: توجيه أسئلة ذكية لكشف الشخص الذي يتهرب أو لا يعرف طبيعة المكان.'),
                    _buildBullet('مهمة الجاسوس: الاستماع بدقة وتأليف إجابات مقنعة وتخمين اسم المكان قبل كشفه!'),
                    const SizedBox(height: 20),

                    const Text(
                      'شروط الفوز 🏆:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('فوز أهل المكان: إذا اتفقت القرية على الجاسوس الصحيح وفشل في تخمين المكان.'),
                    _buildBullet('فوز الجاسوس: إذا أشار الجميع إلى شخص بريء، أو إذا اكتشف الجاسوس اسم المكان السري بدقة.'),
                  ],
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => context.go('/home'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.surfaceBorder),
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('الرجوع'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: players.length >= 3
                            ? () {
                                ref.read(spyGameProvider.notifier).startNewGame(players);
                                context.go('/spy/play');
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.surface,
                                    content: Text(
                                      'لعبة الجاسوس تحتاج 3 لاعبين على الأقل (الموجودين: ${players.length})',
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                  ),
                                );
                              },
                        child: const Text('ابدأ اللعبة 🚀'),
                      ),
                    ),
                  ],
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
          const Text('• ', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}
