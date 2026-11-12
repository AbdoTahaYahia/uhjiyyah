import 'package:flutter/material.dart';

/// Preset secret locations and associated roles for Spyfall (الجاسوس).
class SpyLocation {
  final String nameAr;
  final String emoji;
  final IconData icon;
  final List<String> rolesAr;

  const SpyLocation({
    required this.nameAr,
    this.emoji = '',
    required this.icon,
    required this.rolesAr,
  });
}

const List<SpyLocation> kSpyLocations = [
  SpyLocation(
    nameAr: 'طائرة ركاب',
    icon: Icons.flight_takeoff_outlined,
    rolesAr: ['طيار أول', 'مضيفة طيران', 'راكب درجة أولى', 'رجل أمن', 'مسافر خائف'],
  ),
  SpyLocation(
    nameAr: 'مستشفى مركزي',
    icon: Icons.local_hospital_outlined,
    rolesAr: ['جراح', 'ممرض', 'طبيب طوارئ', 'مريض', 'زائر'],
  ),
  SpyLocation(
    nameAr: 'محطة فضاء دولية',
    icon: Icons.rocket_launch_outlined,
    rolesAr: ['قائد المركبة', 'عالم فيزياء', 'مهندس صيانة', 'رائد فضاء أجنبي'],
  ),
  SpyLocation(
    nameAr: 'مطعم فاخر',
    icon: Icons.restaurant_outlined,
    rolesAr: ['رئيس الطهاة', 'نادل', 'ناقد طعام', 'زبون VIP', 'عازف بيانو'],
  ),
  SpyLocation(
    nameAr: 'بنك مركزي',
    icon: Icons.account_balance_outlined,
    rolesAr: ['مدير الفرع', 'صراف', 'حارس أمن', 'عميل ثري', 'محاسب'],
  ),
  SpyLocation(
    nameAr: 'شاطئ استوائي',
    icon: Icons.beach_access_outlined,
    rolesAr: ['منقذ سباحة', 'سائح', 'راكب أمواج', 'بائع مثلجات'],
  ),
  SpyLocation(
    nameAr: 'غواصة حربية',
    icon: Icons.directions_boat_outlined,
    rolesAr: ['قبطان', 'مهندس محركات', 'موجّه رادار', 'طباخ بحري'],
  ),
  SpyLocation(
    nameAr: 'متحف آثار',
    icon: Icons.museum_outlined,
    rolesAr: ['مرشد سياحي', 'عالم آثار', 'حارس ليلي', 'سائح محب للتاريخ'],
  ),
  SpyLocation(
    nameAr: 'استوديو تصوير سينمائي',
    icon: Icons.movie_outlined,
    rolesAr: ['مخرج', 'ممثل مشهور', 'مصور كاميرا', 'خبير مكياج'],
  ),
  SpyLocation(
    nameAr: 'سفينة سياحية',
    icon: Icons.sailing_outlined,
    rolesAr: ['ربان السفينة', 'مسؤول الترفيه', 'طباخ بوفيه', 'مسافر يقضي شهر عسل'],
  ),
];
