import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/load_image.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/social_media_share_widget.dart';

class AdvertisingMarketDialog extends StatelessWidget {
  final HomeAdModel adModel;
  final String? phone; // رقم الهاتف اختياري

  const AdvertisingMarketDialog({
    super.key,
    required this.adModel,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = (adModel.imageUrls != null && adModel.imageUrls!.isNotEmpty)
        ? adModel.imageUrls!.first
        : null;

    final String title = adModel.title;
    final String location = adModel.location;
    final String phoneNumber = phone ?? '+966 21354686'; // غيّره عند توفره من API

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عنوان الديالوج
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('سوق للإعلان', style: TextStyles.font20Black500Weight),
              horizontalSpace(8),
              const MySvg(image: 'info_icon', width: 16, height: 16),
            ],
          ),

          verticalSpace(20),

          // بطاقة المحتوى
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorsManager.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: AspectRatio(
                    aspectRatio: 12 / 9,
                    child: LoadImage(

                      image: imageUrl, // URL من الـ API
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                verticalSpace(12),

                // العنوان
                Text(
                  title,
                  style: TextStyles.font16Black500Weight,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),

                verticalSpace(8),

                // الموقع
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        location,
                        style: TextStyles.font12Black400Weight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    horizontalSpace(6),
                    const MySvg(image: 'location-yellow', width: 16, height: 16),
                  ],
                ),

                verticalSpace(12),

                // رقم الهاتف بشكل زر أنيق
                Container(
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6FF),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE6EEFF)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.call, size: 16.sp, color: Colors.white),
                      ),
                      horizontalSpace(10),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E5EFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          verticalSpace(16),

          SocialMediaShareWidget(
            adId: adModel.id,
            adTitle: adModel.title,
          ),

          verticalSpace(16),

          // زر حسناً
          PrimaryButton(
            text: 'حسنا',
            backgroundColor: ColorsManager.primary50,
            textColor: ColorsManager.primary500,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final Color color;
  final String icon;

  const _CircleIcon({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: MySvg(image: icon, width: 24.w, height: 24.w),
    );
  }
}