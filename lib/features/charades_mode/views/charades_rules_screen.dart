import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/models/player.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import 'package:uhjiyyah/core/widgets/player_avatar.dart';
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

  final Set<String> _teamAPlayerIds = {};
  final Set<String> _teamBPlayerIds = {};
  bool _initialized = false;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  void _distributePlayers(List<Player> players, {bool shuffle = false}) {
    _teamAPlayerIds.clear();
    _teamBPlayerIds.clear();

    final list = List<Player>.from(players);
    if (shuffle) {
      list.shuffle(Random());
    }

    for (int i = 0; i < list.length; i++) {
      if (i % 2 == 0) {
        _teamAPlayerIds.add(list[i].id);
      } else {
        _teamBPlayerIds.add(list[i].id);
      }
    }
  }

  void _togglePlayerTeam(String playerId) {
    setState(() {
      if (_teamAPlayerIds.contains(playerId)) {
        _teamAPlayerIds.remove(playerId);
        _teamBPlayerIds.add(playerId);
      } else {
        _teamBPlayerIds.remove(playerId);
        _teamAPlayerIds.add(playerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    if (!_initialized && players.isNotEmpty) {
      _distributePlayers(players, shuffle: false);
      _initialized = true;
    }

    final teamAPlayers = players.where((p) => _teamAPlayerIds.contains(p.id)).toList();
    final teamBPlayers = players.where((p) => _teamBPlayerIds.contains(p.id)).toList();

    final canStart = players.length >= 2 && teamAPlayers.isNotEmpty && teamBPlayers.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تمثيل (بدون كلام)'),
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
                      'تقسيم الفرق وتحدي بدون كلام',
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
                        'وزّع اللاعبين على الفريقين يدوياً أو اضغط على التقسيم العشوائي!',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 60.ms),
                    const SizedBox(height: 20),

                    // Quick Random Shuffle Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تشكيلة الفريقين:',
                          style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: players.length < 2
                              ? null
                              : () {
                                  setState(() {
                                    _distributePlayers(players, shuffle: true);
                                  });
                                },
                          icon: const Icon(Icons.shuffle, size: 18, color: AppColors.pureWhite),
                          label: const Text(
                            'تقسيم عشوائي',
                            style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Team A Card
                    _buildTeamCard(
                      controller: _teamAController,
                      teamLabel: 'الفريق الأول',
                      teamPlayers: teamAPlayers,
                      otherTeamName: _teamBController.text,
                    ),
                    const SizedBox(height: 14),

                    // Team B Card
                    _buildTeamCard(
                      controller: _teamBController,
                      teamLabel: 'الفريق الثاني',
                      teamPlayers: teamBPlayers,
                      otherTeamName: _teamAController.text,
                    ),
                    const SizedBox(height: 20),

                    // Rounds Selector
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

                    // Rules Bullets
                    const Text(
                      'قوانين اللعبة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('في كل دور، يظهر اسم الممثل المحدد من الفريق لتمثيل الكلمة لباقي فريقه فقط.'),
                    _buildBullet('ممنوع الكلام نهائياً أو إصدار أصوات أو تحريك الشفاه أو الإشارة للحروف!'),
                    _buildBullet('أمام الممثل 90 ثانية لتمثيل الكلمة وكسب نقطة لفريقه.'),
                    _buildBullet('الفريق الذي يجمع أكبر عدد من النقاط في نهاية الجولات يفوز باللقب!'),
                  ],
                ),
              ),

              // Bottom Start Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: !canStart
                        ? null
                        : () {
                            ref.read(charadesGameProvider.notifier).setupTeams(
                                  teamAName: _teamAController.text,
                                  teamBName: _teamBController.text,
                                  teamAPlayers: teamAPlayers,
                                  teamBPlayers: teamBPlayers,
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
                      !canStart
                          ? (players.length < 2 ? 'يلزم لاعبان على الأقل' : 'يجب وضع لاعب في كل فريق')
                          : 'بدء المسابقة بين الفريقين',
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

  Widget _buildTeamCard({
    required TextEditingController controller,
    required String teamLabel,
    required List<Player> teamPlayers,
    required String otherTeamName,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: teamLabel,
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  '${teamPlayers.length} لاعبين',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (teamPlayers.isEmpty)
            const Text(
              'لا يوجد لاعبون في هذا الفريق (المس أي لاعب لنقله هنا)',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: teamPlayers.map((p) {
                return InkWell(
                  onTap: () => _togglePlayerTeam(p.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Chip(
                    backgroundColor: AppColors.surfaceLight,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    avatar: PlayerAvatar(
                      name: p.name,
                      radius: 10,
                    ),
                    label: Text(
                      '${p.name} ⇄',
                      style: const TextStyle(color: AppColors.pureWhite, fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
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
