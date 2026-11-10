import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';

/// Space-age player roster setup screen.
///
/// Features staggered entrance animations, local persistence, and sleek
/// deep space styling with red touches reserved strictly for delete actions.
class PlayersSetupScreen extends ConsumerStatefulWidget {
  const PlayersSetupScreen({super.key});

  @override
  ConsumerState<PlayersSetupScreen> createState() => _PlayersSetupScreenState();
}

class _PlayersSetupScreenState extends ConsumerState<PlayersSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(playersProvider.notifier).addPlayer(name);
    _nameController.clear();
    _focusNode.requestFocus();
  }

  void _removePlayer(String id) {
    ref.read(playersProvider.notifier).removePlayer(id);
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final canStart = players.length >= 2;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.7),
              radius: 1.3,
              colors: [
                Color(0xFF141424),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إعداد طاقم اللعبة 🚀',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                      if (players.isNotEmpty)
                        IconButton(
                          tooltip: 'مسح الكل',
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => _showClearConfirmation(context),
                        ).animate().fadeIn(duration: 300.ms),
                    ],
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    'أضف أسماء اللاعبين المشاركين في الجلسة',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(delay: 80.ms),

                  const SizedBox(height: 16),

                  // Futuristic Input Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: AppColors.textPrimary),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addPlayer(),
                          decoration: InputDecoration(
                            hintText: 'اسم اللاعب (مثال: سارة، أحمد...)',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _nameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.textMuted),
                                    onPressed: () {
                                      _nameController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _nameController.text.trim().isEmpty ? null : _addPlayer,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: _nameController.text.trim().isEmpty
                                ? AppColors.surfaceLight
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBorder),
                            boxShadow: _nameController.text.trim().isEmpty
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: _nameController.text.trim().isEmpty
                                ? AppColors.textMuted
                                : AppColors.background,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 22),

                  // Telemetry Status Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'قائمة اللاعبين',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          '${players.length} لاعبين',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 12),

                  // Staggered Players List
                  Expanded(
                    child: players.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.radar_outlined,
                                  size: 64,
                                  color: AppColors.textMuted.withValues(alpha: 0.4),
                                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                                const SizedBox(height: 16),
                                const Text(
                                  'لم تتم إضافة أي لاعب بعد',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'أضف لاعبين على الأقل للبدء (2 أو أكثر)',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: players.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final player = players[index];
                              final initial = player.name.isNotEmpty
                                  ? player.name.characters.first
                                  : '?';

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Color(player.avatarColor),
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          color: AppColors.pureWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        player.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: AppColors.danger,
                                        size: 22,
                                      ),
                                      tooltip: 'حذف',
                                      onPressed: () => _removePlayer(player.id),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 300.ms,
                                    delay: (index * 45).ms,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .slideX(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: (index * 45).ms,
                                    curve: Curves.easeOutCubic,
                                  );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Start Playing Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: canStart ? () => context.go('/home') : null,
                      child: Text(
                        canStart
                            ? 'الانطلاق للألعاب (${players.length}) 🚀'
                            : 'أضف لاعبين على الأقل للبدء',
                      ),
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
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
            'مسح جميع اللاعبين؟',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'سيتم حذف قائمة اللاعبين الحالية بالكامل.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(playersProvider.notifier).clearAll();
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'مسح',
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
