import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import 'package:uhjiyyah/core/widgets/player_avatar.dart';
import '../providers/out_of_context_game_provider.dart';

class OutOfContextRulesScreen extends ConsumerWidget {
  const OutOfContextRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('لعبة: خارج السياق '),
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
                      'قواعد لعبة خارج السياق',
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
                        'عدد اللاعبين المطلوب: 3 لاعبين على الأقل',
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
                      'جميع اللاعبين يحصلون على كلمة سرية وتصنيف موحد، ما عدا لاعب واحد فقط يكون "خارج السياق" ولا يعلم ما هي الكلمة!',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'طريقة اللعب خطوة بخطوة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('يمرر الهاتف بين اللاعبين لرؤية بطاقتهم السرية بحذر.'),
                    _buildBullet('اللاعب العادي يرى الكلمة والتصنيف (مثلاً: شاورما - أكلات).'),
                    _buildBullet('اللاعب الذي بالخارج يرى جملة: "أنت خارج السياق! حاول التمويه".'),
                    _buildBullet('يبدأ النقاش بالسؤال والجواب بالدور؛ احذر أن تكون إجابتك مكشوفة للمتسلل أو غامضة فيشك فيك أصحابك!'),
                    _buildBullet('إذا انتهى الوقت، يتم التصويت على الشخص المتسلل.'),
                    _buildBullet('إذا تم اتهام المتسلل، يحصل على فرصة ذهبية واحدة لتخمين الكلمة والفوز!'),
                    const SizedBox(height: 20),

                    const Text(
                      'شروط الفوز:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('يفوز أصحاب الكلمة إذا اكتشفوا المتسلل ولم يستطع تخمين الكلمة السرية.'),
                    _buildBullet('يفوز المتسلل إذا تم اتهام لاعب بريء، أو إذا كشفوه واستطاع معرفة الكلمة السرية!'),
                    const SizedBox(height: 24),

                    // Players list
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
                          avatar: PlayerAvatar(
                            name: p.name,
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

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: players.length < 3
                        ? null
                        : () {
                            ref.read(outOfContextGameProvider.notifier).startNewGame();
                            context.push('/out-of-context/play');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.surfaceBorder,
                      disabledForegroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      players.length < 3 ? 'يلزم 3 لاعبين على الأقل' : 'ابدأ اللعبة الآن',
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
