// lib/features/product_details/ui/screens/full_view_product_details_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/full_view_content_widget.dart';

import '../../../home/data/models/home_data_model.dart';

class FullViewProductDetailsScreen extends StatefulWidget {
  final HomeAdModel adModel;

  const FullViewProductDetailsScreen({super.key, required this.adModel});

  @override
  State<FullViewProductDetailsScreen> createState() =>
      _FullViewProductDetailsScreenState();
}

class _FullViewProductDetailsScreenState
    extends State<FullViewProductDetailsScreen> {
  bool isFullView = false;
  late final PageController _pageCtrl;
  int _index = 0;

  static const String fallbackImage =
      'https://toyota-cdn.alghanim.com/camry2022.jpg';

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  List<String> get _images {
    final imgs = (widget.adModel.imageUrls ?? <String>[]);
    return imgs.isNotEmpty ? imgs : <String>[fallbackImage];
  }

  String get _statusLabel {
    final cond = (widget.adModel.condition ?? '').toLowerCase();
    if (cond == 'used' || cond == 'مستخدم' || cond == 'مستعملة') return 'مستعملة';
    if (cond == 'new' || cond == 'جديد' || cond == 'جديدة') return 'جديدة';
    return '';
  }

  void _openAdDetails() {
    final id = widget.adModel.id;
    final catId = widget.adModel.categoryId;

    if (catId == 1) {
      NavX(context).pushNamed(Routes.carDetailsScreen, arguments: id);
    } else if (catId == 2) {
      NavX(context).pushNamed(Routes.carPartDetailsScreen, arguments: id);
    } else if (catId == 3) {
      NavX(context).pushNamed(Routes.realEstateDetailsScreen, arguments: id);
    } else {
      NavX(context).pushNamed(Routes.productDetails, arguments: widget.adModel);
    }
  }

  Widget _glassButton({required Widget child, EdgeInsets? padding, VoidCallback? onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: padding ?? EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final count = images.length;
    final showChrome = !isFullView;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => setState(() => isFullView = !isFullView),
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: count,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final url = images[i];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined,
                                size: 48, color: Colors.grey),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.35),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.45),
                                ],
                                stops: const [0, .4, 1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                top: showChrome ? 12.h : -80.h,
                left: 12.w,
                right: 12.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _glassButton(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    const MySvg(image: 'white_logo_with_name'),
                    Row(
                      children: [
                        _glassButton(
                          onTap: () {},
                          child: const Icon(Icons.ios_share_rounded,
                              color: Colors.white),
                        ),
                        horizontalSpace(8),
                        _glassButton(
                          onTap: () {},
                          child: const Icon(Icons.favorite_border_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_statusLabel.isNotEmpty)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  top: showChrome ? 64.h : -80.h,
                  right: 12.w,
                  child: _glassButton(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Text(
                      _statusLabel,
                      style: TextStyles.font12White400Weight,
                    ),
                  ),
                ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                bottom: showChrome ? 112.h : -60.h,
                left: 0,
                right: 0,
                child: Center(
                  child: _glassButton(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    child: Text(
                      '${_index + 1} / $count',
                      style: TextStyles.font12White400Weight,
                    ),
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                left: 0,
                right: 0,
                bottom: showChrome ? 0 : -320.h,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 12.h,
                    bottom: 16.h + 64.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: FullViewContentWidget(adModel: widget.adModel),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: isFullView ? 0 : 72.h,
        curve: Curves.easeOut,
        decoration: BoxDecoration(color: Colors.black, boxShadow: [
          if (!isFullView)
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: Offset.zero,
            ),
        ]),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: isFullView
            ? const SizedBox.shrink()
            : PrimaryButton(
          text: 'عرض الإعلان',
          isPrefixIconInCenter: true,
          prefixIcon: const MySvg(image: 'eye_white'),
          onPressed: _openAdDetails,
        ),
      ),
    );
  }
}