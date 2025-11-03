import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/product_details/ui/widgets/share_dialog.dart';

import '../../../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../../../favorites/ui/logic/cubit/favorites_state.dart';

class CarDetailsImages extends StatefulWidget {
  final List<String> images;
  final int adId;
  final String favoriteType; // 'ad' أو 'auction'

  const CarDetailsImages({
    super.key,
    required this.images,
    required this.adId,
    this.favoriteType = 'ad',
  });

  @override
  State<CarDetailsImages> createState() => _CarDetailsImagesState();
}

class _CarDetailsImagesState extends State<CarDetailsImages> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<FavoritesCubit>();
      if (cubit.state is FavoritesInitial) {
        cubit.fetchFavorites();
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // ✅ الدالة الجديدة لفتح الـ Dialog المخصص للمشاركة
  void _shareAd() {
    final link = 'https://moshtary.com/ad/${widget.adId}';
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (_) => ShareDialog(shareLink: link),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.isEmpty ? 1 : widget.images.length;

    return SizedBox(
      height: 300.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ✅ PageView لعرض الصور
          PageView.builder(
            controller: pageController,
            itemCount: total,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, i) {
              if (widget.images.isEmpty) {
                return const Center(child: MySvg(image: 'image'));
              }
              final url = widget.images[i];
              final scale = (i == currentIndex) ? 1.0 : 0.9;
              return AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: scale,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300.h,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ✅ عدّاد النقاط في أسفل الصور
          if (total > 1)
            Positioned(
              bottom: 10.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final isActive = i == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    height: 6.h,
                    width: isActive ? 20.w : 8.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? ColorsManager.primary400
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  );
                }),
              ),
            ),

          // ✅ الشريط العلوي: المشاركة + المفضلة
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Row(
              children: [
                // زر المشاركة
                IconButton(
                  onPressed: _shareAd,
                  icon: const Icon(Icons.share, color: Colors.white),
                ),

                // زر المفضلة
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    bool isFav = false;
                    if (state is FavoritesLoaded) {
                      isFav = state.favoriteIds.contains(widget.adId);
                    }
                    return IconButton(
                      onPressed: () {
                        context.read<FavoritesCubit>().toggleFavorite(
                          type: widget.favoriteType,
                          id: widget.adId,
                        );
                      },
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
                            ? ColorsManager.redButton
                            : Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}