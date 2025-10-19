import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class WorkWithUsIntroScreen extends StatelessWidget {
  const WorkWithUsIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsManager.white,
        centerTitle: true,
        title: Text('العمل معنا', style: TextStyles.font20Black500Weight),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios,color: ColorsManager.darkGray300,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            verticalSpace(32),
            CircleAvatar(
              radius: 75.w,
              backgroundColor: ColorsManager.purple, // This will be the circle's background color
              // ✨ FIX: Use the 'child' property for widgets like MySvg
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: MySvg(
                  image: 'logo',
                  color: ColorsManager.white,
                  // Adjust the SVG size to fit nicely inside the circle
                  width: 60.w,
                  height: 60.w,
                ),
              ),
            ),
            verticalSpace(16),
            Text('العمل معنا', style: TextStyles.font24Black700Weight),
            verticalSpace(16),
            Text(
              'هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة، لقد تم توليد هذا النص من مولد النصوص العربى، حيث يمكنك أن تولد مثل هذا النص أو العديد من النصوص الأخرى إضافة إلى زيادة عدد الحروف التى يولدها التطبيق.',
              textAlign: TextAlign.center,
              style: TextStyles.font14DarkGray400Weight,
            ),
            const Spacer(),
            PrimaryButton(
              text: 'التالي',
              onPressed: () {
                context.pushNamed(Routes.workWithUsFormScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}