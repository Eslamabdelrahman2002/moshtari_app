import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_state.dart';

class CarAddCommentField extends StatefulWidget {
  final int adId;
  final VoidCallback? onSuccessRefresh;

  const CarAddCommentField({
    super.key,
    required this.adId,
    this.onSuccessRefresh,
  });

  @override
  State<CarAddCommentField> createState() => _CarAddCommentFieldState();
}

class _CarAddCommentFieldState extends State<CarAddCommentField> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentSendCubit, CommentSendState>(
      listenWhen: (p, c) =>
      p.submitting != c.submitting || p.success != c.success || p.error != c.error,
      listener: (context, state) {
        if (state.success) {
          _ctrl.clear();
          FocusScope.of(context).unfocus();
          widget.onSuccessRefresh?.call();
        } else if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final sending = state.submitting;
        final canSend = !sending && _ctrl.text.trim().isNotEmpty;

        void submit() {
          if (!canSend) return;
          context.read<CommentSendCubit>().submit(
            adId: widget.adId,
            comment: _ctrl.text.trim(),
          );
        }

        return Container(
          height: 65.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: ColorsManager.dark50,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'اكتب تعليقك هنا ...........',
                    filled: true,
                    fillColor: Colors.white,
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  ),
                  onSubmitted: (_) => submit(),
                ),
              ),
              horizontalSpace(8),
              GestureDetector(
                onTap: canSend ? submit : null,
                child: sending
                    ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send, color: Colors.blue),
              ),
            ],
          ),
        );
      },
    );
  }
}