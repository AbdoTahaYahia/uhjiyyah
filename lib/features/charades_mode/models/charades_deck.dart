class CharadesCard {
  final String title;
  final String categoryAr;
  final int points;

  const CharadesCard({
    required this.title,
    required this.categoryAr,
    this.points = 1,
  });
}

const List<CharadesCard> kCharadesCards = [
  // أفلام
  CharadesCard(title: 'الفيل الأزرق', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'إبراهيم الأبيض', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'صعيدي في الجامعة الأمريكية', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'الناظر صلاح الدين', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'الجزيرة', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'عسل أسود', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'غبي منه فيه', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'تيتو', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'بوحة', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'أمير الظلام', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'الكيف', categoryAr: 'أفلام سينمائية'),
  CharadesCard(title: 'طير إنت', categoryAr: 'أفلام سينمائية'),

  // مسلسلات
  CharadesCard(title: 'جعفر العمدة', categoryAr: 'مسلسلات درامية'),
  CharadesCard(title: 'لن أعيش في جلباب أبي', categoryAr: 'مسلسلات درامية'),
  CharadesCard(title: 'الكبير أوي', categoryAr: 'مسلسلات درامية'),
  CharadesCard(title: 'رأفت الهجان', categoryAr: 'مسلسلات درامية'),
  CharadesCard(title: 'الاختيار', categoryAr: 'مسلسلات درامية'),

  // أمثال وحكم
  CharadesCard(title: 'القرد في عين أمه غزال', categoryAr: 'أمثال شعبية'),
  CharadesCard(title: 'اللي على راسه بطحة', categoryAr: 'أمثال شعبية'),
  CharadesCard(title: 'داري على شمعتك تقيد', categoryAr: 'أمثال شعبية'),
  CharadesCard(title: 'عصفور في اليد خير من عشرة على الشجرة', categoryAr: 'أمثال شعبية'),
  CharadesCard(title: 'اللي اتلسع من الشوربة ينفخ في الزبادي', categoryAr: 'أمثال شعبية'),
  CharadesCard(title: 'دخول الحمام مش زي خروجه', categoryAr: 'أمثال شعبية'),
  CharadesCard(title: 'الباب اللي يجيلك منه الريح سده واستريح', categoryAr: 'أمثال شعبية'),

  // حركات ومواقف
  CharadesCard(title: 'واحد بيغرق وبيشاور للناس تفتكره بيسلم', categoryAr: 'مواقف كوميدية'),
  CharadesCard(title: 'دكتور سنان بيخلع ضرس عقل بالعافية', categoryAr: 'مواقف كوميدية'),
  CharadesCard(title: 'واحد بيحط شطة كتير وبيدور على ماء', categoryAr: 'مواقف كوميدية'),
  CharadesCard(title: 'حرامي بيسرق ومحشور في الشباك', categoryAr: 'مواقف كوميدية'),
  CharadesCard(title: 'واحد بيصطاد سمكة وشدته في البحر', categoryAr: 'مواقف كوميدية'),
];
