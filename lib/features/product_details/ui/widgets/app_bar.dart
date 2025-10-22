import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // تأكد من استيراد هذه المكتبة إذا كنت تستخدمها
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ProductScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton; // تحكم في عرض زر العودة (السهم)
  final bool useCloseButton; // إذا كانت true، تعرض زر X (إغلاق) بدلاً من السهم
  final VoidCallback? onLeadingPressed; // إجراء مخصص لزر العودة/الإغلاق

  const ProductScreenAppBar({
    super.key,
    this.showBackButton = true,
    this.useCloseButton = false,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كانت هناك شاشة للعودة إليها (إذا لم يتم تعيين onLeadingPressed مسبقاً)
    final bool canPop = Navigator.of(context).canPop();

    // إذا لم يتم تحديد إجراء مخصص وكان زر العودة معروضاً، فاستخدم Navigator.pop
    final VoidCallback defaultAction = onLeadingPressed ?? () {
      if (canPop) {
        Navigator.pop(context);
      }
    };

    // أيقونة الزر الأمامي (Leading Icon)
    final IconData leadingIcon = useCloseButton ? Icons.close : Icons.arrow_back_ios_new_rounded;
    // حجم الأيقونة (لجعلها أكبر قليلاً وأكثر وضوحاً)
    final double iconSize = useCloseButton ? 24.0 : 20.0;

    return AppBar(
      title: const MySvg(
        image: 'logo',
        isImage: false,
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,

      // الزر الأمامي (Leading Widget)
      leading: !showBackButton
          ? const SizedBox.shrink() // إخفاء الزر بالكامل إذا كانت showBackButton = false
          : IconButton(
        onPressed: defaultAction,
        icon: Padding(
          // إضافة حشوة (padding) لزر العودة (السهم) لجعله في المنتصف بشكل أفضل
          padding: EdgeInsets.only(right: useCloseButton ? 0 : 4.0),
          child: Icon(
            leadingIcon,
            color: ColorsManager.darkGray300,
            size: iconSize,
            // قلب اتجاه السهم إذا لم يكن زر إغلاق (X)
            textDirection: useCloseButton ? TextDirection.ltr : TextDirection.rtl,
          ),
        ),
      ),
    );
  }

  // تطبيق واجهة PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}