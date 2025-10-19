import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/home/data/models/auctions/bargains_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_text_field.dart';
import 'package:mushtary/features/product_details/ui/widgets/comments_header_with_button.dart';

class CommentsView extends StatelessWidget {
  final List<BargainModel> bargains;
  const CommentsView({super.key, required this.bargains});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          const CommentsHeaderWithButton(),
          verticalSpace(20),
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: bargains.length,
            itemBuilder: (context, index) {
              return CommentItem(
                 userName: '', comment: '',
              );
            },
          ),
          // const ShowMoreCommentsButton(), TODO: Uncomment this line

          verticalSpace(16),
          const CommentTextField(),
        ],
      ),
    );
  }
}
