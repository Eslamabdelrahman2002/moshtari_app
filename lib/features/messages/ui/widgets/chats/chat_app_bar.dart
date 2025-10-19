import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/safe_cached_image.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';

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
          SafeCircleAvatar(url: avatar, radius: 18),
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