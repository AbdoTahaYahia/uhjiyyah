import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/charades_game_state.dart';
import '../providers/charades_game_provider.dart';

class CharadesGameScreen extends ConsumerWidget {
  const CharadesGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(charadesGameProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _showExitDialog(context, ref);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('تمثيل (بدون كلام) '),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => _showExitDialog(context, ref),
            ),
          ),
          body: SafeArea(
            child: switch (state.phase) {
              CharadesPhase.teamSetup => const SizedBox.shrink(),
              CharadesPhase.roundReady => _buildRoundReadyView(context, ref, state),
              CharadesPhase.acting => _buildActingView(context, ref, state),
              CharadesPhase.roundSummary => _buildRoundSummaryView(context, ref, state),
              CharadesPhase.gameOver => _buildGameOverView(context, ref, state),
            },
          ),
        ),
      ),
    );
  }

  // ── 1. Round Ready View ────────────────────────────────────────────────────
  Widget _buildRoundReadyView(BuildContext context, WidgetRef ref, CharadesGameState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Score summary bar
          _buildScoreHeader(state),
          const Spacer(),

          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'الجولة ${state.currentRound} من ${state.totalRounds}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  'الدور على: ${state.currentActiveTeamName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.pureWhite, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'سلّم الهاتف للممثل من هذا الفريق ليطّلع على الكلمة سراً.\nأمامك 90 ثانية لتمثيلها بدون كلام!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => ref.read(charadesGameProvider.notifier).startTurn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('أنا الممثل، أظهر الكلمة وابدأ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Acting View ─────────────────────────────────────────────────────────
  Widget _buildActingView(BuildContext context, WidgetRef ref, CharadesGameState state) {
    return Column(
      children: [
        // Score Header & Timer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  state.currentActiveTeamName,
                  style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.pureWhite, width: 1.5),
                ),
                child: Text(
                  '${state.secondsRemaining} ثانية',
                  style: const TextStyle(color: AppColors.pureWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Secret Card Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Text(
                      'التصنيف: ${state.currentCard.categoryAr}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    state.currentCard.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    ' ممنوع الكلام أو الإشارة للحروف!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () => ref.read(charadesGameProvider.notifier).teamFailedOrTimedOut(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('لم ينجح / تخطي ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => ref.read(charadesGameProvider.notifier).teamGuessedCorrectly(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('عرفوها! (+1) ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3. Round Summary View ──────────────────────────────────────────────────
  Widget _buildRoundSummaryView(BuildContext context, WidgetRef ref, CharadesGameState state) {
    final success = state.lastRoundSuccess ?? false;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildScoreHeader(state),
          const Spacer(),

          Icon(
            success ? Icons.check_circle_outline : Icons.highlight_off,
            size: 72,
            color: success ? AppColors.pureWhite : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            success ? 'أحسنتم! نقطة إضافية ' : 'حظ أوفر في الجولة القادمة!',
            style: const TextStyle(color: AppColors.pureWhite, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'كانت الكلمة: "${state.currentCard.title}"',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ref.read(charadesGameProvider.notifier).nextTurn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('الدور التالي ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Game Over View ──────────────────────────────────────────────────────
  Widget _buildGameOverView(BuildContext context, WidgetRef ref, CharadesGameState state) {
    String winnerText;
    if (state.teamAScore > state.teamBScore) {
      winnerText = 'الفائز: ${state.teamAName} ';
    } else if (state.teamBScore > state.teamAScore) {
      winnerText = 'الفائز: ${state.teamBName} ';
    } else {
      winnerText = 'تعادل بين الفريقين! ';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(Icons.emoji_events_outlined, size: 84, color: AppColors.pureWhite),
          const SizedBox(height: 20),
          Text(
            winnerText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.pureWhite, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildScoreHeader(state),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(charadesGameProvider.notifier).setupTeams(
                      teamAName: state.teamAName,
                      teamBName: state.teamBName,
                      totalRounds: state.totalRounds,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('مباراة جديدة ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                ref.read(charadesGameProvider.notifier).reset();
                context.go('/home');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceBorder),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(CharadesGameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(state.teamAName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${state.teamAScore}',
                style: const TextStyle(color: AppColors.pureWhite, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Text('VS', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16)),
          Column(
            children: [
              Text(state.teamBName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${state.teamBScore}',
                style: const TextStyle(color: AppColors.pureWhite, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('إنهاء اللعبة', style: TextStyle(color: AppColors.pureWhite)),
          content: const Text(
            'هل تريد الخروج والعودة للقائمة الرئيسية؟',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('متابعة اللعب', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(charadesGameProvider.notifier).reset();
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('خروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
