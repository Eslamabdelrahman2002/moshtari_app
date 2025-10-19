// lib/features/product_details/ui/widgets/other_ad_comments_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
// تم تغيير الاستيراد ليستخدم CommentWidget
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/comment_widget.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

class OtherAdCommentsView extends StatelessWidget {
  final List<dynamic> comments;

  const OtherAdCommentsView({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);

    if (comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text('لا توجد تعليقات بعد 👀',
            style: TextStyles.font14DarkGray400Weight),
      );
    }

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
        if (raw != null && raw.toString().trim().isNotEmpty) {
          return raw.toString().trim();
        }
      } catch (_) {}
      if ((currentUsername?.trim().isNotEmpty ?? false)) {
        return currentUsername!.trim();
      }
      return 'مستخدم';
    }

    String _text(dynamic c) {
      try {
        final t = (c as dynamic).text ?? (c as dynamic).comment;
        if (t is String) return t;
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        return (map['comment_text'] ??
            map['text'] ??
            map['content'] ??
            map['comment'] ??
            '')
            .toString();
      } catch (_) {}
      return '';
    }

    DateTime? _createdAt(dynamic c) {
      try {
        final v = (c as dynamic).createdAt;
        if (v is DateTime) return v;
        if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        final s = (map['created_at'] ?? '').toString();
        if (s.isNotEmpty) return DateTime.tryParse(s);
      } catch (_) {}
      return null;
    }

    String? _price(dynamic c) {
      try {
        final p = (c as dynamic).price;
        if (p != null) return p.toString();
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        final raw = map['price'] ?? map['amount'];
        if (raw != null && raw.toString().trim().isNotEmpty) {
          return raw.toString().trim();
        }
      } catch (_) {}
      return null;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التعليقات', style: TextStyles.font16Dark300Grey400Weight),
          verticalSpace(8),
          ...comments.map((c) {
            final userName = _name(c);
            final text = _text(c);
            final createdAt = _createdAt(c);
            final price = _price(c); // استخراج السعر

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              // *** تم استبدال CommentItem بـ CommentWidget ***
              child: CommentWidget(
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                createdAt: createdAt,
                price: price, // تمرير السعر
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}