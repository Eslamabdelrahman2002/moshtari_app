import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/theme/text_styles.dart';

import 'package:mushtary/core/widgets/safe_cached_image.dart'; // افتراضًا أن SafeCircleAvatar موجود هنا

import 'package:mushtary/features/messages/data/models/chat_model.dart';

import '../../../../../core/router/routes.dart'; // غير المسار حسب مشروعك

class ChatAppBar extends StatelessWidget {
  final UserModel? user;

  const ChatAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'المحادثة';
    final avatar = user?.profileImage;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // لف SafeCircleAvatar بـ GestureDetector لإضافة onTap
          GestureDetector(
            onTap: () {
              final ownerIdRaw = user?.id; // استخراج ID المستخدم من UserModel
              final ownerId = int.tryParse(ownerIdRaw.toString()); // تحويل إلى int إذا كان String
              if (ownerId != null) {
                Navigator.of(context).pushNamed(
                  Routes.userProfileScreenId, // اسم الراوت لصفحة الملف الشخصي
                  arguments: ownerId, // تمرير ID كـ arguments
                );
              } else {
                print('❌ فشل تحويل معرف المستخدم إلى رقم صالح. القيمة: $ownerIdRaw');
              }
            },
            child: SafeCircleAvatar(url: avatar, radius: 18),
          ),
          SizedBox(width: 12.w),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.font16Black500Weight,
          ),
        ],
      ),
    );
  }
}