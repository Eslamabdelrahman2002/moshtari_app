import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/product_details/ui/widgets/share_dialog.dart';

import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_state.dart';

class OtherAdDetailsImages extends StatefulWidget {
  final List<String> images;
  final int adId;
  final String favoriteType;
  final String? status;

  const OtherAdDetailsImages({
    super.key,
    required this.images,
    required this.adId,
    this.favoriteType = 'ad',
    this.status,
  });

  @override
  State<OtherAdDetailsImages> createState() => _OtherAdDetailsImagesState();
}

class _OtherAdDetailsImagesState extends State<OtherAdDetailsImages> {
  int current = 0;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    // ✅ تعطيل الـ viewportFraction لتظهر الصورة بالحجم الكامل
    _ctrl = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// ✅ دالة مشاركة موحّدة
  void _shareAd(BuildContext context) {
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
      height: 285.h,
      width: double.infinity,
      child: Stack(
        children: [
          // ✅ عرض الصور يشغل العرض كاملاً
          PageView.builder(
            controller: _ctrl,
            itemCount: total,
            onPageChanged: (i) => setState(() => current = i),
            itemBuilder: (_, i) {
              if (widget.images.isEmpty) {
                return const Center(child: MySvg(image: 'image'));
              }

              final url = widget.images[i];
              return ClipRRect(
                borderRadius: BorderRadius.zero, // لا انحناء لحافة الصورة
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: double.infinity,
                  height: 285.h,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                  const Center(child: MySvg(image: 'image')),
                ),
              );
            },
          ),

          // ✅ شارة الحالة (جديدة / مستعملة ...)
          if ((widget.status ?? '').isNotEmpty)
            Positioned(
              top: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  widget.status!,
                  style: TextStyles.font12Black400Weight,
                ),
              ),
            ),

          // ✅ أزرار المشاركة والمفضلة في الزاوية العلوية اليمنى
          Positioned(
            top: 16.h,
            left: 12.w,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => _shareAd(context),
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final isFav = state is FavoritesLoaded &&
                          state.favoriteIds.contains(widget.adId);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? ColorsManager.redButton
                              : Colors.white,
                        ),
                        onPressed: () => context
                            .read<FavoritesCubit>()
                            .toggleFavorite(
                          type: widget.favoriteType,
                          id: widget.adId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ✅ مؤشّر الصفحات في الأسفل
          if (widget.images.length > 1)
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final active = i == current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    height: 6.h,
                    width: active ? 20.w : 8.w,
                    decoration: BoxDecoration(
                      color: active
                          ? ColorsManager.primary400
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}