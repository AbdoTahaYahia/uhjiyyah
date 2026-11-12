/// Preset secret locations and associated roles for Spyfall (الجاسوس).
class SpyLocation {
  final String nameAr;
  final String emoji;
  final List<String> rolesAr;

  const SpyLocation({
    required this.nameAr,
    required this.emoji,
    required this.rolesAr,
  });
}

const List<SpyLocation> kSpyLocations = [
  SpyLocation(
    nameAr: 'طائرة ركاب',
    emoji: '✈️',
    rolesAr: ['طيار أول', 'مضيفة طيران', 'راكب درجة أولى', 'رجل أمن', 'مسافر خائف'],
  ),
  SpyLocation(
    nameAr: 'مستشفى مركزي',
    emoji: '🏥',
    rolesAr: ['جراح', 'ممرض', 'طبيب طوارئ', 'مريض', 'زائر'],
  ),
  SpyLocation(
    nameAr: 'محطة فضاء دولية',
    emoji: '🚀',
    rolesAr: ['قائد المركبة', 'عالم فيزياء', 'مهندس صيانة', 'رائد فضاء أجنبي'],
  ),
  SpyLocation(
    nameAr: 'مطعم فاخر',
    emoji: '🍽️',
    rolesAr: ['رئيس الطهاة', 'نادل', 'ناقد طعام', 'زبون VIP', 'عازف بيانو'],
  ),
  SpyLocation(
    nameAr: 'بنك مركزي',
    emoji: '🏦',
    rolesAr: ['مدير الفرع', 'صراف', 'حارس أمن', 'عميل ثري', 'محاسب'],
  ),
  SpyLocation(
    nameAr: 'شاطئ استوائي',
    emoji: '🏖️',
    rolesAr: ['منقذ سباحة', 'سائح', 'راكب أمواج', 'بائع مثلجات'],
  ),
  SpyLocation(
    nameAr: 'غواصة حربية',
    emoji: '⚓',
    rolesAr: ['قبطان', 'مهندس محركات', 'موجّه رادار', 'طباخ بحري'],
  ),
  SpyLocation(
    nameAr: 'متحف آثار',
    emoji: '🏛️',
    rolesAr: ['مرشد سياحي', 'عالم آثار', 'حارس ليلي', 'سائح محب للتاريخ'],
  ),
  SpyLocation(
    nameAr: 'استوديو تصوير سينمائي',
    emoji: '🎬',
    rolesAr: ['مخرج', 'ممثل مشهور', 'مصور كاميرا', 'خبير مكياج'],
  ),
  SpyLocation(
    nameAr: 'سفينة سياحية',
    emoji: '🚢',
    rolesAr: ['ربان السفينة', 'مسؤول الترفيه', 'طباخ بوفيه', 'مسافر يقضي شهر عسل'],
  ),
];
