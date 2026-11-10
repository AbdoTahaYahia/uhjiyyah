import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../providers/mafia_game_provider.dart';

/// The official rules and guidelines screen for Mafia Mode with Deep Space styling
/// and staggered section animations.
class MafiaRulesScreen extends ConsumerWidget {
  const MafiaRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.6),
              radius: 1.3,
              colors: [
                Color(0xFF141424),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        onPressed: () => context.go('/home'),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'لعبة: المافيا 🕵️',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      _buildSectionHeader('قوانين لعبة المافيا')
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.1, end: 0),
                      const SizedBox(height: 8),
                      _buildBadge('عدد اللاعبين المقترح في اللعبة: من 5 إلى 12 لاعب')
                          .animate()
                          .fadeIn(delay: 50.ms),
                      const SizedBox(height: 16),

                      _buildSubHeader('فكرة اللعبة:')
                          .animate()
                          .fadeIn(delay: 100.ms),
                      _buildParagraph(
                        'تدور أحداث اللعبة في قرية صغيرة تحتوي على أعضاء المافيا والمواطنين الذين يحاول كل منهما التخلص من الآخر، إذ أن المواطنين لا يعرفون من هم المافيا ولكنهم يحاولون تخمينهم، أما أعضاء المافيا فيعرفون بعضهم بعضاً سراً ويحاولون التخلص من المواطنين، وبناءً على الدور الذي يكلف به اللاعب سوف يحاول قتل أعضاء الفريق الآخر في جولات صباحية ومسائية.',
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 20),

                      _buildSubHeader('الأدوار:').animate().fadeIn(delay: 200.ms),
                      _buildRoleCard(
                        emoji: '💀',
                        title: 'المافيا',
                        description:
                            'يوجد عضو مافيا لكل 4 لاعبين، فمثلاً لو كان عدد اللاعبين 8، سيكون هناك 2 من المافيا. يحاول أعضاء المافيا قتل باقي اللاعبين وسيعرف كل عضو مافيا من هم أعضاء المافيا الآخرين.',
                      ).animate().fadeIn(delay: 230.ms).slideY(begin: 0.1, end: 0),
                      _buildRoleCard(
                        emoji: '🩺',
                        title: 'الطبيب',
                        description:
                            'الطبيب هو مواطن ويستطيع حماية اللاعب الذي يشك في أنه سيتم قتله من المافيا في الجولة المسائية، أو حماية نفسه إن أراد.',
                      ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.1, end: 0),
                      _buildRoleCard(
                        emoji: '🕵️',
                        title: 'المحقق',
                        description:
                            'المحقق هو مواطن ويستطيع سراً التحقق من هوية أحد اللاعبين خلال الجولات المسائية.',
                      ).animate().fadeIn(delay: 290.ms).slideY(begin: 0.1, end: 0),
                      _buildRoleCard(
                        emoji: '🧑‍🌾',
                        title: 'المواطن',
                        description:
                            'يحاول المواطن البقاء على قيد الحياة والتصويت لقتل أعضاء المافيا في الجولات الصباحية.',
                      ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 20),

                      _buildSubHeader('كيفية لعب المافيا:').animate().fadeIn(delay: 350.ms),
                      _buildBullet('تبدأ اللعبة بتحديد أدوار اللاعبين عشوائياً.'),
                      _buildBullet(
                        'أفراد المافيا سيتم إخبارهم بباقي الأعضاء الذين ينتمون لنفس الفريق في حال وجد أكثر من لاعب مافيا.',
                      ),
                      const SizedBox(height: 20),

                      _buildSubHeader('الجولات المسائية 🌃:').animate().fadeIn(delay: 400.ms),
                      _buildBullet(
                        'تبدأ اللعبة بالجولة المسائية وفي هذه الجولة يقوم أعضاء المافيا بقتل شخصية من المواطنين (مواطنين، الطبيب أو المحقق).',
                      ),
                      _buildBullet(
                        'يقوم الطبيب أيضاً بحماية شخصية يشك في أنها ستتعرض للقتل.',
                      ),
                      _buildBullet(
                        'يقوم المحقق بالتحقق من هوية شخصية واحدة في كل جولة مسائية.',
                      ),
                      _buildBullet(
                        'يمر الهاتف على كل اللاعبين في الليل للحفاظ على السرية التامة وعدم كشف هوية أصحاب الأدوار الخاصة.',
                      ),
                      _buildBullet(
                        'بعد انتهاء تصويت الجولة المسائية سيتم عرض النتائج وإذا كان هناك لاعب قد تم قتله من قبل المافيا يخرج من اللعبة. لكن إذا استطاع الطبيب حماية اللاعب المستهدف، لن يتم استبعاده وتنتقل اللعبة للجولة الصباحية.',
                      ),
                      const SizedBox(height: 20),

                      _buildSubHeader('الجولات الصباحية 🌅:').animate().fadeIn(delay: 450.ms),
                      _buildBullet(
                        'قبل بدء الجولة الصباحية يطلب من الجميع أن يتناقشوا وأن يتبادلوا التهم ومحاولة معرفة من هم المافيا بينهم. كل ما عليكم هو إقناع باقي اللاعبين بشخصيتكم بدون كشفها.',
                      ),
                      _buildBullet(
                        'بعد انتهاء النقاش يطلب من الجميع أن يقوموا بالتصويت لقتل شخصية ما.',
                      ),
                      _buildBullet(
                        'يتم الإعلان عن الشخصية التي تم قتلها ويتم إخراجها من اللعبة 💀.',
                      ),
                      _buildBullet(
                        'بعد الجولة الصباحية تنتقل اللعبة للجولة المسائية مرة أخرى وتستمر حتى انتهاء أعضاء أحد الفريقين.',
                      ),
                      const SizedBox(height: 20),

                      _buildSubHeader('نهاية اللعبة 🏆:').animate().fadeIn(delay: 500.ms),
                      _buildParagraph(
                        'تنتهي اللعبة عندما يتم قتل جميع أفراد المافيا (فوز المواطنين) أو عندما يتساوى عدد المافيا مع عدد المواطنين (فوز المافيا).',
                      ),
                      const SizedBox(height: 12),
                      _buildSubHeader('النقاط 🥇:').animate().fadeIn(delay: 530.ms),
                      _buildParagraph(
                        'يحصل الفريق الذي يفوز على 70 نقطة لكل لاعب متبقي على قيد الحياة في الفريق.',
                      ),
                      const SizedBox(height: 20),

                      _buildSubHeader('ملاحظات مهمة:').animate().fadeIn(delay: 560.ms),
                      _buildBullet(
                        'من المفترض إبقاء الأدوار سرية وعدم الإفصاح عن دورك الحقيقي في اللعبة لباقي اللاعبين لمنع استهدافك.',
                      ),
                      _buildBullet(
                        'لا تتسرع بالحكم على شخص ما لإخراجه، بل استمع إلى باقي اللاعبين لتحدد جيداً من المافيا.',
                      ),
                      _buildBullet(
                        'دافع عن نفسك بعقلانية كأن لا تقول "أنا لست من المافيا" بل حاول أن تقول شيئاً مفيداً لإقناع الجميع.',
                      ),
                      _buildBullet(
                        'لا تفزع عندما يتهمك أحدهم بأنك من أفراد المافيا لكي لا تثبت التهمة عليك.',
                      ),
                      _buildBullet(
                        'إذا خرجت من اللعبة يمنع التحدث والتأثير على مجريات اللعبة ولا تفوت فرصة الاستمتاع بمشاهدة بقية اللعبة.',
                      ),
                      _buildBullet(
                        'اللعبة تعتمد على الخداع والإيهام، ويفضل عدم استخدام الحلف بالله.',
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Text(
                          'نتمنى لكم وقتاً ممتعاً مع لعبة المافيا وتجربة مليئة بالإثارة والغموض مع أصدقائكم وعائلتكم!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Bottom Action Bar
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'الرجوع',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: players.length >= 4
                              ? () {
                                  ref.read(mafiaGameProvider.notifier).startNewGame(players);
                                  context.go('/mafia/play');
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.surface,
                                      content: Text(
                                        'لعبة المافيا تحتاج 4 لاعبين على الأقل للبدء (الموجودين: ${players.length})',
                                        style: const TextStyle(color: AppColors.textPrimary),
                                      ),
                                      action: SnackBarAction(
                                        label: 'إضافة لاعبين',
                                        textColor: AppColors.pureWhite,
                                        onPressed: () => context.go('/'),
                                      ),
                                    ),
                                  );
                                },
                          child: const Text(
                            'ابدأ اللعبة 🚀',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.pureWhite,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String emoji,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
