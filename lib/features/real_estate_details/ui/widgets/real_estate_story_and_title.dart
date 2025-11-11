import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart'; // 👈 تغيير إلى PublisherProductModel للـ story
import 'package:mushtary/features/real_estate_details/ui/widgets/colored_dotted_story_ring.dart';

import '../../../../core/theme/colors.dart';
import 'RealEstateSimilarStory.dart'; // 👈 محدث لـ PublisherProductModel

class RealEstateStoryAndTitleWidget extends StatelessWidget {
  final String? title;
  final List<PublisherProductModel> similarAds; // 👈 تغيير النوع للـ story (إعلانات الـ owner)

  const RealEstateStoryAndTitleWidget({
    super.key,
    required this.title,
    this.similarAds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final String? coverImage = _firstAvailableImage(similarAds);
    final ImageProvider imageProvider = coverImage != null && coverImage.isNotEmpty
        ? NetworkImage(coverImage)
        : const AssetImage('assets/images/img.png');

    // ألوان القطاعات في الحلقة (بتتكرر حسب عدد الإعلانات المشابهة)
    final segmentColors = _buildSegmentColors(similarAds.length);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (similarAds.isNotEmpty) // 👈 عرض الـ ring فقط إذا كانت القائمة غير فارغة
            ColoredDottedStoryRing(
              radius: 28.r,
              image: imageProvider,
              segmentColors: segmentColors,
              strokeWidth: 2.5,
              borderPadding: 3,
              gapAngleDeg: 12,     // مسافة صغيرة بين القطاعات
              startAngleDeg: -90,  // يبدأ من أعلى مثل ستوريات إنستغرام
              onTap: () {
                if (similarAds.isEmpty) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RealEstateSimilarStory(
                      items: similarAds, // 👈 تمرير PublisherProductModel (إعلانات الـ owner)
                      segmentDuration: const Duration(seconds: 4),
                      useAllImagesOfEachAd: false, // 👈 بسيط، لأن imageUrl واحدة فقط
                    ),
                  ),
                );
              },
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title ?? '',
              style: TextStyles.font20Black500Weight,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // 👈 تعديل لاستخدام PublisherProductModel (للـ story)
  String? _firstAvailableImage(List<PublisherProductModel> items) {
    for (final product in items) {
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        return product.imageUrl;
      }
    }
    return null;
  }

  // بنبني ألوان القطاعات من ألوان البراند
  List<Color> _buildSegmentColors(int count) {
    if (count <= 0) return const [];
    final palette = <Color>[
      ColorsManager.primary500,
      ColorsManager.blueGradient2,
    ];
    return List<Color>.generate(count, (i) => palette[i % palette.length]);
  }
}