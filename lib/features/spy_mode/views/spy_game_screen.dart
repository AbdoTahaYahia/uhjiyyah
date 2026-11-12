import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import '../models/spy_game_state.dart';
import '../models/spy_locations.dart';
import '../providers/spy_game_provider.dart';

class SpyGameScreen extends ConsumerStatefulWidget {
  const SpyGameScreen({super.key});

  @override
  ConsumerState<SpyGameScreen> createState() => _SpyGameScreenState();
}

class _SpyGameScreenState extends ConsumerState<SpyGameScreen> {
  String? _selectedPlayerId;
  String? _selectedLocationGuess;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spyGameProvider);
    final notifier = ref.read(spyGameProvider.notifier);

    if (state.players.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/spy'),
            child: const Text('العودة لقوانين الجاسوس'),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('لعبة: الجاسوس 🕵️‍♂️'),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.danger),
            tooltip: 'إنهاء اللعبة',
            onPressed: () => _confirmExit(context),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildPhase(state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase(SpyGameState state, SpyGameNotifier notifier) {
    switch (state.phase) {
      case SpyGamePhase.reveal:
        return _buildRevealPhase(state, notifier);
      case SpyGamePhase.discussion:
        return _buildDiscussionPhase(state, notifier);
      case SpyGamePhase.voting:
        return _buildVotingPhase(state, notifier);
      case SpyGamePhase.spyGuessLocation:
        return _buildSpyGuessLocationPhase(state, notifier);
      case SpyGamePhase.gameOver:
        return _buildGameOverPhase(state, notifier);
    }
  }

  // 1. Reveal Phase
  Widget _buildRevealPhase(SpyGameState state, SpyGameNotifier notifier) {
    final player = state.players[state.currentRevealIndex];
    final isLast = state.currentRevealIndex == state.players.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'كشف الهوية: لاعب ${state.currentRevealIndex + 1} من ${state.players.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
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
                          Text(
                            player.isSpy ? '🕵️‍♂️' : state.location.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            player.isSpy
                                ? 'أنت الجاسوس!'
                                : 'المكان: ${state.location.nameAr}',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              player.isSpy
                                  ? 'لا أحد يعلم هويتك... استمع للأسئلة وخمن المكان!'
                                  : 'دورك في المكان: ${player.roleInLocation}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            ),
                          ),
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
                            player.name.characters.first,
                            style: const TextStyle(fontSize: 28, color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('مرر الهاتف إلى:', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          player.name,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '🔒 تأكد من سرية الشاشة قبل الضغط',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (!state.isCardRevealed) {
                notifier.toggleCard();
              } else {
                notifier.nextPlayer();
              }
            },
            child: Text(
              !state.isCardRevealed
                  ? 'كشف الهوية سراً 👁️'
                  : (isLast ? 'بدء وقت النقاش 🗣️' : 'إخفاء وتمرير للهاتف 🔒'),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Discussion Phase
  Widget _buildDiscussionPhase(SpyGameState state, SpyGameNotifier notifier) {
    final minutes = (state.secondsRemaining / 60).floor();
    final seconds = state.secondsRemaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'وقت التحقيق والنقاش 🕵️‍♂️',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
          ),
          const SizedBox(height: 4),
          const Text(
            'اسألوا بعضكم أسئلة ذكية لكشف الجاسوس دون ذكر اسم المكان مباشرة!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Digital Countdown
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                const Text('الوقت المتبقي', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  timeStr,
                  style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Icon(
                    state.isTimerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 36,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: notifier.toggleTimer,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          ElevatedButton(
            onPressed: notifier.startVoting,
            child: const Text('اشتباه وتصويت على الجاسوس 🗳️'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              // Spy steps forward to guess
              notifier.startVoting();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorder),
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('أنا الجاسوس وأريد تخمين المكان 🎯'),
          ),
        ],
      ),
    );
  }

  // 3. Voting Phase
  Widget _buildVotingPhase(SpyGameState state, SpyGameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'من تعتقدون أنه الجاسوس؟ 🗳️',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
          ),
          const SizedBox(height: 6),
          const Text(
            'اختاروا اللاعب الذي أجمعت القرية على اتهامه بالجاسوسية:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = state.players[index];
                final isSelected = _selectedPlayerId == player.id;

                return InkWell(
                  onTap: () => setState(() => _selectedPlayerId = player.id),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.pureWhite : AppColors.surfaceBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(player.avatarColor),
                          child: Text(player.name.characters.first, style: const TextStyle(color: AppColors.pureWhite)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: AppColors.pureWhite),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _selectedPlayerId != null
                ? () {
                    final target = _selectedPlayerId!;
                    setState(() => _selectedPlayerId = null);
                    notifier.submitVote(target);
                  }
                : null,
            child: const Text('تأكيد الاتهام 🎯'),
          ),
        ],
      ),
    );
  }

  // 4. Spy Guess Location Phase
  Widget _buildSpyGuessLocationPhase(SpyGameState state, SpyGameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تم كشف الجاسوس! 🚨',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.danger),
          ),
          const SizedBox(height: 6),
          const Text(
            'فرصة الجاسوس الأخيرة: اختر المكان السري الصحيح لتحقيق الفوز!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: kSpyLocations.length,
              itemBuilder: (context, index) {
                final loc = kSpyLocations[index];
                final isSelected = _selectedLocationGuess == loc.nameAr;

                return InkWell(
                  onTap: () => setState(() => _selectedLocationGuess = loc.nameAr),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.pureWhite : AppColors.surfaceBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(loc.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.nameAr,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _selectedLocationGuess != null
                ? () {
                    final guess = _selectedLocationGuess!;
                    setState(() => _selectedLocationGuess = null);
                    notifier.submitSpyGuess(guess);
                  }
                : null,
            child: const Text('تأكيد تخمين الجاسوس 🎯'),
          ),
        ],
      ),
    );
  }

  // 5. Game Over Phase
  Widget _buildGameOverPhase(SpyGameState state, SpyGameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text('🏆', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 16),
          Text(
            'الفائز: ${state.winner}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                Text('المكان السري كان: ${state.location.emoji} ${state.location.nameAr}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.pureWhite)),
                const SizedBox(height: 6),
                Text(
                  'الجاسوس كان: ${state.players.firstWhere((p) => p.isSpy).name}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final globalPlayers = ref.read(playersProvider);
              notifier.startNewGame(globalPlayers);
            },
            child: const Text('لعب جولة أخرى 🔄'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorder),
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('العودة للقائمة الرئيسية 🏠'),
          ),
        ],
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
          title: const Text('مغادرة اللعبة؟', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text('هل أنت متأكد من مغادرة اللعبة والعودة للقائمة؟', style: TextStyle(color: AppColors.textSecondary)),
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
              child: const Text('خروج', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
