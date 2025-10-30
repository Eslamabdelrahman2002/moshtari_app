// lib/features/car_details/ui/widgets/car_story_and_title.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/theme/colors.dart';
import '../../../../../real_estate_details/ui/widgets/colored_dotted_story_ring.dart';
import '../../../../data/model/car_details_model.dart';
import 'car_similar_story.dart';

class CarStoryAndTitle extends StatelessWidget {
  final String title;
  final List<SimilarCarAdModel> similarAds;
  final void Function(SimilarCarAdModel ad)? onOpenDetails;

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
                    items: similarAds,
                    segmentDuration: const Duration(seconds: 4),
                    useAllImagesOfEachAd: false, // صورة واحدة لكل إعلان مشابه
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

  String? _firstImage(List<SimilarCarAdModel> items) {
    for (final ad in items) {
      final img = ad.image;
      if (img != null && img.isNotEmpty) return img;
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