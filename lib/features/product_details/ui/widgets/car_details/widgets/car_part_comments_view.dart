import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// ✅ كلاس مساعد لتوحيد بيانات التعليق/العرض قبل العرض
class CommentOfferItem {
  final String userName;
  final String text;
  final DateTime createdAt;
  final String? userImageUrl;
  final String? offerPrice;

  CommentOfferItem({
    required this.userName,
    required this.text,
    required this.createdAt,
    this.userImageUrl,
    this.offerPrice,
  });
}

class CarPartCommentsView extends StatelessWidget {
  final List<dynamic> comments;
  final List<dynamic> offers; // ✅ الحقل الجديد لاستقبال العروض

  const CarPartCommentsView({
    super.key,
    required this.comments,
    required this.offers, // ✅ إضافته للـ constructor
  });

  String? _safeString(dynamic v) => v?.toString().trim().isEmpty ?? true ? null : v.toString();

  // 🛠️ دوال استخلاص البيانات الموحدة

  String _name(dynamic c, String? currentUsername) {
    String? name;
    try {
      final nameFromModel = (c as dynamic).userName;
      if (nameFromModel is String && nameFromModel.trim().isNotEmpty) name = nameFromModel.trim();
    } catch (_) {}
    try {
      if (name == null) {
        final map = c as Map<String, dynamic>;
        final raw = map['user_name'] ??
            map['username'] ??
            (map['user'] is Map ? map['user']['username'] : null);
        if (raw != null && raw.toString().trim().isNotEmpty) name = raw.toString().trim();
      }
    } catch (_) {}

    if (name != null) return name;
    if ((currentUsername?.trim().isNotEmpty ?? false)) return currentUsername!.trim();
    return 'مستخدم';
  }

  String _text(dynamic c) {
    String? text;
    try {
      final t = (c as dynamic).text;
      if (t is String && t.isNotEmpty) text = t;
    } catch (_) {}
    try {
      if (text == null) {
        final map = c as Map<String, dynamic>;
        text = (map['comment_text'] ?? map['text'] ?? map['content'] ?? map['comment'] ?? map['offer_comment'] ?? '').toString();
        if (text.isEmpty && map.containsKey('offer_price')) text = 'عرض سعر';
      }
    } catch (_) {}
    return text ?? '...';
  }

  DateTime? _createdAt(dynamic c) {
    DateTime? date;
    try {
      final v = (c as dynamic).createdAt;
      if (v is DateTime) date = v;
      if (v is String && v.isNotEmpty) date = DateTime.tryParse(v);
    } catch (_) {}
    try {
      if (date == null) {
        final map = c as Map<String, dynamic>;
        final s = (map['created_at'] ?? '').toString();
        if (s.isNotEmpty) date = DateTime.tryParse(s);
      }
    } catch (_) {}
    return date;
  }

  String? _userPicture(dynamic c) {
    String? imageUrl;
    try {
      final v = (c as dynamic).userPicture;
      if (v is String) imageUrl = v;
    } catch (_) {}
    try {
      if (imageUrl == null) {
        final map = c as Map<String, dynamic>;
        final raw = map['user_picture'] ?? map['user_profile_image'] ?? map['user_image'] ?? map['user_avatar'];
        imageUrl = _safeString(raw);
        // التحقق داخل كائن user
        final userMap = map['user'] as Map<String, dynamic>?;
        if (imageUrl == null && userMap != null) {
          final userRawImage = userMap['profile_picture_url'] ?? userMap['profile_image'] ?? userMap['image'] ?? userMap['avatar'];
          imageUrl = _safeString(userRawImage);
        }
      }
    } catch (_) {}
    return imageUrl;
  }

  String? _offerPrice(dynamic c) {
    String? price;
    try {
      final v = (c as dynamic).offerPrice;
      if (v is String) price = v;
      if (v is num) price = v.toString();
    } catch (_) {}
    try {
      if (price == null) {
        final map = c as Map<String, dynamic>;
        final raw = map['offer_price'] ?? map['price'] ?? map['amount'];
        price = _safeString(raw);
      }
    } catch (_) {}
    return price;
  }

  // ✅ دالة لدمج العروض والتعليقات وفرزها
  List<CommentOfferItem> _combineAndSortItems(String? currentUsername) {
    List<CommentOfferItem> allItems = [];

    // دمج التعليقات والعروض في قائمة واحدة
    final rawItems = [...comments, ...offers];

    for (final item in rawItems) {
      final createdAt = _createdAt(item);

      // يجب أن يكون العنصر يملك تاريخ إنشاء لكي يتم فرزه وعرضه
      if (createdAt != null) {
        allItems.add(CommentOfferItem(
          userName: _name(item, currentUsername),
          text: _text(item),
          createdAt: createdAt,
          userImageUrl: _userPicture(item),
          offerPrice: _offerPrice(item),
        ));
      }
    }

    // الفرز: الأحدث أولاً
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);

    final allItems = _combineAndSortItems(currentUsername); // ✅ دمج وفرز القوائم

    if (allItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text('لا توجد تعليقات أو عروض بعد 👀', style: TextStyles.font14DarkGray400Weight),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التعليقات والعروض', style: TextStyles.font16Dark300Grey400Weight),
          verticalSpace(8),
          ...allItems.map((item) {

            final userName = item.userName;
            final text = item.text;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                createdAt: item.createdAt, // ✅ تمرير تاريخ الإنشاء
                userImageUrl: item.userImageUrl, // ✅ تمرير رابط الصورة
                offerPrice: item.offerPrice, // ✅ تمرير سعر العرض
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}