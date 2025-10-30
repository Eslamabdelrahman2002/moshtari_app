import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import 'package:mushtary/features/real_estate_details/date/model/real_estate_details_model.dart' as re;
import 'package:mushtary/features/real_estate_details/ui/widgets/colored_dotted_story_ring.dart';


import '../../../../core/theme/colors.dart';
import 'RealEstateSimilarStory.dart';

class RealEstateStoryAndTitleWidget extends StatelessWidget {
  final String? title;
  final List<re.SimilarAd> similarAds;

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
      padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                    items: similarAds,
                    segmentDuration: const Duration(seconds: 4),
                    useAllImagesOfEachAd: true,
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

  // اختار أول صورة متاحة كغلاف
  String? _firstAvailableImage(List<re.SimilarAd> items) {
    for (final ad in items) {
      if (ad.imageUrls.isNotEmpty && ad.imageUrls.first.isNotEmpty) {
        return ad.imageUrls.first;
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