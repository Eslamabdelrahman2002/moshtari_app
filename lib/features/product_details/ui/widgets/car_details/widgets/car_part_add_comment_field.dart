import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_state.dart';
// افتراض استيراد PrimaryTextFormField
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';
// قد تحتاج لعمل import لـ flutter/widgets.dart أيضاً

class CarPartAddCommentField extends StatefulWidget {
  final int adId;
  final VoidCallback? onSuccessRefresh;

  const CarPartAddCommentField({
    super.key,
    required this.adId,
    this.onSuccessRefresh,
  });

  @override
  State<CarPartAddCommentField> createState() => _CarPartAddCommentFieldState();
}

class _CarPartAddCommentFieldState extends State<CarPartAddCommentField> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Keep listener for UI update, especially for submit button state
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
        // ✅ Can send when not submitting and text is not empty
        final canSend = !sending && _ctrl.text.trim().isNotEmpty;

        void submit() {
          if (!canSend) return;
          context.read<CommentSendCubit>().submit(
            adId: widget.adId,
            comment: _ctrl.text.trim(),
          );
        }

        // ✅ تم تعديل الأبعاد لتطابق تصميم CommentTextField
        return Container(
          // تم تقليص الارتفاع
          height: 56.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h), // تعديل الـ padding
          decoration: BoxDecoration(
            color: ColorsManager.dark50,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              // ✅ استخدام PrimaryTextFormField وتحديد الـ dimensions
              SizedBox(
                width: 302.w,
                height: 40.h, // تم تحديد ارتفاع مُناسب لـ TextField
                child: PrimaryTextFormField(
                  controller: _ctrl,
                  validationError: '', // لا نحتاج validation error هنا
                  hint: 'اكتب تعليقك هنا ...........',
                  fillColor: ColorsManager.white,
                  // ✅ Handle submit on keyboard done button
                  onFieldSubmitted: (_) => submit(),
                ),
              ),
              horizontalSpace(8),
              // ✅ استخدام MySvg لزر الإرسال مع حالة Loading
              GestureDetector(
                onTap: canSend ? submit : null,
                child: sending
                    ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
                    : Opacity( // ✅ إضافة Opacity للتعبير عن حالة canSend
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