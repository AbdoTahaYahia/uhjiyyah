import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/who_among_us_game_state.dart';
import '../providers/who_among_us_game_provider.dart';

class WhoAmongUsGameScreen extends ConsumerWidget {
  const WhoAmongUsGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(whoAmongUsGameProvider);

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
            title: const Text('مين فينا '),
            actions: [
              if (state.phase != WhoAmongUsPhase.leaderboard)
                IconButton(
                  icon: const Icon(Icons.leaderboard_outlined, color: AppColors.textPrimary),
                  onPressed: () => ref.read(whoAmongUsGameProvider.notifier).showLeaderboard(),
                ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => _showExitDialog(context, ref),
            ),
          ),
          body: SafeArea(
            child: switch (state.phase) {
              WhoAmongUsPhase.questionDisplay => _buildQuestionView(context, ref, state),
              WhoAmongUsPhase.voting => _buildVotingView(context, ref, state),
              WhoAmongUsPhase.results => _buildResultsView(context, ref, state),
              WhoAmongUsPhase.leaderboard => _buildLeaderboardView(context, ref, state),
            },
          ),
        ),
      ),
    );
  }

  // ── 1. Question Display View ───────────────────────────────────────────────
  Widget _buildQuestionView(BuildContext context, WidgetRef ref, WhoAmongUsGameState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سؤال ${state.currentQuestionIndex + 1} من ${state.questionsPool.length}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const Text('اقرأ السؤال بصوت عالٍ ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.help_outline, size: 48, color: AppColors.pureWhite),
                const SizedBox(height: 20),
                Text(
                  state.currentQuestion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ref.read(whoAmongUsGameProvider.notifier).beginVoting(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('بدء التصويت السري ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Pass & Play Voting View ─────────────────────────────────────────────
  Widget _buildVotingView(BuildContext context, WidgetRef ref, WhoAmongUsGameState state) {
    final currentVoter = state.players[state.currentVoterIndex];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Voter Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(currentVoter.avatarColor),
                  radius: 16,
                  child: Text(
                    currentVoter.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دور المصوّت: ${currentVoter.name}',
                        style: const TextStyle(color: AppColors.pureWhite, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'اختر الشخص الأنسب بدون أن يرى الآخرون!',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${state.currentVoterIndex + 1}/${state.players.length}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            state.currentQuestion,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final candidate = state.players[index];
                return InkWell(
                  onTap: () {
                    ref.read(whoAmongUsGameProvider.notifier).castVote(candidate.id);
                  },
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
                        const Icon(Icons.check_circle_outline, color: AppColors.textSecondary, size: 20),
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

  // ── 3. Results View ────────────────────────────────────────────────────────
  Widget _buildResultsView(BuildContext context, WidgetRef ref, WhoAmongUsGameState state) {
    final winnerPlayer = state.players.firstWhere(
      (p) => p.id == state.roundWinnerId,
      orElse: () => state.players.first,
    );
    final winnerVotes = state.roundVotes[state.roundWinnerId] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Winner Announcement Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                const Text('الشخص المختار', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                CircleAvatar(
                  backgroundColor: Color(winnerPlayer.avatarColor),
                  radius: 28,
                  child: Text(
                    winnerPlayer.name.substring(0, 1),
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  winnerPlayer.name,
                  style: const TextStyle(color: AppColors.pureWhite, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'حصل على $winnerVotes من أصل ${state.players.length} أصوات!',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'تفاصيل التصويت بالكامل:',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final player = state.players[index];
                final votes = state.roundVotes[player.id] ?? 0;
                final percentage = state.players.isNotEmpty ? votes / state.players.length : 0.0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(player.name, style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.w600)),
                          Text('$votes أصوات', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                          minHeight: 5,
                        ),
                      ),
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
              onPressed: () => ref.read(whoAmongUsGameProvider.notifier).nextQuestion(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('السؤال التالي ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Leaderboard View ───────────────────────────────────────────────────
  Widget _buildLeaderboardView(BuildContext context, WidgetRef ref, WhoAmongUsGameState state) {
    final sortedPlayers = List.of(state.players)
      ..sort((a, b) {
        final votesA = state.totalVotes[a.id] ?? 0;
        final votesB = state.totalVotes[b.id] ?? 0;
        return votesB.compareTo(votesA);
      });

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'لوحة صدارة الأصوات ',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.pureWhite, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'الترتيب الإجمالي لجميع الأسئلة التي تم التصويت عليها',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: sortedPlayers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final total = state.totalVotes[player.id] ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: index == 0 ? AppColors.pureWhite : AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: index == 0 ? AppColors.pureWhite : AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      CircleAvatar(
                        backgroundColor: Color(player.avatarColor),
                        radius: 16,
                        child: Text(
                          player.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          player.name,
                          style: const TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '$total صوت',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                ref.read(whoAmongUsGameProvider.notifier).reset();
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
                ref.read(whoAmongUsGameProvider.notifier).reset();
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
