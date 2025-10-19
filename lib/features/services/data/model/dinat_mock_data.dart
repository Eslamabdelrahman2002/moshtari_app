

import 'dinat_trip.dart';

final List<DinatTrip> mockDinatTrips = List.generate(10, (i) {
  return DinatTrip(
    fromCity: i.isEven ? 'جدة' : 'مراكش',
    toCity: i.isEven ? 'الرياض' : 'فاس',
    sizeLabel: 'كبيرة',
    dateLabel: i.isEven ? 'الثلاثاء 12 أغسطس' : 'الأربعاء 13 أغسطس',
    timeLabel: i.isEven ? '3:00 مساء' : '5:00 مساء',
    userName: i.isEven ? 'سارة أحمد' : 'يوسف أحمد',
    userAvatar: 'assets/images/prof.png',
    // حط هنا صورة الخريطة الخاصة بك (نفس اللي في الـ UI)
    mapImage: 'assets/images/map_placeholder.png',
  );
});