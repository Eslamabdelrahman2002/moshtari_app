import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/data/models/auctions/auctions_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/share_dialog.dart';

class ProductImages extends StatefulWidget {
  final List<String> images;
  final String status;
  final AuctionsModel auctionsModel;
  const ProductImages(
      {super.key,
      required this.images,
      required this.status,
      required this.auctionsModel});

  @override
  State<ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285.h,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => _currentIndex = value),
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: 285.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.images[index]),
                        fit: BoxFit.cover),
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.45, horizontal: 10.98),
                  decoration: BoxDecoration(
                    color: ColorsManager.secondary500,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    widget.status,
                    style: TextStyles.font14Blue500Weight,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  color: ColorsManager.white,
                  onPressed: () {
                    final link = 'https://moshtary.com/auction/${widget.auctionsModel.id}';
                    showDialog(
                      context: context,
                      builder: (_) => ShareDialog(shareLink: link),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_outlined),
                  color: ColorsManager.white,
                  onPressed: () {},
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorsManager.black,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '${widget.images.length} / ${_currentIndex + 1}',
                      style: TextStyles.font12White400Weight,
                    ),
                  ),
                  horizontalSpace(4),
                  InkWell(
                    onTap: () {
                      if (_currentIndex < widget.images.length - 1) {
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                child: InkWell(
                    onTap: () {
                      NavX(context).pushNamed(Routes.fullViewProductDetailsScreen,
                          arguments: widget.auctionsModel);
                    },
                    child: const MySvg(image: 'frame', isImage: false))),
          )
        ],
      ),
    );
  }
}
