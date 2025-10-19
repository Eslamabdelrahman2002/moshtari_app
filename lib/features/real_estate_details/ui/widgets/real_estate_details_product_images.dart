import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/product_details/ui/widgets/share_dialog.dart';

class RealEstateDetailsProductImages extends StatefulWidget {
  final List<String> images;
  const RealEstateDetailsProductImages({super.key, required this.images});

  @override
  State<RealEstateDetailsProductImages> createState() =>
      _RealEstateDetailsProductImagesState();
}

class _RealEstateDetailsProductImagesState
    extends State<RealEstateDetailsProductImages> {
  PageController pageController = PageController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285.h,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: double.infinity,
                height: 285.h,
                child: CachedNetworkImage(
                    imageUrl: widget.images[index], fit: BoxFit.cover),
              );
            },
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.share,
                    size: 20.w,
                  ),
                  color: ColorsManager.white,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const ShareDialog();
                      },
                    );
                  },
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.favorite_outlined,
                    size: 20.w,
                  ),
                  color: ColorsManager.white,
                  onPressed: () {},
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}
