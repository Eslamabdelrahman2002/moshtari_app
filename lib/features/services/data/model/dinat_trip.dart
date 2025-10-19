// features/services/data/models/dinat_trip.dart
class DinatTrip {
  final String fromCity;
  final String toCity;
  final String sizeLabel;     // مثال: كبيرة
  final String dateLabel;     // مثال: الثلاثاء 12 أغسطس
  final String timeLabel;     // مثال: 3:00 مساء
  final String userName;      // مثال: سارة أحمد
  final String userAvatar;    // assets/images/user.png
  final String mapImage;      // assets/images/map.png (حط صورتك هنا)

  DinatTrip({
    required this.fromCity,
    required this.toCity,
    required this.sizeLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.userName,
    required this.userAvatar,
    required this.mapImage,
  });
}