// lib/features/car_details/ui/widgets/car_details/widgets/car_details_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarDetailsAppBar extends StatelessWidget {
  const CarDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: MySvg(image: "arrow-right",color: ColorsManager.darkGray300,)),
          Spacer(),
          MySvg(image: "logo"),
          Spacer()

        ],
      ),
    );
  }
}