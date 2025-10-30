import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/features/%20real_estate_request_details/ui/widgets/real_state_request_info_description.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import '../widgets/real_estate_request_info_grid_view.dart';
import '../widgets/request_owner_card.dart';
import '../../data/model/real_estate_request_details_model.dart';

class RealEstateRequestBody extends StatelessWidget {
  final RealEstateRequestDetailsModel property;
  final int id;

  const RealEstateRequestBody({
    super.key,
    required this.property,
    required this.id,
  });

  String _getRangeText(dynamic range) {
    if (range == null) return 'غير محدد';
    return range.toString();
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.font16Dark400Weight
                .copyWith(color: ColorsManager.darkGray300),
          ),
          Text(value, style: TextStyles.font14Black500Weight),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specs = property.realEstateDetails;
    final user = property.user;

    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 90.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, user, property, specs),
            const MyDivider(),

            // ✅ Grid المعلومات التفصيلية
            if (specs != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: RealEstateRequestInfoGridView(specs: specs)),
              ),
              const MyDivider(),
            ],

            // ✅ الوصف
            if ((specs?.notes?.isNotEmpty ?? false))
              RealEstateRequestInfoDescription(description: specs?.notes),

            // ✅ بيانات المعلن
            if (user != null) ...[
              const MyDivider(),
              RequestOwnerCard(user: user, isSeeker: true),
            ],

            const MyDivider(),
            _buildSimilarSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      RequestUserModel? user,
      RealEstateRequestDetailsModel property,
      RealEstateRequestSpecs? specs,
      ) {
    final address = '${property.city ?? 'غير محددة'}, ${property.region ?? ''}';
    final imageUrl = user?.profilePictureUrl;

    // 🏠 خريطة أنواع العقارات بالعربية
    const Map<String, String> typeMap = {
      'apartment': 'شقة',
      'villa': 'فيلا',
      'residential_land': 'أرض سكنية',
      'lands': 'أراضٍ',
      'apartments_and_rooms': 'شقق وغرف',
      'villas_and_palaces': 'فلل وقصور',
      'floor': 'دور',
      'buildings_and_towers': 'عمائر وأبراج',
      'chalets_and_resthouses': 'شاليهات واستراحات',
    };

    // 🏷️ خريطة الغرض بالعربية
    const Map<String, String> purposeMap = {
      'rent': 'إيجار',
      'sell': 'بيع',
    };

    // ترجمة القيم
    final typeAr = typeMap[specs?.realEstateType ?? ''] ??
        (specs?.realEstateType ?? 'غير محدد');
    final purposeAr = purposeMap[specs?.purpose ?? ''] ??
        (specs?.purpose ?? 'غير محدد');

    // 🔷 العنوان النهائي بالعربية
    final titleText = 'طلب $purposeAr - $typeAr';

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 العنوان + الموقع
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ العنوان بالعربي
                    Text(
                      titleText,
                      style: TextStyles.font20Black500Weight,
                    ),
                    verticalSpace(6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: ColorsManager.darkGray300),
                        horizontalSpace(4),
                        Flexible(
                          child: Text(
                            address,
                            style: TextStyles.font14Dark500Weight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (property.createdAt != null)
                      Text(
                        'تاريخ النشر: ${property.createdAt!.toLocal().toString().split(" ")[0]}',
                        style: TextStyles.font12DarkGray400Weight,
                      ),
                  ],
                ),
              ),
              // صورة المستخدم
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) =>
                    const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
            ],
          ),
          verticalSpace(12),

          // 🔹 الكارت الأساسي بالعربية (بدون رقم الطلب)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow('نوع العقار', typeAr),
                _infoRow('الغرض', purposeAr),
                _infoRow('السعر المتوقع', property.price ?? 'غير محدد'),
                _infoRow('قابل للتفاوض',
                    (specs?.isNegotiable ?? false) ? 'نعم' : 'لا'),
              ],
            ),
          ),
          verticalSpace(12),
        ],
      ),
    );
  }

  Widget _buildSimilarSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إعلانات مشابهة', style: TextStyles.font16DarkGrey500Weight),
          verticalSpace(8),
          Text(
            'لا توجد إعلانات مشابهة لهذا الطلب حالياً.',
            style: TextStyles.font14Black400Weight,
          ),
        ],
      ),
    );
  }
}