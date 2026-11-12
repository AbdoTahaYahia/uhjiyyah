import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/heads_up_game_state.dart';
import '../providers/heads_up_game_provider.dart';

class HeadsUpGameScreen extends ConsumerWidget {
  const HeadsUpGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(headsUpGameProvider);

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
            title: Text(state.selectedCategory.nameAr),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => _showExitDialog(context, ref),
            ),
          ),
          body: SafeArea(
            child: switch (state.phase) {
              HeadsUpGamePhase.categorySelection => const SizedBox.shrink(),
              HeadsUpGamePhase.readyToPlay => _buildReadyView(context, ref, state),
              HeadsUpGamePhase.playing => _buildPlayingView(context, ref, state),
              HeadsUpGamePhase.roundSummary => _buildSummaryView(context, ref, state),
            },
          ),
        ),
      ),
    );
  }

  // ── Ready View ─────────────────────────────────────────────────────────────
  Widget _buildReadyView(BuildContext context, WidgetRef ref, HeadsUpGameState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            state.selectedCategory.icon,
            size: 72,
            color: AppColors.pureWhite,
          ),
          const SizedBox(height: 20),
          Text(
            state.selectedCategory.nameAr,
            style: const TextStyle(color: AppColors.pureWhite, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'ارفع الهاتف على جبهتك بحيث يرى أصدقاؤك الشاشة!\nأمامك 60 ثانية لتخمين أكبر عدد من الكلمات.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => ref.read(headsUpGameProvider.notifier).startRound(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ابدأ العداد الآن (60 ثانية)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Playing View ───────────────────────────────────────────────────────────
  Widget _buildPlayingView(BuildContext context, WidgetRef ref, HeadsUpGameState state) {
    return Column(
      children: [
        // Top Bar: Timer and Score
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.pureWhite, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${state.secondsRemaining} ثانية',
                      style: const TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.pureWhite, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'النقاط: ${state.score}',
                      style: const TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Big Word Display Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
              child: Center(
                child: Text(
                  state.currentWord,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Action Buttons: Pass and Correct
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: OutlinedButton(
                    onPressed: () => ref.read(headsUpGameProvider.notifier).passWord(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('تخطي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => ref.read(headsUpGameProvider.notifier).markCorrect(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('صح (+1)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Round Summary View ────────────────────────────────────────────────────
  Widget _buildSummaryView(BuildContext context, WidgetRef ref, HeadsUpGameState state) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'انتهى الوقت!',
                  style: TextStyle(color: AppColors.pureWhite, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'مجموع النقاط: ${state.score}',
                  style: const TextStyle(color: AppColors.pureWhite, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'نتائج الكلمات في هذه الجولة:',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                if (state.correctWords.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('كلمات تمت الإجابة عليها:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  ...state.correctWords.map((word) => _buildResultTile(word, true)),
                  const SizedBox(height: 12),
                ],
                if (state.passedWords.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('كلمات تم تخطيها:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  ...state.passedWords.map((word) => _buildResultTile(word, false)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(headsUpGameProvider.notifier).selectCategory(state.selectedCategory);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('العب مرة أخرى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                ref.read(headsUpGameProvider.notifier).reset();
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

  Widget _buildResultTile(String word, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(word, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          Icon(
            isCorrect ? Icons.check_circle_outline : Icons.remove_circle_outline,
            color: isCorrect ? AppColors.pureWhite : AppColors.textSecondary,
            size: 18,
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
                ref.read(headsUpGameProvider.notifier).reset();
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
