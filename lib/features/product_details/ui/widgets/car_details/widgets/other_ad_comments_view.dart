// lib/features/product_details/ui/widgets/other_ad_comments_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
// تم إزالة استيراد CommentWidget
// import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/comment_widget.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

import '../../../../data/model/other_ad_details_model.dart';
import '../../comment_item.dart'; // ✅ تأكد من استخدام CommentItem الذي يدعم offerPrice

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


class OtherAdCommentsView extends StatelessWidget {
  final List<dynamic> comments; // التعليقات
  final List<dynamic> offers; // ✅ العروض: تم التأكيد على إضافته هنا

  const OtherAdCommentsView({
    super.key,
    required this.comments,
    this.offers = const [], // ✅ هذا هو المكان الذي تم فيه إضافة الحقل
  });

  String? _safeString(dynamic v) => v?.toString().trim().isEmpty ?? true ? null : v.toString();

  // ✅ دالة لدمج العروض والتعليقات وفرزها
  List<CommentOfferItem> _combineAndSortItems(String? currentUsername) {
    List<CommentOfferItem> allItems = [];

    // دمج التعليقات والعروض في قائمة واحدة
    final rawItems = [...comments, ...offers]; // ✅ يتم دمج القائمتين هنا

    // المنطق الموحد لاستخلاص البيانات من أي عنصر
    String _name(dynamic c) {
      try {
        final name = (c as dynamic).userName;
        if (name is String && name.trim().isNotEmpty) return name.trim();
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        final raw = map['user_name'] ??
            map['username'] ??
            (map['user'] is Map ? map['user']['username'] : null);
        if (raw != null && raw.toString().trim().isNotEmpty) return raw.toString().trim();
      } catch (_) {}
      if ((currentUsername?.trim().isNotEmpty ?? false)) return currentUsername!.trim();
      return 'مستخدم';
    }

    String _text(dynamic c, {required bool isOffer}) {
      String? text;
      try {
        // جرب الوصول المباشر
        final t = (c as dynamic).text ?? (c as dynamic).comment ?? (c as dynamic).offerComment;
        if (t is String && t.isNotEmpty) text = t;
      } catch (_) {}

      try {
        // جرب الوصول كخريطة
        if (text == null) {
          final map = c as Map<String, dynamic>;
          text = (map['comment_text'] ??
              map['text'] ??
              map['content'] ??
              map['comment'] ??
              map['offer_comment'] ??
              '').toString();
        }
      } catch (_) {}

      if (text != null && text.isNotEmpty) return text;

      // نص افتراضي إذا كان عرض سعر ولا يوجد تعليق
      return isOffer ? 'عرض سعر' : '...';
    }

    DateTime? _createdAt(dynamic c) {
      try {
        final v = (c as dynamic).createdAt;
        if (v is DateTime) return v;
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        final s = (map['created_at'] ?? '').toString();
        if (s.isNotEmpty) return DateTime.tryParse(s);
      } catch (_) {}
      return null;
    }

    String? _userPicture(dynamic c) {
      try {
        final v = (c as dynamic).userPicture ?? (c as dynamic).user_picture;
        if (v is String) return _safeString(v);
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        final raw = map['user_picture'] ?? map['user_profile_image'] ?? map['user_image'] ?? map['user_avatar'];
        return _safeString(raw);
      } catch (_) {}
      return null;
    }

    String? _offerPrice(dynamic c) {
      try {
        // جرب الوصول المباشر
        final p = (c as dynamic).offerPrice ?? (c as dynamic).price ?? (c as dynamic).amount;
        if (p != null) return _safeString(p);
      } catch (_) {}

      try {
        // جرب الوصول كخريطة
        final map = c as Map<String, dynamic>;
        final raw = map['offer_price'] ?? map['price'] ?? map['amount'];
        return _safeString(raw);
      } catch (_) {}
      return null;
    }

    // تعبئة قائمة العناصر الموحدة
    for (final item in rawItems) {
      final isOffer = _offerPrice(item) != null;
      final createdAt = _createdAt(item);

      // يجب أن يكون العنصر يملك تاريخ إنشاء لكي يتم فرزه وعرضه
      if (createdAt != null) {
        allItems.add(CommentOfferItem(
          userName: _name(item),
          text: _text(item, isOffer: isOffer),
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
        child: Text('لا توجد تعليقات أو عروض بعد 👀',
            style: TextStyles.font14DarkGray400Weight),
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
              padding: EdgeInsets.only(bottom: 12.h),
              child: CommentItem( // ✅ تم استخدام CommentItem
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                createdAt: item.createdAt,
                userImageUrl: item.userImageUrl,
                offerPrice: item.offerPrice, // ✅ تمرير سعر العرض
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}