// lib/core/widgets/primary/load_image.dart

import 'package:flutter/material.dart';

class LoadImage extends StatelessWidget {
  final String? image; // جعله قابلاً ليكون null
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String placeholder; // صورة افتراضية في حالة الخطأ أو إذا كان الرابط null

  const LoadImage({
    super.key,
    required this.image,
    this.color,
    this.width,
    this.height,
    this.fit,
    // يمكنك وضع صورة placeholder في مجلد assets
    this.placeholder = 'assets/images/placeholder.png',
  });

  @override
  Widget build(BuildContext context) {
    // تحقق مما إذا كان الرابط صالحًا ويبدأ بـ http
    if (image != null && image!.startsWith('http')) {
      return Image.network(
        image!,
        width: width,
        height: height,
        color: color,
        fit: fit,
        // عرض placeholder أثناء التحميل
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        // عرض placeholder في حالة حدوث خطأ
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            placeholder,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }
    // إذا لم يكن رابطًا، افترض أنه اسم ملف في assets
    else if (image != null && image!.isNotEmpty) {
      return Image.asset(
        'assets/images/$image.png', // الافتراض أنه png
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            placeholder,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }
    // في حالة كان الرابط null أو فارغًا
    else {
      return Image.asset(
        placeholder,
        width: width,
        height: height,
        fit: fit,
      );
    }
  }
}