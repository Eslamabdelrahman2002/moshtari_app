// file: lib/features/real_estate/ui/widgets/map_details_sheet.dart (مُعدَّل)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';

// استيراد البطاقة الفردية التي سيتم عرضها بالداخل
import 'real_estate_map_item_detail.dart';

class MapDetailsSheet extends StatefulWidget {
  final List<RealEstateListModel> listings;
  final VoidCallback onClose;

  const MapDetailsSheet({
    super.key,
    required this.listings,
    required this.onClose,
  });

  @override
  State<MapDetailsSheet> createState() => _MapDetailsSheetState();
}

class _MapDetailsSheetState extends State<MapDetailsSheet> {
  // استخدام PageController لعرض جزء من البطاقة التالية
  // تم تعديل viewportFraction إلى 0.95 للسماح بـ Padding أفضل
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // دالة الانتقال لصفحة التفاصيل الكاملة
  void _navigateToDetails(RealEstateListModel listing) {
    // إغلاق البطاقة/الـ Stack أولاً

    NavX(context).pushNamed(
      Routes.realEstateDetailsScreen,
      arguments: listing.id,
    );
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listings.isEmpty) return const SizedBox.shrink();

    // ✅ استبدال DraggableScrollableSheet بـ Container/Column مع تحديد ارتفاع ثابت
    return Container(
      // تحديد ارتفاع مناسب للـ Sheet (الـ PageView 120 + مسافات 30)
      height: 150.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      // ✅ Padding حول الـ Container لضمان عدم ملامسة الحواف في real_estate_screen.dart
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر السحب (Grab Handle) - تم وضعه فقط للتصميم، لا يعمل كـ Drag
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: ColorsManager.dark200,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // مؤشر التمرير الأفقي (Dots)
          if (widget.listings.length > 1)
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.listings.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    height: 6.h,
                    width: _currentPage == index ? 20.w : 6.w,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? ColorsManager.primaryColor : ColorsManager.dark200,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                }),
              ),
            ),

          // الـ PageView (للتمرير الأفقي بين البطاقات)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.listings.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final listing = widget.listings[index];
                // لا نحتاج لـ Padding أفقي هنا لأن الـ viewportFraction قام بذلك
                return RealEstateMapItemDetails(
                  listing: listing,
                  // عرض زر الإغلاق فقط في البطاقة النشطة لتقليل الازدحام
                  onClose: index == _currentPage ? widget.onClose : null,
                  onTap: () => _navigateToDetails(listing),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
