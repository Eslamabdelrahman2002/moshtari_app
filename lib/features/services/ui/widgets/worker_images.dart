import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/product_details/ui/widgets/share_dialog.dart';

class WorkerImages extends StatefulWidget {
  final List<String> images;
  final String rate;
  const WorkerImages({super.key, required this.images, required this.rate});

  @override
  State<WorkerImages> createState() => _WorkerImagesState();
}

class _WorkerImagesState extends State<WorkerImages> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final effectiveImages = widget.images.isEmpty ? ['https://placeholder.com/default-worker-image'] : widget.images; // default إذا empty

    return SizedBox(
      height: 285.h,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: effectiveImages.length,
              onPageChanged: (value) => setState(() => _currentIndex = value),
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: 285.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(effectiveImages[index]),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) { // جديد: handling error
                        print('Image load error: $error');
                      },
                    ),
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.45, horizontal: 10.98),
                  decoration: BoxDecoration(
                    color: ColorsManager.secondary500,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.rate,
                        style: TextStyles.font14White500Weight.copyWith(height: 0.2),
                      ),
                      horizontalSpace(4),
                      const MySvg(
                        image: 'white-star',
                        width: 16,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (_currentIndex > 0) {
                        _pageController.animateToPage(_currentIndex - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      }
                    },
                    child: const MySvg(
                      image: 'arrow_right',
                      isImage: false,
                    ),
                  ),
                  horizontalSpace(4),

                  horizontalSpace(4),
                  InkWell(
                    onTap: () {
                      if (_currentIndex < effectiveImages.length - 1) {
                        _pageController.animateToPage(_currentIndex + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      }
                    },
                    child: const MySvg(
                      image: 'arrow_left',
                      isImage: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}