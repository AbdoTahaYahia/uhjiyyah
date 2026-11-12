import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uhjiyyah/core/models/game_modes_registry.dart';
import 'package:uhjiyyah/core/theme/app_theme.dart';
import 'package:uhjiyyah/core/widgets/player_avatar.dart';
import '../providers/online_room_provider.dart';

class OnlineRoomScreen extends ConsumerWidget {
  const OnlineRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onlineRoomProvider);
    final room = state.room;

    if (room == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('تم مغادرة الغرفة', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pureWhite, foregroundColor: AppColors.background),
                  child: const Text('العودة للرئيسية'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isHost = state.isHost;
    final selectedGame = kGameModes.firstWhere(
      (m) => m.id == room.gameModeId,
      orElse: () => kGameModes.first,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _showLeaveDialog(context, ref);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('صالة الغرفة أونلاين'),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => _showLeaveDialog(context, ref),
            ),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: room.messages.isNotEmpty,
                  label: Text('${room.messages.length}'),
                  backgroundColor: AppColors.pureWhite,
                  textColor: AppColors.background,
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.pureWhite),
                ),
                tooltip: 'المحادثة اللحظية',
                onPressed: () => _showChatModal(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Room Code Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.pureWhite, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('رمز الغرفة:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              room.code,
                              style: const TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: room.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ رمز الغرفة بنجاح!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, color: AppColors.pureWhite),
                          tooltip: 'نسخ الرمز',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected Game Card / Selector
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'اللعبة المختارة:',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            if (isHost)
                              const Text(
                                '(أنت المضيف - يمكنك تغيير اللعبة)',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (isHost)
                          DropdownButtonFormField<String>(
                            initialValue: room.gameModeId,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.surfaceBorder),
                              ),
                            ),
                            items: kGameModes.map((mode) {
                              return DropdownMenuItem(
                                value: mode.id,
                                child: Text(mode.titleAr),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(onlineRoomProvider.notifier).changeGameMode(val);
                              }
                            },
                          )
                        else
                          Row(
                            children: [
                              Icon(selectedGame.icon, color: AppColors.pureWhite, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                selectedGame.titleAr,
                                style: const TextStyle(color: AppColors.pureWhite, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Players in Room
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'اللاعبون المتصلون (${room.players.length}):',
                        style: const TextStyle(color: AppColors.pureWhite, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'مزامنة سحابية حية',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.separated(
                      itemCount: room.players.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final player = room.players[index];
                        final isMe = player.id == state.myPlayerId;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMe ? AppColors.pureWhite : AppColors.surfaceBorder,
                              width: isMe ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              PlayerAvatar(name: player.name, radius: 18, showInitialBadge: true),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          player.name,
                                          style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                                        ),
                                        if (isMe)
                                          const Text(' (أنت)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                    if (player.isHost)
                                      const Text('المضيف (Host)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ),
                              if (player.isReady)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: const Text('جاهز', style: TextStyle(color: AppColors.pureWhite, fontSize: 12)),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Live Chat Bar Preview
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _showChatModal(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.pureWhite),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              room.messages.isEmpty
                                  ? 'المحادثة اللحظية للغرفة (اضغط للكتابة)'
                                  : '${room.messages.last.senderName}: ${room.messages.last.text}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                          if (room.messages.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Text(
                                '${room.messages.length}',
                                style: const TextStyle(color: AppColors.pureWhite, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  const SizedBox(height: 12),
                  if (isHost)
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: room.players.length >= selectedGame.minPlayers
                            ? () {
                                ref.read(onlineRoomProvider.notifier).startGame();
                                // Navigate to the selected game mode route
                                context.push(selectedGame.routeName);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pureWhite,
                          foregroundColor: AppColors.background,
                          disabledBackgroundColor: AppColors.surfaceBorder,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          room.players.length < selectedGame.minPlayers
                              ? 'يلزم ${selectedGame.minPlayers} لاعبين على الأقل للبدء'
                              : 'بدء اللعبة للجميع الآن',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => ref.read(onlineRoomProvider.notifier).toggleReady(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pureWhite,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('أنا جاهز للبدء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('مغادرة الغرفة', style: TextStyle(color: AppColors.pureWhite)),
          content: const Text(
            'هل تريد مغادرة هذه الغرفة والعودة إلى القائمة الرئيسية؟',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(onlineRoomProvider.notifier).leaveRoom();
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('مغادرة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _RoomChatSheet(),
    );
  }
}

class _RoomChatSheet extends ConsumerStatefulWidget {
  const _RoomChatSheet();

  @override
  ConsumerState<_RoomChatSheet> createState() => _RoomChatSheetState();
}

class _RoomChatSheetState extends ConsumerState<_RoomChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(onlineRoomProvider.notifier).sendChatMessage(text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(onlineRoomProvider).room;
    final myId = ref.watch(onlineRoomProvider).myPlayerId;
    final messages = room?.messages ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.pureWhite, width: 1.5),
            left: BorderSide(color: AppColors.surfaceBorder),
            right: BorderSide(color: AppColors.surfaceBorder),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: AppColors.pureWhite, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'محادثة الغرفة اللحظية',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          '${messages.length}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            // Messages list
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد رسائل بعد.\nابدأ المحادثة مع زملائك في الغرفة!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == myId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment:
                                isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isMe) ...[
                                PlayerAvatar(name: msg.senderName, radius: 14),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        isMe ? 'أنت' : msg.senderName,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? AppColors.pureWhite
                                            : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isMe
                                              ? AppColors.pureWhite
                                              : AppColors.surfaceBorder,
                                        ),
                                      ),
                                      child: Text(
                                        msg.text,
                                        style: TextStyle(
                                          color: isMe
                                              ? AppColors.background
                                              : AppColors.pureWhite,
                                          fontSize: 14,
                                          fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMe) ...[
                                const SizedBox(width: 8),
                                PlayerAvatar(name: msg.senderName, radius: 14),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            // Input row
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(color: AppColors.pureWhite),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة للغرفة...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.pureWhite,
                        foregroundColor: AppColors.background,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 20),
                      tooltip: 'إرسال',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
