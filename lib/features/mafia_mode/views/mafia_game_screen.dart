import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/mafia_game_state.dart';
import '../models/mafia_player.dart';
import '../models/mafia_role.dart';
import '../providers/mafia_game_provider.dart';

/// Interactive, turn-based game coordinator screen for Mafia Mode.
///
/// Features Turn-by-Turn Night Phase where the phone is passed to EVERY
/// alive player (including sleeping Citizens) to eliminate metagaming,
/// timed daytime debates, interactive voting, and winner scoring.
class MafiaGameScreen extends ConsumerStatefulWidget {
  const MafiaGameScreen({super.key});

  @override
  ConsumerState<MafiaGameScreen> createState() => _MafiaGameScreenState();
}

class _MafiaGameScreenState extends ConsumerState<MafiaGameScreen> {
  String? _selectedPlayerId;

  // Discussion timer state
  Timer? _discussionTimer;
  int _secondsRemaining = 90;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _discussionTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _discussionTimer?.cancel();
    _secondsRemaining = 90;
    _isTimerRunning = true;
    _discussionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isTimerRunning = false);
      }
    });
  }

  void _stopTimer() {
    _discussionTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mafiaGameProvider);
    final notifier = ref.read(mafiaGameProvider.notifier);

    if (state.players.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('لم تبدأ اللعبة بعد'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/mafia'),
                  child: const Text('العودة لقوانين المافيا'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            state.phase == MafiaPhase.revealRoles
                ? 'كشف الأدوار السرية'
                : 'المافيا - الجولة ${state.roundNumber}',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.danger),
            tooltip: 'إنهاء اللعبة',
            onPressed: () => _confirmExit(context),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildPhaseView(state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseView(MafiaGameState state, MafiaGameNotifier notifier) {
    switch (state.phase) {
      case MafiaPhase.rules:
        return const SizedBox.shrink();

      case MafiaPhase.revealRoles:
        return _buildRevealRolesView(state, notifier);

      case MafiaPhase.nightTurns:
        return _buildNightTurnView(state, notifier);

      case MafiaPhase.dawnReport:
        return _buildDawnReportView(state, notifier);

      case MafiaPhase.dayDiscussion:
        return _buildDayDiscussionView(state, notifier);

      case MafiaPhase.dayVoting:
        return _buildDayVotingView(state, notifier);

      case MafiaPhase.gameOver:
        return _buildGameOverView(state, notifier);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. REVEAL ROLES VIEW (Pass & Play)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRevealRolesView(
      MafiaGameState state, MafiaGameNotifier notifier) {
    final player = state.players[state.currentRevealIndex];
    final isLast = state.currentRevealIndex == state.players.length - 1;

    final otherMafia = state.players
        .where((p) => p.role == MafiaRole.mafia && p.id != player.id)
        .map((p) => p.name)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اللاعب ${state.currentRevealIndex + 1} من أصل ${state.players.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
              child: state.isCardRevealed
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            player.role.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            player.role.titleAr,
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              player.role.team == MafiaTeam.mafia
                                  ? 'فريق المافيا 💀'
                                  : 'فريق المواطنين 🧑‍🌾',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            player.role.instructionsAr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          if (player.role == MafiaRole.mafia &&
                              otherMafia.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '👥 زملاؤك في المافيا:',
                                    style: TextStyle(
                                      color: AppColors.pureWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    otherMafia.join(' ، '),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(player.avatarColor),
                          child: Text(
                            player.name.isNotEmpty
                                ? player.name.characters.first
                                : '?',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'مرر الهاتف إلى:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player.name,
                          style: const TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🔒 تأكد من عدم رؤية أي شخص آخر للشاشة قبل كشف الدور',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (!state.isCardRevealed) {
                notifier.toggleRevealCard();
              } else {
                notifier.nextRoleReveal();
              }
            },
            child: Text(
              !state.isCardRevealed
                  ? 'اكشف دوري سراً 👁️'
                  : (isLast ? 'إنهاء وبدء الجولة الليلية 🌃' : 'أخفِ دوري ومرر للتالي 🔒'),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. TURN-BY-TURN NIGHT PHASE (For ALL Alive Players)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildNightTurnView(
      MafiaGameState state, MafiaGameNotifier notifier) {
    final player = state.currentNightPlayer;
    if (player == null) return const SizedBox.shrink();

    final aliveCount = state.alivePlayers.length;
    final turnNumber = state.currentNightPlayerIndex + 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Night Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الجولة المسائية 🌃',
                style: TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  'دور $turnNumber من $aliveCount',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hidden State: "Pass phone to [Name]"
          if (!state.isNightActionRevealed)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(player.avatarColor),
                      child: Text(
                        player.name.isNotEmpty ? player.name.characters.first : '?',
                        style: const TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'مرر الهاتف إلى:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: AppColors.pureWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🔒 جميع اللاعبين يستلمون الهاتف ليلاً لمنع كشف الأدوار. استلم الهاتف وتأكد من سرية الشاشة قبل البدء.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Active Action State based on role
            Expanded(
              child: _buildRoleNightAction(state, notifier, player),
            ),

          const SizedBox(height: 16),

          // Action button
          if (!state.isNightActionRevealed)
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedPlayerId = null);
                notifier.revealNightAction();
              },
              child: Text('أنا ${player.name}، ابدأ دوري الليلي 🌙'),
            )
          else
            _buildRoleNightSubmitButton(state, notifier, player),
        ],
      ),
    );
  }

  Widget _buildRoleNightAction(
      MafiaGameState state, MafiaGameNotifier notifier, MafiaPlayer player) {
    switch (player.role) {
      case MafiaRole.mafia:
        final targets = state.alivePlayers;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoleHeader('💀', 'أنت المافيا!', 'اختر الضحية المراد اغتيالها هذه الليلة:'),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: targets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  final isSelected = _selectedPlayerId == target.id;
                  return _buildSelectableTile(
                    name: target.name,
                    avatarColor: target.avatarColor,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedPlayerId = target.id),
                  );
                },
              ),
            ),
          ],
        );

      case MafiaRole.doctor:
        final targets = state.alivePlayers;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoleHeader('🩺', 'أنت الطبيب!', 'اختر شخصاً لحمايته الليلة من القتل (يمكنك حماية نفسك):'),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: targets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  final isSelected = _selectedPlayerId == target.id;
                  return _buildSelectableTile(
                    name: target.name,
                    avatarColor: target.avatarColor,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedPlayerId = target.id),
                  );
                },
              ),
            ),
          ],
        );

      case MafiaRole.detective:
        final targets = state.alivePlayers.where((p) => p.id != player.id).toList();
        final hasChecked = state.detectiveCheckedId != null;

        if (!hasChecked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoleHeader('🕵️', 'أنت المحقق!', 'اختر لاعباً للتحقق من هويته سراً:'),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: targets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final target = targets[index];
                    final isSelected = _selectedPlayerId == target.id;
                    return _buildSelectableTile(
                      name: target.name,
                      avatarColor: target.avatarColor,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedPlayerId = target.id),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.detectiveInspectionResult == true ? '💀' : '🧑‍🌾',
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.detectiveInspectionResult == true
                        ? 'هذا اللاعب ينتمي إلى المافيا!'
                        : 'هذا اللاعب مواطن شريف!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'احتفظ بهذه المعلومة بحذر لتقود النقاش في الصباح دون لفت انتباه المافيا إليك.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

      case MafiaRole.citizen:
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('😴', style: TextStyle(fontSize: 54)),
                SizedBox(height: 16),
                Text(
                  'أنت مواطن شريف نائم...',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'القرية هادئة بالنسبة لك هذه الليلة. ليس لديك أي قرار لاتخاذه. اضغط على الزر بالأسفل لتمرير الهاتف للاعب التالي دون أن يكتشف أحد أنك مواطن!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildRoleNightSubmitButton(
      MafiaGameState state, MafiaGameNotifier notifier, MafiaPlayer player) {
    switch (player.role) {
      case MafiaRole.mafia:
        return ElevatedButton(
          onPressed: _selectedPlayerId != null
              ? () {
                  final target = _selectedPlayerId;
                  setState(() => _selectedPlayerId = null);
                  notifier.submitCurrentNightTurn(selectedTargetId: target);
                }
              : null,
          child: const Text('تأكيد الهدف وإنهاء دوري 💀'),
        );

      case MafiaRole.doctor:
        return ElevatedButton(
          onPressed: _selectedPlayerId != null
              ? () {
                  final target = _selectedPlayerId;
                  setState(() => _selectedPlayerId = null);
                  notifier.submitCurrentNightTurn(selectedTargetId: target);
                }
              : null,
          child: const Text('تأكيد الحماية وإنهاء دوري 🛡️'),
        );

      case MafiaRole.detective:
        final hasChecked = state.detectiveCheckedId != null;
        if (!hasChecked) {
          return ElevatedButton(
            onPressed: _selectedPlayerId != null
                ? () {
                    final target = _selectedPlayerId;
                    setState(() => _selectedPlayerId = null);
                    notifier.submitCurrentNightTurn(selectedTargetId: target);
                  }
                : null,
            child: const Text('فحص هوية هذا اللاعب 🔍'),
          );
        } else {
          return ElevatedButton(
            onPressed: () {
              notifier.submitCurrentNightTurn();
            },
            child: const Text('فهمت، إنهاء دوري وتمرير الهاتف 🔒'),
          );
        }

      case MafiaRole.citizen:
        return ElevatedButton(
          onPressed: () {
            notifier.submitCurrentNightTurn();
          },
          child: const Text('إنهاء دوري وتمرير الهاتف 🌙'),
        );
    }
  }

  Widget _buildRoleHeader(String emoji, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. DAWN REPORT VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDawnReportView(
      MafiaGameState state, MafiaGameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text('🌅', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 16),
          const Text(
            'أشرقت الشمس على القرية!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: state.wasSavedByDoctor
                ? const Column(
                    children: [
                      Text('🛡️', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 12),
                      Text(
                        'استيقظ الجميع سالمين!',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'استطاع الطبيب بنجاح حماية الشخص المستهدف من قبل المافيا، ولم يمت أحد هذه الليلة!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Text('💀', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text(
                        'قامت المافيا بعملية اغتيال!',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.lastKilledPlayer != null
                            ? 'الضحية الليلة كان اللاعب: "${state.lastKilledPlayer!.name}"'
                            : 'لم تقع أي إصابات الليلة.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (state.lastKilledPlayer != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Text(
                            'الدور الحقيقي للضحية: ${state.lastKilledPlayer!.role.emoji} ${state.lastKilledPlayer!.role.titleAr}',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              _startTimer();
              notifier.proceedToDayDiscussion();
            },
            child: const Text('الانتقال للنقاش الصباحي 🗣️'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. DAY DISCUSSION VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDayDiscussionView(
      MafiaGameState state, MafiaGameNotifier notifier) {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الجولة الصباحية - وقت النقاش 🌅',
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'تناقشوا وتبادلوا الشكوك والتهم بحرية لمعرفة من هو المافيا بينكم!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'الوقت المتبقي للنقاش',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isTimerRunning
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        if (_isTimerRunning) {
                          _stopTimer();
                        } else {
                          _startTimer();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                      onPressed: _startTimer,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'اللاعبون الأحياء المتبقون:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              itemCount: state.alivePlayers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final player = state.alivePlayers[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(player.avatarColor),
                        child: Text(
                          player.name.isNotEmpty
                              ? player.name.characters.first
                              : '?',
                          style: const TextStyle(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        player.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              _stopTimer();
              notifier.proceedToDayVoting();
            },
            child: const Text('بدء التصويت الآن 🗳️'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. DAY VOTING VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDayVotingView(
      MafiaGameState state, MafiaGameNotifier notifier) {
    final candidates = state.alivePlayers;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'التصويت على المشتبه بهم 🗳️',
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اختاروا الشخص الذي اتفقت القرية على إعدامه، أو تخطوا التصويت:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: candidates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = candidates[index];
                final isSelected = _selectedPlayerId == player.id;

                return _buildSelectableTile(
                  name: player.name,
                  avatarColor: player.avatarColor,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedPlayerId = player.id),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _selectedPlayerId != null
                ? () {
                    final target = _selectedPlayerId!;
                    setState(() => _selectedPlayerId = null);
                    _confirmExecution(context, state, notifier, target);
                  }
                : null,
            child: const Text('إعدام المشتبه به ⚔️'),
          ),

          const SizedBox(height: 8),

          OutlinedButton(
            onPressed: () {
              setState(() => _selectedPlayerId = null);
              notifier.skipDayVoting();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorder),
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('تخطي التصويت دون إعدام أحد'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6. GAME OVER VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGameOverView(MafiaGameState state, MafiaGameNotifier notifier) {
    final isCitizensWin = state.winner == MafiaTeam.citizens;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              isCitizensWin ? '🧑‍🌾' : '💀',
              style: const TextStyle(fontSize: 64),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isCitizensWin
                ? 'فاز المواطنون الشرفاء! 🏆'
                : 'انتصرت المافيا وسيطرت على القرية! 🏆',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.pureWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.winnerReason ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),

          const Text(
            'نتائج اللاعبين والأدوار الحقيقية:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final player = state.players[index];
                final isWinner = player.role.team == state.winner && player.isAlive;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isWinner
                          ? AppColors.pureWhite
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(player.role.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: TextStyle(
                                color: player.isAlive
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                                decoration: player.isAlive
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '${player.role.titleAr} ${player.isAlive ? '(على قيد الحياة)' : '(مات)'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (player.score > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${player.score} نقطة',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              final globalPlayers = ref.read(playersProvider);
              notifier.startNewGame(globalPlayers);
            },
            child: const Text('لعب جولة أخرى 🔄'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorder),
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('العودة للقائمة الرئيسية 🏠'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper Widgets
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSelectableTile({
    required String name,
    required int avatarColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceLight : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.pureWhite : AppColors.surfaceBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(avatarColor),
                child: Text(
                  name.isNotEmpty ? name.characters.first : '?',
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.pureWhite, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExecution(
    BuildContext context,
    MafiaGameState state,
    MafiaGameNotifier notifier,
    String targetId,
  ) {
    final player = state.players.firstWhere((p) => p.id == targetId);
    final isMafia = player.role == MafiaRole.mafia;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
            borderRadius: BorderRadius.circular(18),
          ),
          title: Center(
            child: Text(
              player.role.emoji,
              style: const TextStyle(fontSize: 50),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تم إعدام: ${player.name}',
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  'الدور الحقيقي: ${player.role.emoji} ${player.role.titleAr}',
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isMafia
                    ? 'أحسنتم! تخلصت القرية من أحد أفراد المافيا! 💀'
                    : 'للأسف! لقد أعدمتم شخصاً بريئاً من أهل القرية! 🧑‍🌾',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isMafia ? AppColors.pureWhite : AppColors.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  notifier.executePlayer(targetId);
                },
                child: const Text('متابعة اللعبة 🌙'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.surfaceBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'إنهاء اللعبة؟',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في مغادرة اللعبة والعودة إلى القائمة؟ سيتم فقدان تقدم الجولة الحالية.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/home');
              },
              child: const Text(
                'خروج',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
