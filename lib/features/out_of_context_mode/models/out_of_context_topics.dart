class OutOfContextTopic {
  final String categoryAr;
  final String secretWordAr;
  final List<String> decoyWordsAr;
  final String hintAr;

  const OutOfContextTopic({
    required this.categoryAr,
    required this.secretWordAr,
    required this.decoyWordsAr,
    required this.hintAr,
  });
}

const List<OutOfContextTopic> kOutOfContextTopics = [
  OutOfContextTopic(
    categoryAr: 'أماكن عامة',
    secretWordAr: 'مستشفى',
    decoyWordsAr: ['صيدلية', 'عيادة', 'مدرسة', 'جامعة', 'فندق', 'محطة قطار'],
    hintAr: 'مكان فيه دكاترة وسراير',
  ),
  OutOfContextTopic(
    categoryAr: 'أماكن ترفيهية',
    secretWordAr: 'سينما',
    decoyWordsAr: ['مسرح', 'استاد', 'متحف', 'ملاهي', 'حديقة حيوان'],
    hintAr: 'شاشة كبيرة وفشار وأفلام',
  ),
  OutOfContextTopic(
    categoryAr: 'أكلات ومشروبات',
    secretWordAr: 'شاورما',
    decoyWordsAr: ['كشري', 'برجر', 'بيتزا', 'حواوشي', 'طعمية'],
    hintAr: 'سيخ لحمة أو فراخ مع تومية وتورشي',
  ),
  OutOfContextTopic(
    categoryAr: 'وسائل مواصلات',
    secretWordAr: 'طائرة',
    decoyWordsAr: ['قطار', 'سفينة', 'مترو', 'أتوبيس', 'سيارة أجرة'],
    hintAr: 'تطير في السماء وفيها مضيفين',
  ),
  OutOfContextTopic(
    categoryAr: 'أماكن عامة',
    secretWordAr: 'سوبرماركت',
    decoyWordsAr: ['مول', 'مخبز', 'سوق خضار', 'محل ملابس'],
    hintAr: 'عربات تسوق وأرفف وبضائع مختلفة',
  ),
  OutOfContextTopic(
    categoryAr: 'أجهزة وتكنولوجيا',
    secretWordAr: 'ثلاجة',
    decoyWordsAr: ['غسالة', 'ميكروويف', 'بوتاجاز', 'تكييف', 'تلفزيون'],
    hintAr: 'تبرد الأكل وتحفظه في المطبخ',
  ),
  OutOfContextTopic(
    categoryAr: 'مهن ووظائف',
    secretWordAr: 'رائد فضاء',
    decoyWordsAr: ['طيار', 'غواص', 'عالم فلك', 'مهندس', 'ضابط'],
    hintAr: 'يسافر إلى الفضاء ببدلة خاصة',
  ),
  OutOfContextTopic(
    categoryAr: 'أماكن تاريخية وسياحية',
    secretWordAr: 'الأهرامات',
    decoyWordsAr: ['برج القاهرة', 'قلعة قايتباي', 'متحف الحضارة', 'معبد الكرنك'],
    hintAr: 'عجائب الدنيا السبع في الجيزة',
  ),
  OutOfContextTopic(
    categoryAr: 'ألعاب ورياضة',
    secretWordAr: 'كرة قدم',
    decoyWordsAr: ['كرة سلة', 'تنس', 'سباحة', 'ملاكمة', 'شطرنج'],
    hintAr: '11 لاعب ضد 11 لاعب وشباك',
  ),
  OutOfContextTopic(
    categoryAr: 'أدوات يومية',
    secretWordAr: 'ساعة يد',
    decoyWordsAr: ['نظارة شمس', 'محفظة', 'حزام', 'خاتم', 'ميدالية مفاتيح'],
    hintAr: 'تلبسها في معصمك لمعرفة الوقت',
  ),
];
