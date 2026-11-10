import 'package:flutter/material.dart';

/// Teams in the Mafia game.
enum MafiaTeam {
  mafia,
  citizens,
}

/// The secret roles in the Mafia game.
enum MafiaRole {
  mafia,
  doctor,
  detective,
  citizen;

  /// Arabic title of the role.
  String get titleAr {
    switch (this) {
      case MafiaRole.mafia:
        return 'المافيا';
      case MafiaRole.doctor:
        return 'الطبيب';
      case MafiaRole.detective:
        return 'المحقق';
      case MafiaRole.citizen:
        return 'المواطن';
    }
  }

  /// Team alignment.
  MafiaTeam get team {
    switch (this) {
      case MafiaRole.mafia:
        return MafiaTeam.mafia;
      case MafiaRole.doctor:
      case MafiaRole.detective:
      case MafiaRole.citizen:
        return MafiaTeam.citizens;
    }
  }

  /// Role icon for UI representation.
  IconData get icon {
    switch (this) {
      case MafiaRole.mafia:
        return Icons.dangerous;
      case MafiaRole.doctor:
        return Icons.medical_services_outlined;
      case MafiaRole.detective:
        return Icons.search;
      case MafiaRole.citizen:
        return Icons.person_outline;
    }
  }

  /// Emoji representation matching Lamma game cards.
  String get emoji {
    switch (this) {
      case MafiaRole.mafia:
        return '💀';
      case MafiaRole.doctor:
        return '🩺';
      case MafiaRole.detective:
        return '🕵️';
      case MafiaRole.citizen:
        return '🧑‍🌾';
    }
  }

  /// Secret instruction displayed to the player during role reveal.
  String get instructionsAr {
    switch (this) {
      case MafiaRole.mafia:
        return 'أنت من أفراد المافيا! مهمتك القضاء على المواطنين دون كشف هويتك. في الليل ستختار مع زملائك ضحية، وفي النهار تظاهر بأنك مواطن بريء!';
      case MafiaRole.doctor:
        return 'أنت طبيب القرية! في كل جولة ليلية يمكنك اختيار لاعب واحد لحمايته من اغتيال المافيا (يمكنك حماية نفسك). إذا اخترت نفس الشخص الذي استهدفته المافيا سينجو!';
      case MafiaRole.detective:
        return 'أنت محقق القرية الذكي! في كل جولة ليلية تستطيع فحص هوية لاعب واحد سراً لمعرفة إن كان مافيا أم بريء. استخدم معلوماتك بحذر في النهار لإقناع الجميع دون أن تستهدفك المافيا.';
      case MafiaRole.citizen:
        return 'أنت مواطن بريء ومسالم! ليس لديك قوى خاصة في الليل، لكن في النهار استمع جيداً لأقوال الجميع، حلل تصرفاتهم وصوّت لإعدام أفراد المافيا!';
    }
  }
}
