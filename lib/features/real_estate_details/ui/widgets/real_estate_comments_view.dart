// file: RealEstateCommentsView.dart (بعد التعديل)

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

class RealEstateCommentsView extends StatelessWidget {
  final List<dynamic> comments;
  final List<dynamic> offers; // ✅ الحقل الجديد لاستقبال العروض

  const RealEstateCommentsView({
    super.key,
    required this.comments,
    required this.offers, // ✅ إضافة العروض للـ constructor
  });

  String? _safeString(dynamic v) => v?.toString().trim().isEmpty ?? true ? null : v.toString();

  // ✅ دالة لدمج العروض والتعليقات وفرزها
  List<CommentOfferItem> _combineAndSortItems(String? currentUsername) {
    List<CommentOfferItem> allItems = [];

    // 1. معالجة التعليقات
    for (final c in comments) {
      if (c is! Map<String, dynamic>) continue;
      final map = c;

      // استخراج الاسم
      String? nameFromComment;
      final rawName = map['user_name'] ??
          map['username'] ??
          (map['user'] is Map ? map['user']['username'] : null);
      nameFromComment = _safeString(rawName);

      // استخراج رابط الصورة
      String? imageUrl;
      final rawImage = map['user_profile_image'] ?? map['user_image'] ?? map['user_avatar'];
      final userMap = map['user'] as Map<String, dynamic>?;
      final userRawImage = userMap?['profile_image'] ?? userMap?['image'] ?? userMap?['avatar'];

      imageUrl = _safeString(rawImage ?? userRawImage);

      final userName = (nameFromComment != null)
          ? nameFromComment
          : ((currentUsername?.trim().isNotEmpty ?? false)
          ? currentUsername!.trim()
          : 'مستخدم');

      final text = _safeString(map['comment_text'] ?? map['text'] ?? '') ?? '...';
      final createdAtStr = _safeString(map['created_at']);
      DateTime? createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

      if (createdAt != null) {
        allItems.add(CommentOfferItem(
          userName: userName,
          text: text,
          createdAt: createdAt,
          userImageUrl: imageUrl,
          offerPrice: null,
        ));
      }
    }

    // 2. معالجة العروض
    for (final o in offers) {
      if (o is! Map<String, dynamic>) continue;
      final map = o;

      // استخراج سعر العرض
      final offerPrice = _safeString(map['offer_price'] ?? map['price']);
      if (offerPrice == null) continue;

      // استخراج الاسم
      String? nameFromOffer;
      final rawName = map['user_name'] ?? map['username'];
      nameFromOffer = _safeString(rawName);

      // استخراج رابط الصورة
      String? imageUrl = _safeString(map['user_picture']);

      final userName = (nameFromOffer != null)
          ? nameFromOffer
          : ((currentUsername?.trim().isNotEmpty ?? false)
          ? currentUsername!.trim()
          : 'مستخدم');

      final text = _safeString(map['offer_comment'] ?? '') ?? 'عرض سعر';
      final createdAtStr = _safeString(map['created_at']);
      DateTime? createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

      if (createdAt != null) {
        allItems.add(CommentOfferItem(
          userName: userName,
          text: text,
          createdAt: createdAt,
          userImageUrl: imageUrl,
          offerPrice: offerPrice, // ✅ تمرير سعر العرض
        ));
      }
    }

    // 3. الفرز: الأحدث أولاً
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
          ...allItems.map((item) { // ✅ استخدام القائمة المدمجة والمفرزة

            final userName = item.userName;
            final text = item.text.isEmpty ? '...' : item.text;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text,
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