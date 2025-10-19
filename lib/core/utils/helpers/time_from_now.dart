import 'dart:developer';

extension DateTimeExtension on DateTime {
  String timeSinceNow() {
    try {
      final now = DateTime.now();
      final difference = now.difference(this);

      final years = difference.inDays ~/ 365;
      final months = (difference.inDays % 365) ~/ 30;
      final days = (difference.inDays % 365) % 30;

      if (years > 0) {
        return years == 1 ? 'منذ سنة' : 'منذ $years سنوات';
      } else if (months > 0) {
        return months == 1 ? 'منذ شهر' : 'منذ $months أشهر';
      } else if (days > 0) {
        return days == 1 ? 'منذ يوم' : 'منذ $days أيام';
      } else if (difference.inHours > 0) {
        return difference.inHours == 1
            ? 'منذ ساعة'
            : 'منذ ${difference.inHours} ساعات';
      } else if (difference.inMinutes > 0) {
        return difference.inMinutes == 1
            ? 'منذ دقيقة'
            : 'منذ ${difference.inMinutes} دقائق';
      } else {
        return 'الاًن';
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
