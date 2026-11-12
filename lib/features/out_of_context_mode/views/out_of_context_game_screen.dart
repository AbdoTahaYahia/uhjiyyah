import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/out_of_context_game_state.dart';
import '../providers/out_of_context_game_provider.dart';

class OutOfContextGameScreen extends ConsumerWidget {
  const OutOfContextGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(outOfContextGameProvider);

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
            title: const Text('خارج السياق '),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => _showExitDialog(context, ref),
            ),
          ),
          body: SafeArea(
            child: switch (gameState.phase) {
              OutOfContextPhase.reveal => _buildRevealView(context, ref, gameState),
              OutOfContextPhase.discussion => _buildDiscussionView(context, ref, gameState),
              OutOfContextPhase.voting => _buildVotingView(context, ref, gameState),
              OutOfContextPhase.imposterGuess => _buildImposterGuessView(context, ref, gameState),
              OutOfContextPhase.gameOver => _buildGameOverView(context, ref, gameState),
            },
          ),
        ),
      ),
    );
  }

  // ── 1. Reveal Phase ────────────────────────────────────────────────────────
  Widget _buildRevealView(BuildContext context, WidgetRef ref, OutOfContextGameState state) {
    if (state.players.isEmpty) {
      return const Center(child: Text('لا يوجد لاعبون', style: TextStyle(color: AppColors.textPrimary)));
    }

    final currentPlayer = state.players[state.currentRevealIndex];
    final isLastPlayer = state.currentRevealIndex == state.players.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Step progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اللاعب ${state.currentRevealIndex + 1} من ${state.players.length}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Text(
                currentPlayer.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (state.currentRevealIndex + 1) / state.players.length,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
              minHeight: 6,
            ),
          ),
          const Spacer(),

          // Card View
          GestureDetector(
            onTap: () => ref.read(outOfContextGameProvider.notifier).toggleCardReveal(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: state.isCardRevealed ? AppColors.surface : AppColors.surfaceBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.isCardRevealed ? AppColors.pureWhite : AppColors.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: state.isCardRevealed
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentPlayer.isOut ? ' خارج السياق!' : 'الكلمة السرية:',
                            style: TextStyle(
                              color: currentPlayer.isOut ? AppColors.pureWhite : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentPlayer.isOut ? 'أنت المتسلل!' : state.topic.secretWordAr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              currentPlayer.isOut
                                  ? 'التصنيف العام: ${state.topic.categoryAr} (راقب أسئلة الآخرين!)'
                                  : 'التصنيف: ${state.topic.categoryAr}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(currentPlayer.avatarColor),
                            child: Text(
                              currentPlayer.name.substring(0, 1),
                              style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'أعطِ الهاتف إلى ${currentPlayer.name}',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'المس الكرت لرؤية دورك سراً ',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const Spacer(),

          // Next Player Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: !state.isCardRevealed
                  ? null
                  : () => ref.read(outOfContextGameProvider.notifier).nextPlayer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isLastPlayer ? 'بدء النقاش ' : 'التالي (إخفاء البطاقة)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Discussion Phase ────────────────────────────────────────────────────
  Widget _buildDiscussionView(BuildContext context, WidgetRef ref, OutOfContextGameState state) {
    final minutes = state.secondsRemaining ~/ 60;
    final seconds = state.secondsRemaining % 60;
    final timeFormatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'فترة النقاش والأسئلة ',
            style: TextStyle(color: AppColors.pureWhite, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'اسألوا بعضكم بالتناوب أسئلة ذكية حول الكلمة لكشف من هو خارج السياق دون حرق الكلمة!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),

          // Big Timer Widget
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.pureWhite, width: 2),
            ),
            child: Text(
              timeFormatted,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pause / Resume Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  state.isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 44,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (state.isTimerRunning) {
                    ref.read(outOfContextGameProvider.notifier).pauseTimer();
                  } else {
                    ref.read(outOfContextGameProvider.notifier).resumeTimer();
                  }
                },
              ),
            ],
          ),
          const Spacer(),

          // Direct to voting button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ref.read(outOfContextGameProvider.notifier).startVoting(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('جاهزون للتصويت والاتهام ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Voting Phase ────────────────────────────────────────────────────────
  Widget _buildVotingView(BuildContext context, WidgetRef ref, OutOfContextGameState state) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'من تظن أنه خارج السياق؟',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.pureWhite, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'اتفقوا معاً واضغطوا على اسم اللاعب المشتبه به لإصدار الاتهام.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final player = state.players[index];
                return InkWell(
                  onTap: () => _confirmAccusation(context, ref, player.id, player.name),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(player.avatarColor),
                          radius: 18,
                          child: Text(
                            player.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Imposter Guess Phase ───────────────────────────────────────────────
  Widget _buildImposterGuessView(BuildContext context, WidgetRef ref, OutOfContextGameState state) {
    final imposter = state.players.firstWhere((p) => p.isOut);
    final options = [state.topic.secretWordAr, ...state.topic.decoyWordsAr]..shuffle();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                const Text(
                  ' كشفتم المتسلل!',
                  style: TextStyle(color: AppColors.pureWhite, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'المتسلل هو: ${imposter.name}',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'أمامك فرصة أخيرة يا متسلل! اختر الكلمة السرية الصحيحة لتنتصر:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final word = options[index];
                return InkWell(
                  onTap: () {
                    ref.read(outOfContextGameProvider.notifier).imposterGuessWord(word);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      word,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Game Over Phase ────────────────────────────────────────────────────
  Widget _buildGameOverView(BuildContext context, WidgetRef ref, OutOfContextGameState state) {
    final isCiviliansWin = state.winner == 'civilians';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            isCiviliansWin ? Icons.verified : Icons.theater_comedy,
            size: 80,
            color: AppColors.pureWhite,
          ),
          const SizedBox(height: 20),
          Text(
            isCiviliansWin ? 'فاز أهل السياق! ' : 'فاز المتسلل! ',
            style: const TextStyle(color: AppColors.pureWhite, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            state.winnerReason ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                const Text('الكلمة السرية كانت:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  state.topic.secretWordAr,
                  style: const TextStyle(color: AppColors.pureWhite, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(outOfContextGameProvider.notifier).startNewGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('جولة جديدة ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                ref.read(outOfContextGameProvider.notifier).resetGame();
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

  void _confirmAccusation(BuildContext context, WidgetRef ref, String playerId, String playerName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('اتهام $playerName', style: const TextStyle(color: AppColors.pureWhite)),
          content: Text(
            'هل أنتم متأكدون من اتهام $playerName بأنه خارج السياق؟',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(outOfContextGameProvider.notifier).accusePlayer(playerId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
              ),
              child: const Text('تأكيد الاتهام', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
            'هل تريد الخروج من اللعبة الحالية والعودة للقائمة الرئيسية؟',
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
                ref.read(outOfContextGameProvider.notifier).resetGame();
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
