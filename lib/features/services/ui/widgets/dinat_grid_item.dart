// lib/features/services/ui/widgets/dinat_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

// لو اسم الملف عندك dinat_trip.dart غيّر الاستيراد بما يوافق اسم الملف

import '../../data/model/dinat_trip.dart';
import '../../logic/cubit/service_offer_cubit.dart';
import '../../logic/cubit/service_offer_state.dart';
import 'dinat_trip_details_dialog.dart';

class DinatGridItem extends StatelessWidget {
  final DynaTrip trip;
  final VoidCallback? onRequestTap;

  const DinatGridItem({
    super.key,
    required this.trip,
    this.onRequestTap,
  });

  String _fmtDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _showDetails(BuildContext context) {
    final details = DinatTripDetails(
      title: 'رحلة دينا - من ${trip.fromCityNameAr} إلى ${trip.toCityNameAr}',
      pickUpAddress: trip.fromCityNameAr,
      dropOffAddress: trip.toCityNameAr,
      mapImage: 'assets/images/map_image.png',
    );
    showDialog(context: context, builder: (ctx) => DinatTripDetailsDialog(details: details));
  }

  // فتح شيت إرسال عرض
  void _showSendOfferSheet(BuildContext context) {
    final priceCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return BlocProvider<ServiceOfferCubit>(
          create: (_) => getIt<ServiceOfferCubit>(),
          child: BlocConsumer<ServiceOfferCubit, ServiceOfferState>(
            listenWhen: (p, c) => c is ServiceOfferSuccess || c is ServiceOfferFailure,
            listener: (ctx, state) {
              if (state is ServiceOfferSuccess) {
                Navigator.pop(ctx); // اغلق الشيت
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is ServiceOfferFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
            builder: (ctx, state) {
              final submitting = state is ServiceOfferSubmitting;
              return Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + bottom),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40.w, height: 4.h,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100)),
                      ),
                      verticalSpace(12),
                      Row(
                        children: [
                          Container(
                            width: 40.w, height: 40.w,
                            decoration: BoxDecoration(color: ColorsManager.primary50, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.local_shipping_outlined, color: ColorsManager.primary400),
                          ),
                          horizontalSpace(10),
                          Expanded(child: Text('إرسال عرض لخدمة النقل', style: TextStyles.font18Black500Weight)),
                        ],
                      ),
                      verticalSpace(12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('السعر (ريال)', style: TextStyles.font14Dark500Weight),
                      ),
                      verticalSpace(6),
                      TextFormField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'اكتب السعر المقترح',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'أدخل السعر';
                          final num? n = num.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), ''));
                          if (n == null || n <= 0) return 'أدخل سعرًا صحيحًا';
                          return null;
                        },
                      ),
                      verticalSpace(12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('ملاحظة (اختياري)', style: TextStyles.font14Dark500Weight),
                      ),
                      verticalSpace(6),
                      TextFormField(
                        controller: msgCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'رسالة للمستخدم (اختياري)',
                          prefixIcon: const Icon(Icons.message_outlined),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      verticalSpace(16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: submitting ? null : () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('إلغاء', style: TextStyles.font14Black500Weight),
                            ),
                          ),
                          horizontalSpace(12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: submitting
                                  ? null
                                  : () {
                                if (!formKey.currentState!.validate()) return;
                                final num price = num.tryParse(priceCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                                // مبدئيًا نستخدم trip.id كـ request_id (عدّلها لو عندك requestId منفصل)
                                ctx.read<ServiceOfferCubit>().send(
                                  requestId: trip.id,
                                  price: price,
                                  message: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
                                );
                              },
                              icon: submitting
                                  ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.send_rounded),
                              label: Text(submitting ? 'جارٍ الإرسال...' : 'إرسال'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.primary400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: Size(double.infinity, 46.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dep = DateTime.tryParse(trip.departureDateIso)?.toLocal();
    final dateLabel = dep != null ? _fmtDate(dep) : '';
    final timeLabel = dep != null ? _fmtTime(dep) : '';
    final sizeLabel = trip.dynaCapacity;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 4,
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: Image.asset('assets/images/map_image.png', fit: BoxFit.cover),
              ),
            ),
            verticalSpace(8),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyles.font14Black500Weight,
                      children: [
                        TextSpan(text: trip.fromCityNameAr),
                        TextSpan(text: ' ---> ', style: TextStyles.font14Black500Weight.copyWith(color: ColorsManager.primaryColor)),
                        TextSpan(text: trip.toCityNameAr),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(6),
            Row(
              children: [
                MySvg(image: 'size', width: 12.w, height: 12.h),
                horizontalSpace(4),
                Text('سعة الحمولة: ', style: TextStyles.font12DarkGray400Weight),
                Expanded(
                  child: Text(sizeLabel, style: TextStyles.font12Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            verticalSpace(4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      MySvg(image: 'calendar', width: 16.w, height: 16.h),
                      horizontalSpace(4),
                      Expanded(child: Text(dateLabel, style: TextStyles.font12Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                horizontalSpace(8),
                Expanded(
                  child: Row(
                    children: [
                      MySvg(image: 'clock', width: 16.w, height: 16.h),
                      horizontalSpace(4),
                      Expanded(child: Text(timeLabel, style: TextStyles.font12Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpace(8),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundImage: (trip.providerImage.isNotEmpty)
                      ? NetworkImage(trip.providerImage)
                      : const AssetImage('assets/images/prof.png') as ImageProvider,
                ),
                horizontalSpace(6),
                Expanded(child: Text(trip.providerName, style: TextStyles.font12Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis)),
                horizontalSpace(4),
                MySvg(image: 'judge', width: 16.w, height: 16.h),
              ],
            ),
            verticalSpace(10),
            PrimaryButton(
              height: 36.h,
              backgroundColor: ColorsManager.primary500,
              textColor: Colors.white,
              text: 'طلب خدمة',
              // إن أردت سلوكًا مخصصًا، مرّر onRequestTap من الاستدعاء
              onPressed: onRequestTap ?? () => _showSendOfferSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}