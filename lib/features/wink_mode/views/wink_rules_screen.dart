import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../providers/wink_game_provider.dart';

class WinkRulesScreen extends ConsumerWidget {
  const WinkRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الغمزة 👁️'),
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
                      'لعبة الغمزة والمحقق',
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
                        'عدد اللاعبين: 4 لاعبين على الأقل (كلما زاد العدد زادت المتعة)',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 60.ms),
                    const SizedBox(height: 20),

                    const Text(
                      'الأدوار في اللعبة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildRoleCard('🔍 المحقق', 'معروف للجميع ويجلس في وسط الدائرة أو يراقب عيون الجميع لكشف الغامز.'),
                    const SizedBox(height: 8),
                    _buildRoleCard('😉 الغامز (سري)', 'يحاول الغمز بعينه لأي مواطن دون أن يراه المحقق.'),
                    const SizedBox(height: 8),
                    _buildRoleCard('👥 المواطنون', 'إذا غمِز لك، انتظر 5 ثوانٍ ثم اضغط على زر "تم إقصائي".'),
                    const SizedBox(height: 20),

                    const Text(
                      'طريقة اللعب وشروط الفوز:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('يمرر الهاتف ليرى كل لاعب دوره سراً.'),
                    _buildBullet('يجلس الجميع في دائرة، والمحقق يراقب التركيز في العيون.'),
                    _buildBullet('للمحقق محاولتان (2) فقط للاتهام.'),
                    _buildBullet('يفوز المحقق والمواطنون إذا كشف الغامز.'),
                    _buildBullet('يفوز الغامز إذا أقصى المواطنين أو أخطأ المحقق في محاولتيه!'),
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
                    onPressed: players.length < 4
                        ? null
                        : () {
                            ref.read(winkGameProvider.notifier).startNewGame();
                            context.push('/wink/play');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.surfaceBorder,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      players.length < 4 ? 'يلزم 4 لاعبين على الأقل' : 'توزيع الأدوار وبدء اللعبة 👁️',
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

  Widget _buildRoleCard(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35)),
        ],
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
