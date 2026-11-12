import 'package:flutter/material.dart';

class HeadsUpCategory {
  final String id;
  final String nameAr;
  final String descriptionAr;
  final IconData icon;
  final List<String> words;

  const HeadsUpCategory({
    required this.id,
    required this.nameAr,
    required this.descriptionAr,
    required this.icon,
    required this.words,
  });
}

const List<HeadsUpCategory> kHeadsUpCategories = [
  HeadsUpCategory(
    id: 'movies',
    nameAr: 'أفلام ومسلسلات',
    descriptionAr: 'أشهر الأعمال السينمائية والدرامية',
    icon: Icons.movie_outlined,
    words: [
      'الفيل الأزرق',
      'إبراهيم الأبيض',
      'الناظر',
      'صعيدي في الجامعة الأمريكية',
      'الكيف',
      'الجزيرة',
      'عسل أسود',
      'طير إنت',
      'بوحة',
      'اللمبي',
      'تيتو',
      'ولاد رزق',
      'الحريف',
      'غبي منه فيه',
      'أمير الظلام',
      'مافيا',
      'سهر الليالي',
      'كده رضا',
    ],
  ),
  HeadsUpCategory(
    id: 'food',
    nameAr: 'أكلات ومشروبات',
    descriptionAr: 'أطباق ومأكولات شهيرة ومعروفة',
    icon: Icons.restaurant_outlined,
    words: [
      'كشري',
      'ملوخية بالأرانب',
      'حواوشي',
      'طعمية وسلطة',
      'كوارع وممبار',
      'شاورما عربي',
      'فتة بالخل والتوم',
      'أم علي',
      'كنافة بالقشطة',
      'بسبوسة بالمكسرات',
      'محشي ورق عنب',
      'كباب وكفتة',
      'سلطة طحينة',
      'شاي بالنعناع',
      'عصير قصب',
      'سوبيا مثلجة',
    ],
  ),
  HeadsUpCategory(
    id: 'cartoons',
    nameAr: 'كرتون وأنيميشن',
    descriptionAr: 'شخصيات وأفلام كرتونية محبوبة',
    icon: Icons.pets_outlined,
    words: [
      'الأسد الملك',
      'توم وجيري',
      'سبونج بوب',
      'المحقق كونان',
      'كابتن ماجد',
      'سلاحف النينجا',
      'علاء الدين',
      'سندباد',
      'بوكيمون',
      'شركة المرعبين المحدودة',
      'ميكي ماوس',
      'توي ستوري',
      'موفاسا وسيمبا',
      'باباي البحار',
      'بينك بانثر',
    ],
  ),
  HeadsUpCategory(
    id: 'actions',
    nameAr: 'أفعال ومهن',
    descriptionAr: 'حركات وأعمال يومية ومهن',
    icon: Icons.bolt_outlined,
    words: [
      'دكتور سنان',
      'حلاق رجالي',
      'سائق تاكسي',
      'عازف جيتار',
      'غواص في البحر',
      'رائد فضاء',
      'شيف بيتزا',
      'ملاكم في الحلبة',
      'ساحر خفة يد',
      'رقص باليه',
      'نوم عميق',
      'عطسة قوية',
      'ضحك هيستيري',
      'لعب بلايستيشن',
      'تسلق جبال',
    ],
  ),
];
