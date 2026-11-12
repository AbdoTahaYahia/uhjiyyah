import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/wink_game_state.dart';
import '../providers/wink_game_provider.dart';

class WinkGameScreen extends ConsumerWidget {
  const WinkGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(winkGameProvider);

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
            title: const Text('الغمزة 👁️'),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => _showExitDialog(context, ref),
            ),
          ),
          body: SafeArea(
            child: switch (state.phase) {
              WinkPhase.roleReveal => _buildRoleRevealView(context, ref, state),
              WinkPhase.inGame => _buildInGameView(context, ref, state),
              WinkPhase.detectiveAccusing => _buildAccusingView(context, ref, state),
              WinkPhase.gameOver => _buildGameOverView(context, ref, state),
            },
          ),
        ),
      ),
    );
  }

  // ── 1. Role Reveal View ────────────────────────────────────────────────────
  Widget _buildRoleRevealView(BuildContext context, WidgetRef ref, WinkGameState state) {
    if (state.players.isEmpty) return const SizedBox.shrink();

    final currentPlayer = state.players[state.currentRevealIndex];
    final isLastPlayer = state.currentRevealIndex == state.players.length - 1;

    String roleName;
    String roleDesc;
    IconData roleIcon;

    switch (currentPlayer.role) {
      case WinkRole.detective:
        roleName = 'المحقق 🔍';
        roleDesc = 'أنت مكشوف للجميع! مهمتك مراقبة عيون اللاعبين وكشف من يغمز.';
        roleIcon = Icons.search;
      case WinkRole.winker:
        roleName = 'الغامز 😉';
        roleDesc = 'سرّي للغاية! اغمز للاعبين بعينك لإقصائهم دون أن يراك المحقق.';
        roleIcon = Icons.visibility;
      case WinkRole.citizen:
        roleName = 'مواطن 👥';
        roleDesc = 'إذا تم الغمز لك، انتظر 5 ثوانٍ ثم أعلن إقصاءك!';
        roleIcon = Icons.person_outline;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
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

          GestureDetector(
            onTap: () => ref.read(winkGameProvider.notifier).toggleCardReveal(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 290,
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
                          Icon(roleIcon, size: 48, color: AppColors.pureWhite),
                          const SizedBox(height: 12),
                          Text(
                            roleName,
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            roleDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
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
                            'المس الكرت لرؤية دورك سراً 🔒',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: !state.isCardRevealed
                  ? null
                  : () => ref.read(winkGameProvider.notifier).nextPlayer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isLastPlayer ? 'بدء اللعب في الدائرة 👁️' : 'التالي (إخفاء الدور)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. In-Game View ────────────────────────────────────────────────────────
  Widget _buildInGameView(BuildContext context, WidgetRef ref, WinkGameState state) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Detective and status header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.pureWhite, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المحقق: ${state.detective.name}',
                        style: const TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'محاولات الاتهام المتبقية: ${state.remainingAccusations}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'حالة اللاعبين (المس لإقصاء من غُمِز له):',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = state.players[index];
                final isDetective = player.role == WinkRole.detective;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: player.isAlive ? AppColors.surface : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: player.isAlive ? AppColors.surfaceBorder : AppColors.surfaceBorder.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: player.isAlive ? Color(player.avatarColor) : Colors.grey,
                        radius: 16,
                        child: Text(
                          player.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: TextStyle(
                                color: player.isAlive ? AppColors.pureWhite : AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: player.isAlive ? null : TextDecoration.lineThrough,
                              ),
                            ),
                            if (isDetective)
                              const Text('المحقق الرسمي', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      if (!isDetective && player.isAlive)
                        OutlinedButton(
                          onPressed: () => _confirmElimination(context, ref, player.id, player.name),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text('إقصاء (غمز لي) 💀', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        )
                      else if (!player.isAlive)
                        const Text('تم إقصاؤه', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ref.read(winkGameProvider.notifier).openDetectiveAccusation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('🔍 المحقق مستعد للاتهام!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Accusing View ───────────────────────────────────────────────────────
  Widget _buildAccusingView(BuildContext context, WidgetRef ref, WinkGameState state) {
    final eligibleCandidates =
        state.players.where((p) => p.role != WinkRole.detective && p.isAlive).toList();

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
                  'اتهام المحقق 🔍',
                  style: TextStyle(color: AppColors.pureWhite, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'يا ${state.detective.name}، من هو الغامز؟ (متبقي لديك ${state.remainingAccusations} محاولات)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: eligibleCandidates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final candidate = eligibleCandidates[index];
                return InkWell(
                  onTap: () => _confirmAccuse(context, ref, candidate.id, candidate.name),
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
                          backgroundColor: Color(candidate.avatarColor),
                          radius: 18,
                          child: Text(
                            candidate.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            candidate.name,
                            style: const TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => ref.read(winkGameProvider.notifier).cancelAccusation(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceBorder),
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تراجع والعودة للمراقبة'),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Game Over View ──────────────────────────────────────────────────────
  Widget _buildGameOverView(BuildContext context, WidgetRef ref, WinkGameState state) {
    final isDetectiveWin = state.winner == 'detective';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            isDetectiveWin ? Icons.verified : Icons.visibility,
            size: 80,
            color: AppColors.pureWhite,
          ),
          const SizedBox(height: 20),
          Text(
            isDetectiveWin ? 'فاز المحقق والمواطنون! 🏆' : 'فاز الغامز المخاتل! 👁️',
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المحقق كان:', style: TextStyle(color: AppColors.textSecondary)),
                    Text(state.detective.name, style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: AppColors.surfaceBorder, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الغامز السري كان:', style: TextStyle(color: AppColors.textSecondary)),
                    Text(state.winker.name, style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
                  ],
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
                ref.read(winkGameProvider.notifier).startNewGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('جولة جديدة 🔄', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                ref.read(winkGameProvider.notifier).reset();
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

  void _confirmElimination(BuildContext context, WidgetRef ref, String playerId, String playerName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('إقصاء $playerName', style: const TextStyle(color: AppColors.pureWhite)),
          content: Text(
            'هل تم الغمز لك من قبل الغامز وتريد إعلان إقصائك الآن؟',
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
                ref.read(winkGameProvider.notifier).eliminatePlayer(playerId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pureWhite, foregroundColor: AppColors.background),
              child: const Text('تأكيد الإقصاء', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAccuse(BuildContext context, WidgetRef ref, String playerId, String playerName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('اتهام $playerName', style: const TextStyle(color: AppColors.pureWhite)),
          content: Text(
            'هل أنت متأكد يا محقق من اتهام $playerName بأنه الغامز؟',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تراجع', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(winkGameProvider.notifier).makeAccusation(playerId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pureWhite, foregroundColor: AppColors.background),
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
                ref.read(winkGameProvider.notifier).reset();
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
