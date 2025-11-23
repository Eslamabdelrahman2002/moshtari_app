// file: other_ad_comments_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

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

class OtherAdCommentsView extends StatelessWidget {
  final List<dynamic> comments;
  final List<dynamic> offers;

  const OtherAdCommentsView({
    super.key,
    required this.comments,
    required this.offers,
  });

  String? _safeString(dynamic v) =>
      v?.toString().trim().isEmpty ?? true ? null : v.toString();

  List<CommentOfferItem> _combineAndSortItems(String? currentUsername) {
    final List<CommentOfferItem> allItems = [];

    // 🟢 التعليقات
    for (final c in comments) {
      Map<String, dynamic>? map;

      if (c is Map<String, dynamic>) {
        map = c;
      } else {
        try {
          map = {
            'user_name': (c as dynamic).userName?.toString(),
            'user_picture': (c as dynamic).userPicture?.toString(),
            'comment_text': (c as dynamic).text?.toString(),
            'created_at': (c as dynamic).createdAt?.toString(),
          };
        } catch (_) {}
      }

      if (map == null) continue;

      final name = _safeString(map['user_name'] ??
          map['username'] ??
          (map['user'] is Map ? (map['user'] as Map)['username'] : null));

      final userName = name ??
          (currentUsername?.trim().isNotEmpty ?? false
              ? currentUsername!.trim()
              : 'مستخدم');

      final imageUrl = _safeString(map['user_picture'] ??
          map['user_profile_image'] ??
          map['user_image'] ??
          map['user_avatar']);

      final text = _safeString(map['comment_text'] ??
          map['text'] ??
          map['comment'] ??
          map['content']) ??
          '...';

      final createdAtStr = _safeString(map['created_at']);
      final createdAt = createdAtStr != null
          ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
          : DateTime.now();

      allItems.add(CommentOfferItem(
        userName: userName,
        text: text,
        createdAt: createdAt,
        userImageUrl: imageUrl,
        offerPrice: null,
      ));
    }

    // 🟣 العروض
    for (final o in offers) {
      Map<String, dynamic>? map;

      if (o.runtimeType.toString() == 'OfferModel' ||
          (o is dynamic && o?.offerPrice != null)) {
        try {
          map = {
            'user_name': o.userName?.toString(),
            'user_picture': o.userPicture?.toString(),
            'offer_price': o.offerPrice?.toString(),
            'offer_comment': o.offerComment?.toString(),
            'comment': o.offerComment?.toString(),
            'created_at': o.createdAt?.toIso8601String(),
          };
        } catch (_) {}
      }

      if (o is Map<String, dynamic>) {
        map = o;
      }

      if (map == null) continue;

      final offerPrice = _safeString(map['offer_price']);
      if (offerPrice == null) continue;

      final userName = _safeString(map['user_name']) ?? 'مستخدم';
      final imageUrl = _safeString(map['user_picture']);

      // 👉 لو فيه offer_comment أو comment جاي من السيرفر، خده، وإلا رجّع "عرض سعر"
      final text =
          _safeString(map['offer_comment'] ?? map['comment']) ?? 'عرض سعر';

      final createdAtStr = _safeString(map['created_at']);
      final createdAt = createdAtStr != null
          ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
          : DateTime.now();

      allItems.add(CommentOfferItem(
        userName: userName,
        text: text,
        createdAt: createdAt,
        userImageUrl: imageUrl,
        offerPrice: offerPrice,
      ));
    }

    // ترتيب حسب التاريخ
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التعليقات',
              style: TextStyles.font16Dark300Grey400Weight),
          verticalSpace(8),
          ...allItems.map((item) {
            final text = item.text.isEmpty ? '...' : item.text;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: item.userName,
                comment: text,
                createdAt: item.createdAt,
                userImageUrl: item.userImageUrl,
                offerPrice: item.offerPrice,
              ),
            );
          }),
        ],
      ),
    );
  }
}