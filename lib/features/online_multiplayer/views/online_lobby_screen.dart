import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import 'package:uhjiyyah/core/widgets/player_avatar.dart';
import '../providers/online_room_provider.dart';

class OnlineLobbyScreen extends ConsumerStatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  ConsumerState<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends ConsumerState<OnlineLobbyScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedLocalPlayerId;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localPlayers = ref.watch(playersProvider);
    final roomState = ref.watch(onlineRoomProvider);

    // Default name if none set
    if (_nameController.text.isEmpty && localPlayers.isNotEmpty) {
      _nameController.text = localPlayers.first.name;
      _selectedLocalPlayerId = localPlayers.first.id;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('اللعب الجماعي أونلاين'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header
              Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.pureWhite, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.wifi, size: 36, color: AppColors.pureWhite),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.05, 1.05),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: 16),
                  const Text(
                    'غرف اللعب أونلاين',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 6),
                  const Text(
                    'العب مع أصدقائك عبر أجهزة مختلفة في نفس الوقت عن بُعد!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
              const SizedBox(height: 28),

              // Player Name Field / Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اسمك في الغرفة:',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسمك هنا...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                    ),
                    if (localPlayers.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'أو اختر من لاعبيك المسجلين:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: localPlayers.map((p) {
                          final isSelected = _selectedLocalPlayerId == p.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedLocalPlayerId = p.id;
                                _nameController.text = p.name;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Chip(
                              backgroundColor: isSelected ? AppColors.pureWhite : AppColors.background,
                              side: BorderSide(
                                color: isSelected ? AppColors.pureWhite : AppColors.surfaceBorder,
                              ),
                              avatar: PlayerAvatar(
                                name: p.name,
                                radius: 10,
                                iconColor: isSelected ? AppColors.background : AppColors.pureWhite,
                              ),
                              label: Text(
                                p.name,
                                style: TextStyle(
                                  color: isSelected ? AppColors.background : AppColors.pureWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (roomState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Text(
                    roomState.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Create Room Option
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'إنشاء غرفة جديدة',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'أنشئ غرفة وشارك الرمز مع أصدقائك لبدء اللعبة سوياً.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: roomState.isLoading
                            ? null
                            : () async {
                                final name = _nameController.text.trim();
                                if (name.isEmpty) return;
                                final id = _selectedLocalPlayerId ?? const Uuid().v4();

                                final success = await ref.read(onlineRoomProvider.notifier).createRoom(
                                      hostName: name,
                                      hostId: id,
                                    );
                                if (success && context.mounted) {
                                  context.push('/online/room');
                                }
                              },
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          roomState.isLoading ? 'جاري الإنشاء...' : 'إنشاء الغرفة الآن',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pureWhite,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Random Match Option
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.pureWhite, width: 1.3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Icon(Icons.shuffle, color: AppColors.pureWhite, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دخول عشوائي سريع',
                              style: TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'انضم لأي غرفة مفتوحة بانتظار لاعبين فوراً',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: roomState.isLoading
                            ? null
                            : () async {
                                final name = _nameController.text.trim();
                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('يرجى كتابة اسمك أولاً للدخول العشوائي')),
                                  );
                                  return;
                                }
                                final id = _selectedLocalPlayerId ?? const Uuid().v4();
                                final success = await ref.read(onlineRoomProvider.notifier).joinRandomRoom(
                                      playerName: name,
                                      playerId: id,
                                    );
                                if (success && context.mounted) {
                                  context.push('/online/room');
                                }
                              },
                        icon: const Icon(Icons.bolt, size: 20),
                        label: Text(
                          roomState.isLoading ? 'جاري البحث عن غرفة...' : 'بحث ودخول عشوائي الآن',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.pureWhite,
                          side: const BorderSide(color: AppColors.pureWhite, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Join Room Option
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'الانضمام لغرفة قائمة',
                      style: TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'أدخل الرمز المكون من 5 خانات الذي شاركه معك المضيف:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                            decoration: InputDecoration(
                              hintText: 'مثلاً: UH72X',
                              hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 1),
                              filled: true,
                              fillColor: AppColors.background,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.surfaceBorder),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: roomState.isLoading
                                ? null
                                : () async {
                                    final name = _nameController.text.trim();
                                    final code = _codeController.text.trim();
                                    if (name.isEmpty || code.isEmpty) return;
                                    final id = _selectedLocalPlayerId ?? const Uuid().v4();

                                    final success = await ref.read(onlineRoomProvider.notifier).joinRoom(
                                          code: code,
                                          playerName: name,
                                          playerId: id,
                                        );
                                    if (success && context.mounted) {
                                      context.push('/online/room');
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.pureWhite),
                              foregroundColor: AppColors.pureWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('انضمام', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
