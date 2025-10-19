import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_state.dart';

class RealEstateAddCommentField extends StatefulWidget {
  final int adId;
  final VoidCallback? onSuccessRefresh;
  const RealEstateAddCommentField({super.key, required this.adId, this.onSuccessRefresh});

  @override
  State<RealEstateAddCommentField> createState() => _RealEstateAddCommentFieldState();
}

class _RealEstateAddCommentFieldState extends State<RealEstateAddCommentField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentSendCubit, CommentSendState>(
      listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
      listener: (context, state) {
        if (state.submitting) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إرسال التعليق...')));
        } else if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال التعليق بنجاح')));
          _ctrl.clear();
          widget.onSuccessRefresh?.call();
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
            ),
          ),
          horizontalSpace(8),
          SizedBox(
            height: 44.h,
            child: PrimaryButton(
              text: 'إرسال',
              onPressed: () {
                context.read<CommentSendCubit>().submit(adId: widget.adId, comment: _ctrl.text);
              },
              height: 44.h,
              width: 90.w,
            ),
          ),
        ],
      ),
    );
  }
}