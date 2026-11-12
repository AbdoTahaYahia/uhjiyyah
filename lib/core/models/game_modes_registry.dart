import 'package:flutter/material.dart';

import 'game_mode.dart';

/// Master registry of all available game modes in the Uhjiyyah app.
///
/// Each entry defines the mode's bilingual metadata, player limits,
/// icon, and navigation route.
final List<GameMode> kGameModes = [
  // ── 1. Mafia ────────────────────────────────────────────────────────────
  const GameMode(
    id: 'mafia',
    titleAr: 'مافيا',
    titleEn: 'Mafia',
    descriptionAr:
        'لعبة أدوار خفية وخداع؛ يحاول أفراد المافيا القضاء على أهل القرية بينما يحاول المواطنون كشفهم والتصويت لإقصائهم.',
    descriptionEn:
        'A hidden-role game where the Mafia tries to eliminate civilians while civilians discuss, deduce, and vote to uncover the Mafia.',
    icon: Icons.shield,
    minPlayers: 4,
    maxPlayers: 12,
    isAvailable: true,
    routeName: '/mafia',
  ),

  // ── 2. Spy ──────────────────────────────────────────────────────────────
  const GameMode(
    id: 'spy',
    titleAr: 'الجاسوس',
    titleEn: 'Spy',
    descriptionAr:
        'يعرف الجميع المكان السري إلا الجاسوس. اسألوا بعضكم أسئلة ذكية '
        'لكشف الجاسوس بينما يحاول هو معرفة المكان.',
    descriptionEn:
        'Everyone knows the secret location except the Spy. Ask clever '
        'questions to find the Spy before the Spy figures out the location.',
    icon: Icons.person_search,
    minPlayers: 3,
    isAvailable: true,
    routeName: '/spy',
  ),

  // ── 3. Out of Context ───────────────────────────────────────────────────
  const GameMode(
    id: 'out-of-context',
    titleAr: 'خارج السياق',
    titleEn: 'Out of Context',
    descriptionAr:
        'يحصل جميع اللاعبين على كلمة سرية ما عدا لاعب واحد، والهدف هو '
        'اكتشاف من هو اللاعب الذي لا يعرف الكلمة.',
    descriptionEn:
        'All players receive a secret word except one. Everyone asks and '
        'answers questions trying to find who is out of context.',
    icon: Icons.chat_bubble_outline,
    minPlayers: 3,
    isAvailable: true,
    routeName: '/out-of-context',
  ),

  // ── 4. Heads Up ─────────────────────────────────────────────────────────
  const GameMode(
    id: 'heads-up',
    titleAr: 'احزر الكلمة',
    titleEn: 'Heads Up',
    descriptionAr:
        'ارفع الهاتف فوق رأسك وحاول تخمين الكلمة المعروضة من خلال '
        'تلميحات أصدقائك قبل انتهاء الوقت.',
    descriptionEn:
        'Hold the phone above your head and guess the word on screen '
        'from your friends\' clues before the timer runs out.',
    icon: Icons.phone_android,
    minPlayers: 2,
    isAvailable: true,
    routeName: '/heads-up',
  ),

  // ── 5. Who Among Us ─────────────────────────────────────────────────────
  const GameMode(
    id: 'who-among-us',
    titleAr: 'مين فينا',
    titleEn: 'Who Among Us',
    descriptionAr:
        'يُطرح سؤال على المجموعة ويصوّت الجميع سرًا لاختيار الشخص '
        'الأنسب للإجابة. اكتشفوا ماذا يعتقد أصدقاؤكم عنكم!',
    descriptionEn:
        'A question is asked and everyone secretly votes for who best '
        'fits the answer. Discover what your friends really think!',
    icon: Icons.people,
    minPlayers: 3,
    isAvailable: true,
    routeName: '/who-among-us',
  ),

  // ── 6. Charades ─────────────────────────────────────────────────────────
  const GameMode(
    id: 'charades',
    titleAr: 'تمثيل',
    titleEn: 'Charades',
    descriptionAr:
        'مثّل الكلمة أو العبارة بدون كلام واجعل فريقك يخمنها '
        'قبل انتهاء الوقت. ممنوع الكلام أو الإشارة للحروف!',
    descriptionEn:
        'Act out the word or phrase without speaking and get your team '
        'to guess it before time is up. No talking or spelling allowed!',
    icon: Icons.theater_comedy,
    minPlayers: 4,
    isAvailable: true,
    routeName: '/charades',
  ),

  // ── 7. Wink ─────────────────────────────────────────────────────────────
  const GameMode(
    id: 'wink',
    titleAr: 'الغمزة',
    titleEn: 'Wink',
    descriptionAr:
        'لاعب واحد هو "الغامز" يحاول إقصاء اللاعبين بالغمز لهم بدون '
        'أن يكتشفه المحقق. هل تستطيع كشفه قبل فوات الأوان؟',
    descriptionEn:
        'One player is the Winker who secretly winks at others to '
        'eliminate them. Can the detective catch the Winker in time?',
    icon: Icons.visibility,
    minPlayers: 4,
    isAvailable: true,
    routeName: '/wink',
  ),
];
