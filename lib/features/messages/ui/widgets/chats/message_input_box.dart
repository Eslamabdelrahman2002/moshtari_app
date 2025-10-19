import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class MessageInputBox extends StatefulWidget {
  final int receiverId;
  final void Function(String message)? onSend;

  const MessageInputBox({
    super.key,
    required this.receiverId,
    this.onSend,
  });

  @override
  State<MessageInputBox> createState() => _MessageInputBoxState();
}

class _MessageInputBoxState extends State<MessageInputBox> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      widget.onSend?.call(text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 20.r,
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(onTap: () {}, child: const MySvg(image: 'mice')),
          horizontalSpace(16),
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: TextFormField(
                controller: _messageController,
                keyboardType: TextInputType.text,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'أكتب رسالتك هنا...',
                  hintStyle: TextStyles.font12Dark500400Weight,
                  fillColor: const Color(0xffFAFAFA),
                  filled: true,
                  suffixIcon: InkWell(
                    onTap: _handleSend,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      child: const MySvg(image: 'send_message'),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.w),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.w),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.w),
                  ),
                ),
              ),
            ),
          ),
          horizontalSpace(16),
          InkWell(onTap: () {}, child: Icon(Icons.add, size: 32.sp, color: ColorsManager.black)),
        ],
      ),
    );
  }
}