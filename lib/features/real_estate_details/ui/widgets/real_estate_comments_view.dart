// file: RealEstateCommentsView.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// ✅ كلاس مساعد لتوحيد التعليقات والعروض قبل عرضها
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
  final List<dynamic> offers; // ✅ قائمة العروض

  const RealEstateCommentsView({
    super.key,
    required this.comments,
    required this.offers,
  });

  // دالة لتأمين القيم النصية من null أو فراغ
  String? _safeString(dynamic v) =>
      v?.toString().trim().isEmpty ?? true ? null : v.toString();

  // ✅ دمج وفرز التعليقات والعروض
  List<CommentOfferItem> _combineAndSortItems(String? currentUsername) {
    final List<CommentOfferItem> allItems = [];

    // ----------------------------
    // 🟢 1. معالجة التعليقات
    // ----------------------------
    for (final c in comments) {
      if (c is! Map<String, dynamic>) continue;
      final map = c;

      // الاسم
      final rawName = map['user_name'] ??
          map['username'] ??
          (map['user'] is Map ? (map['user'] as Map)['username'] : null);
      final nameFromComment = _safeString(rawName);

      // الصورة
      final rawImage =
          map['user_profile_image'] ?? map['user_image'] ?? map['user_avatar'];
      final userMap = map['user'] as Map<String, dynamic>?;
      final userRawImage =
          userMap?['profile_image'] ?? userMap?['image'] ?? userMap?['avatar'];
      final imageUrl = _safeString(rawImage ?? userRawImage);

      // النص
      final text =
          _safeString(map['comment_text'] ?? map['text'] ?? '') ?? '...';

      // التاريخ
      final createdAtStr = _safeString(
          map['created_at'] ?? map['createdAt'] ?? map['date']);
      final createdAt = createdAtStr != null
          ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
          : DateTime.now();

      // أضف التعليق
      allItems.add(CommentOfferItem(
        userName: nameFromComment ??
            (currentUsername?.trim().isNotEmpty ?? false
                ? currentUsername!.trim()
                : 'مستخدم'),
        text: text,
        createdAt: createdAt,
        userImageUrl: imageUrl,
        offerPrice: null,
      ));
    }


    for (final o in offers) {
      Map<String, dynamic>? map;

      // 🧩 في حالة OfferModel
      if (o.runtimeType.toString() == 'OfferModel' ||
          (o is dynamic && o?.offerPrice != null)) {
        try {
          map = {
            'user_name': o.userName?.toString(),
            'user_picture': o.userPicture?.toString(),
            'offer_price': o.offerPrice?.toString(),
            'offer_comment': o.offerComment?.toString(),
            'created_at': o.createdAt?.toIso8601String(),
          };
        } catch (_) {}
      }

      // 🧩 أو حالة Map عادية
      if (o is Map<String, dynamic>) {
        map = o;
      }

      if (map == null) continue;

      final offerPrice = _safeString(map['offer_price'] ?? map['price']);
      if (offerPrice == null) continue;

      final nameFromOffer =
      _safeString(map['user_name'] ?? map['username']);
      final imageUrl = _safeString(map['user_picture']);
      final userName = nameFromOffer ??
          (currentUsername?.trim().isNotEmpty ?? false
              ? currentUsername!.trim()
              : 'مستخدم');

      final text = _safeString(map['offer_comment'] ?? '') ?? 'عرض سعر';
      final createdAtStr =
      _safeString(map['created_at'] ?? map['createdAt']);
      final createdAt = createdAtStr != null
          ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
          : DateTime.now();

      // ✅ إضافة العرض
      allItems.add(CommentOfferItem(
        userName: userName,
        text: text,
        createdAt: createdAt,
        userImageUrl: imageUrl,
        offerPrice: offerPrice,
      ));
    }

    // ----------------------------
    // 🟡 3. الفرز: الأحدث أولاً
    // ----------------------------
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    // اسم المستخدم الحالي (لو مسجل دخوله)
    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);

    // دمج وفرز العناصر
    final allItems = _combineAndSortItems(currentUsername);

    if (allItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(
          'لا توجد تعليقات أو عروض بعد 👀',
          style: TextStyles.font14DarkGray400Weight,
        ),
      );
    }

    // ----------------------------
    // 🧾 4. عرض القائمة
    // ----------------------------
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التعليقات',
            style: TextStyles.font16Dark300Grey400Weight,
          ),
          verticalSpace(8),
          ...allItems.map((item) {
            final userName = item.userName;
            final text = item.text.isEmpty ? '...' : item.text;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text,
                createdAt: item.createdAt,
                userImageUrl: item.userImageUrl,
                offerPrice: item.offerPrice, // ✅ عرض السعر عند وجوده
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}