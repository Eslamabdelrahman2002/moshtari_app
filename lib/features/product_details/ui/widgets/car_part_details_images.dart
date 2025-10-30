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

class CarPartDetailsImages extends StatefulWidget {
  final List<String> images;
  final int adId;
  final String favoriteType;

  const CarPartDetailsImages({
    super.key,
    required this.images,
    required this.adId,
    this.favoriteType = 'ad',
  });

  @override
  State<CarPartDetailsImages> createState() => _CarPartDetailsImagesState();
}

class _CarPartDetailsImagesState extends State<CarPartDetailsImages> {
  int current = 0;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.isEmpty ? 1 : widget.images.length;

    return SizedBox(
      height: 260.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: total,
            onPageChanged: (i) => setState(() => current = i),
            itemBuilder: (_, i) {
              if (widget.images.isEmpty) {
                return const Center(child: MySvg(image: 'image'));
              }
              final url = widget.images[i];
              final scale = i == current ? 1.0 : 0.9;
              return AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 300),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                    const Center(child: MySvg(image: 'image')),
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 10.h,
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () =>
                        showDialog(context: context, builder: (_) => const ShareDialog()),
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      bool isFav = state is FavoritesLoaded &&
                          state.favoriteIds.contains(widget.adId);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? ColorsManager.redButton : Colors.white,
                        ),
                        onPressed: () => context.read<FavoritesCubit>().toggleFavorite(
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
        ],
      ),
    );
  }
}