import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// alias لموديل العقارات
import 'package:mushtary/features/real_estate_details/date/model/real_estate_details_model.dart' as re;

import '../screens/real_estate_details_screen.dart';

class RealEstateSimilarGallery extends StatefulWidget {
  final List<re.SimilarAd> items;
  final int initialIndex;

  const RealEstateSimilarGallery({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  State<RealEstateSimilarGallery> createState() => _RealEstateSimilarGalleryState();
}

class _RealEstateSimilarGalleryState extends State<RealEstateSimilarGallery> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _imageOf(re.SimilarAd ad) {
    if (ad.imageUrls.isNotEmpty && ad.imageUrls.first.isNotEmpty) {
      return ad.imageUrls.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final ad = items[i];
              final img = _imageOf(ad);
              return Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 3,
                  child: img != null
                      ? Image.network(
                    img,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _placeholder(),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  )
                      : _placeholder(),
                ),
              );
            },
          ),

          // أعلى: زر إغلاق + العداد
          Positioned(
            top: 24.h,
            left: 12.w,
            right: 12.w,
            child: Row(
              children: [
                _circleIcon(
                  context,
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_index + 1}/${items.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // أسفل: عنوان + زر التفاصيل
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _titleChip(items[_index].title),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: () {
                          final ad = items[_index];
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RealEstateDetailsScreen(id: ad.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('عرض التفاصيل'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _circleIcon(
                      context,
                      icon: Icons.share,
                      onTap: () {
                        // TODO: شارك الرابط/المعرّف حسب نظامك
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleChip(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _placeholder() => Icon(Icons.image_not_supported, color: Colors.white38, size: 72.sp);

  Widget _circleIcon(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 28.r,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}