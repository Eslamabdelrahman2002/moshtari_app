import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/ui/widgets/story_avater.dart';
import 'package:mushtary/core/theme/colors.dart';

import 'package:mushtary/features/home/data/models/home_data_model.dart';

import 'car_part_similar_story.dart';

class StoryAndTitleWidget extends StatelessWidget {
  final String title;

  // جديد: الإعلانات المشابهة (كموديل هوم)، افتراضيًا فاضي
  final List<HomeAdModel> similarAds;

  const StoryAndTitleWidget({
    super.key,
    required this.title,
    this.similarAds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final coverImage = _firstImage(similarAds);
    final ringColors = _buildSegmentColors(similarAds.length);

    return Row(
      children: [
        StoryAvater(
          coverImageUrl: coverImage,
          segmentColors: ringColors,
          radius: 30.r,
          onTap: () {
            if (similarAds.isEmpty) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CarPartSimilarStory(
                  items: similarAds,
                  segmentDuration: const Duration(seconds: 4),
                  useAllImagesOfEachAd: true,
                ),
              ),
            );
          },
        ),
        Container(
          constraints: BoxConstraints(maxWidth: 290.w),
          child: Text(
            title,
            style: TextStyles.font20Black500Weight,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  String? _firstImage(List<HomeAdModel> items) {
    for (final ad in items) {
      final imgs = ad.imageUrls ?? [];
      if (imgs.isNotEmpty && imgs.first.isNotEmpty) return imgs.first;
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