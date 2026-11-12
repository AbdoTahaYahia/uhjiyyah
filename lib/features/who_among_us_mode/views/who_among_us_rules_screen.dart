import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../providers/who_among_us_game_provider.dart';

class WhoAmongUsRulesScreen extends ConsumerWidget {
  const WhoAmongUsRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('مين فينا '),
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
                      'لعبة كشف الأسرار والضحك!',
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
                        'عدد اللاعبين: 3 لاعبين على الأقل',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 60.ms),
                    const SizedBox(height: 20),

                    const Text(
                      'كيف تُلعب اللعبة؟',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('يظهر سؤال ممتع ومحرج في كل جولة (مثلاً: "مين أكتر واحد ممكن ينام في فرحه؟").'),
                    _buildBullet('يمرر الهاتف بين جميع اللاعبين ليصوت كل لاعب سراً على الشخص الذي يراه مناسباً للسؤال.'),
                    _buildBullet('بعد انتهاء التصويت، تُكشف النتائج وتظهر نسبة الأصوات ومن هو "الفائز" بالسؤال!'),
                    _buildBullet('يمكنكم متابعة لائحة الشرف في أي وقت لمعرفة أكثر شخص حصل على أصوات.'),
                    const SizedBox(height: 24),

                    Text(
                      'اللاعبون الحاليون (${players.length}):',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: players.map((p) {
                        return Chip(
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.surfaceBorder),
                          avatar: CircleAvatar(
                            backgroundColor: Color(p.avatarColor),
                            radius: 10,
                          ),
                          label: Text(
                            p.name,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: players.length < 3
                        ? null
                        : () {
                            ref.read(whoAmongUsGameProvider.notifier).startNewGame();
                            context.push('/who-among-us/play');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.surfaceBorder,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      players.length < 3 ? 'يلزم 3 لاعبين على الأقل' : 'ابدأ اللعبة الآن ',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
