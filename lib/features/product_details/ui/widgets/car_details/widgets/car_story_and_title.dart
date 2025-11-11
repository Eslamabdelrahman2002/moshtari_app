// lib/features/car_details/ui/widgets/car_story_and_title.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/theme/colors.dart';
import '../../../../../real_estate_details/ui/widgets/colored_dotted_story_ring.dart';
import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart'; // 👈 تغيير إلى PublisherProductModel
import 'car_similar_story.dart'; // 👈 محدث

class CarStoryAndTitle extends StatelessWidget {
  final String title;
  final List<PublisherProductModel> similarAds; // 👈 تغيير النوع
  final void Function(PublisherProductModel product)? onOpenDetails; // 👈 تغيير النوع

  const CarStoryAndTitle({
    super.key,
    required this.title,
    this.similarAds = const [],
    this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (similarAds.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          title,
          style: TextStyles.font20Black500Weight,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final coverImage = _firstImage(similarAds);
    final ImageProvider imageProvider = (coverImage != null && coverImage.isNotEmpty)
        ? NetworkImage(coverImage)
        : const AssetImage('assets/images/img.png');

    final segmentColors = _buildSegmentColors(similarAds.length);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          ColoredDottedStoryRing(
            radius: 28.r,
            image: imageProvider,
            segmentColors: segmentColors,
            strokeWidth: 2.5,
            borderPadding: 3,
            gapAngleDeg: 12,
            startAngleDeg: -90,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CarSimilarStory(
                    items: similarAds, // 👈 تمرير PublisherProductModel
                    segmentDuration: const Duration(seconds: 4),
                    useAllImagesOfEachAd: false, // صورة واحدة لكل إعلان
                    onOpenDetails: onOpenDetails,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyles.font20Black500Weight,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 👈 تعديل لاستخدام PublisherProductModel
  String? _firstImage(List<PublisherProductModel> items) {
    for (final product in items) {
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) return product.imageUrl;
    }
    return null;
  }

  List<Color> _buildSegmentColors(int count) {
    if (count <= 0) return const [];
    final palette = <Color>[
      ColorsManager.primary500,
      ColorsManager.blueGradient2,
    ];
    return List<Color>.generate(count, (i) => palette[i % palette.length]);
  }
}