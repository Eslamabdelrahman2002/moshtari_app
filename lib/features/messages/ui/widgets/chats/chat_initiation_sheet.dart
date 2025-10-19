import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

Future<void> showChatInitiationSheet(
    BuildContext context, {
      required String receiverName,
      required void Function(String message) onInitiate,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ChatInitiationSheet(
      receiverName: receiverName,
      onInitiate: onInitiate,
    ),
  );
}

class ChatInitiationSheet extends StatefulWidget {
  final String receiverName;
  final void Function(String message) onInitiate;

  const ChatInitiationSheet({
    super.key,
    required this.receiverName,
    required this.onInitiate,
  });

  @override
  State<ChatInitiationSheet> createState() => _ChatInitiationSheetState();
}

class _ChatInitiationSheetState extends State<ChatInitiationSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onInitiate(message);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة رسالة لبدء المحادثة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بدء محادثة مع ${widget.receiverName}',
                style: TextStyles.font18Black500Weight.copyWith(
                  color: ColorsManager.primary400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalSpace(16),
              SecondaryTextFormField(
                controller: _controller,
                label: 'رسالتك الأولى',
                hint: 'مرحباً، أنا مهتم بالخدمة...',
                maxheight: 120.h,
                minHeight: 100.h,
                maxLines: 5,
              ),
              verticalSpace(20),
              PrimaryButton(
                text: 'بدء المحادثة وإرسال الرسالة',
                onPressed: _handleSend,
                width: double.infinity,
                height: 48.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}