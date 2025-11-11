import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/widgets/show_more.dart';

class RealEstateInfoDescription extends StatefulWidget {
  final String? description;
  const RealEstateInfoDescription({
    super.key,
    required this.description,
  });

  @override
  State<RealEstateInfoDescription> createState() =>
      _RealEstateInfoDescriptionState();
}

class _RealEstateInfoDescriptionState extends State<RealEstateInfoDescription> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // للتأكد من أن العناصر تبدأ من اليمين
      children: [
        // 1. عنوان الوصف: تم إبقاء الـ Padding الخاص به فقط.
        Padding(
          padding: EdgeInsets.only(right: 16.w, top: 16.h, bottom: 8.h), // فقط Padding من اليمين والأعلى/الأسفل
          child: Align(
            alignment: Alignment.centerRight,
            // 💡 تم تعديل الـ Style ليطابق الـ UI المطلوب
            child: Text(
              'الوصف',
              style: TextStyles.font14DarkGray400Weight, // استخدام ستايل يتناسب مع العناوين الفرعية
            ),
          ),
        ),

        // 2. محتوى الوصف القابل للتوسيع/الطي
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // إزالة SingleChildScrollView لتجنب المشاكل داخل AnimatedContainer
          child: Padding(
            padding: EdgeInsets.only(right: 16.w, left: 16.w), // إضافة Padding من الجهتين
            child: Text(
              widget.description != null ? '${(widget.description)}' : '',
              style: TextStyles.font14Black500Weight,
              overflow:  TextOverflow.ellipsis ,
              maxLines: 10,
            ),
          ),
        ),

      ],
    );
  }

}
