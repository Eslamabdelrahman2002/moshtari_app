import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
// افتراض استيراد PrimaryTextFormField
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';
// افتراض استيراد MySvg
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_state.dart';

class RealEstateCommentComposer extends StatefulWidget {
  final int adId;
  final VoidCallback? onSuccessRefresh;
  const RealEstateCommentComposer({super.key, required this.adId, this.onSuccessRefresh});

  @override
  State<RealEstateCommentComposer> createState() => _RealEstateCommentComposerState();
}

class _RealEstateCommentComposerState extends State<RealEstateCommentComposer> {
  final _ctrl = TextEditingController();

  // ✅ يتم إضافة Listener لـ _ctrl لتمكين/تعطيل زر الإرسال عند الكتابة
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

  void _submitComment(BuildContext context, bool sending) {
    final canSend = !sending && _ctrl.text.trim().isNotEmpty;
    if (!canSend) return;

    context.read<CommentSendCubit>().submit(
      adId: widget.adId,
      comment: _ctrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentSendCubit, CommentSendState>(
      listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
      listener: (context, state) {
        if (state.success) {
          _ctrl.clear();
          FocusScope.of(context).unfocus();
          widget.onSuccessRefresh?.call();
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final sending = state.submitting;
        final canSend = !sending && _ctrl.text.trim().isNotEmpty;

        return Container(
          // ✅ تعديل الارتفاع ليتطابق مع الـ UI الجديد (56.h)
          height: 56.h,
          width: double.infinity,
          // ✅ تعديل الـ padding
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: ColorsManager.dark50,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              // ✅ استبدال TextField بـ PrimaryTextFormField
              SizedBox(
                width: 302.w,
                height: 40.h, // ارتفاع مناسب للـ TextFormField
                child: PrimaryTextFormField(
                  controller: _ctrl,
                  validationError: '',
                  hint: 'اكتب تعليقك هنا ...........',
                  fillColor: ColorsManager.white,
                  onFieldSubmitted: (_) => _submitComment(context, sending),
                ),
              ),
              horizontalSpace(8),
              // ✅ استبدال Icon بـ MySvg مع حالة Loading
              GestureDetector(
                onTap: canSend ? () => _submitComment(context, sending) : null,
                child: sending
                    ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
                    : Opacity(
                  opacity: canSend ? 1.0 : 0.4,
                  child: const MySvg(image: 'send-2'), // ✅ استخدام MySvg
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}