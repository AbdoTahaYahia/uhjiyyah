import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../providers/charades_game_provider.dart';

class CharadesRulesScreen extends ConsumerStatefulWidget {
  const CharadesRulesScreen({super.key});

  @override
  ConsumerState<CharadesRulesScreen> createState() => _CharadesRulesScreenState();
}

class _CharadesRulesScreenState extends ConsumerState<CharadesRulesScreen> {
  final TextEditingController _teamAController = TextEditingController(text: 'الفريق أ');
  final TextEditingController _teamBController = TextEditingController(text: 'الفريق ب');
  int _selectedRounds = 5;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تمثيل (بدون كلام) '),
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
                      'لعبة بدون كلام الكلاسيكية',
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
                        'ينصح بـ 4 لاعبين على الأقل (فريقين متنافسين)',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 60.ms),
                    const SizedBox(height: 20),

                    const Text(
                      'إعداد الفرق والجولات:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _teamAController,
                      style: const TextStyle(color: AppColors.pureWhite),
                      decoration: InputDecoration(
                        labelText: 'اسم الفريق الأول',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _teamBController,
                      style: const TextStyle(color: AppColors.pureWhite),
                      decoration: InputDecoration(
                        labelText: 'اسم الفريق الثاني',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'عدد الجولات لكل فريق:',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [3, 5, 7].map((rounds) {
                        final isSelected = _selectedRounds == rounds;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              onPressed: () => setState(() => _selectedRounds = rounds),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.pureWhite : AppColors.surface,
                                foregroundColor: isSelected ? AppColors.background : AppColors.pureWhite,
                                side: BorderSide(
                                  color: isSelected ? AppColors.pureWhite : AppColors.surfaceBorder,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text('$rounds جولات', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'قوانين اللعبة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('ممنوع الكلام نهائياً أو إصدار أصوات أو تحريك الشفاه!'),
                    _buildBullet('ممنوع كتابة الحروف في الهواء أو الإشارة لأشياء بالكلمة.'),
                    _buildBullet('أمام الممثل 90 ثانية لتمثيل الكلمة لفريقه فقط.'),
                    _buildBullet('الفريق الذي يحصل على أكبر عدد من النقاط في نهاية الجولات يفوز باللقب!'),
                    const SizedBox(height: 20),

                    Text(
                      'اللاعبون المسجلون (${players.length}):',
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
                            ref.read(charadesGameProvider.notifier).setupTeams(
                                  teamAName: _teamAController.text,
                                  teamBName: _teamBController.text,
                                  totalRounds: _selectedRounds,
                                );
                            context.push('/charades/play');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: AppColors.surfaceBorder,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      players.length < 4 ? 'يلزم 4 لاعبين على الأقل' : 'بدء المسابقة ',
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
