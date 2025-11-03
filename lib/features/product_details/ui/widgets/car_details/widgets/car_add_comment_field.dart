import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_state.dart';
// افتراض استيراد PrimaryTextFormField و MySvg
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

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
              // ✅ استبدال Expanded/TextField بـ SizedBox و PrimaryTextFormField
              SizedBox(
                width: 302.w,
                height: 40.h, // ارتفاع مناسب للـ TextFormField
                child: PrimaryTextFormField(
                  controller: _ctrl,
                  validationError: '',
                  hint: 'اكتب تعليقك هنا ...........',
                  fillColor: ColorsManager.white,
                  onFieldSubmitted: (_) => submit(),
                ),
              ),
              horizontalSpace(8),
              // ✅ استبدال الأيقونة بـ MySvg مع حالة Loading
              GestureDetector(
                onTap: canSend ? submit : null,
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