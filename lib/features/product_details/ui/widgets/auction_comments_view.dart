import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

class AuctionCommentsView extends StatelessWidget {
  final List<dynamic> comments;

  const AuctionCommentsView({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final currentUsername =
    context.select<ProfileCubit, String?>((c) => c.user?.username);

    if (comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text('لا توجد تعليقات بعد 👀', style: TextStyles.font14DarkGray400Weight),
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
      if ((currentUsername?.trim().isNotEmpty ?? false)) return currentUsername!.trim();
      return 'مستخدم';
    }

    String _text(dynamic c) {
      try {
        final t = (c as dynamic).text;
        if (t is String) return t;
      } catch (_) {}
      try {
        final map = c as Map<String, dynamic>;
        return (map['comment_text'] ?? map['text'] ?? map['content'] ?? map['comment'] ?? '')
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

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                createdAt: createdAt,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}