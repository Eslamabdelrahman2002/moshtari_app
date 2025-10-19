// lib/features/create_ad/ui/screens/real_estate/real_estate_view_iformations_screen.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_real_estate_ad_add_photo_video.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import '../../../../services/ui/widgets/map_picker_screen.dart';
import 'logic/cubit/real_estate_ads_cubit.dart';
import 'logic/cubit/real_estate_ads_state.dart';

class RealEstateViewIformationsScreen extends StatefulWidget {
  const RealEstateViewIformationsScreen({super.key});

  @override
  State<RealEstateViewIformationsScreen> createState() =>
      _RealEstateViewIformationsScreenState();
}

class _RealEstateViewIformationsScreenState
    extends State<RealEstateViewIformationsScreen> {
  final ImagePicker _picker = ImagePicker();

  // حالة السويتشات
  bool isCommentsAvailable = true;
  bool isAllowedToAdvertisingMarketing = true;

  // الموقع المختار
  gmap.LatLng? _pickedLatLng;
  String? _pickedAddressAr;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<RealEstateAdsCubit>().addImage(File(image.path));
      if (mounted) setState(() {});
    }
  }

  // اختيار الموقع من الخريطة
  Future<void> _openMapPicker() async {
    FocusScope.of(context).unfocus();
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (picked != null) {
      setState(() {
        _pickedLatLng = picked.latLng;
        _pickedAddressAr = picked.addressAr;
      });
      // تمرير القيم للكيوبت
      context
          .read<RealEstateAdsCubit>()
          .setLatLng(picked.latLng.latitude, picked.latLng.longitude);
    }
  }

  // Dialog نجاح
  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: Text(
            'تم نشر الإعلان بنجاح',
            style: TextStyles.font18Black500Weight.copyWith(color: ColorsManager.primary400),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'لقد تم رفع إعلانك العقاري بنجاح. سيصبح متاحاً للمشاهدة قريباً.',
                  style: TextStyles.font14Dark500Weight.copyWith(color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('العودة للرئيسية', style: TextStyles.font14Primary500Weight),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  // عنصر واجهة لاختيار الموقع من الخريطة
  Widget _mapPickerTile() {
    final hasValue = _pickedLatLng != null || (_pickedAddressAr != null && _pickedAddressAr!.isNotEmpty);
    final subtitle = _pickedAddressAr ??
        (_pickedLatLng != null
            ? '(${_pickedLatLng!.latitude.toStringAsFixed(6)}, ${_pickedLatLng!.longitude.toStringAsFixed(6)})'
            : 'اختر الموقع على الخريطة أو ابحث');

    return InkWell(
      onTap: _openMapPicker,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ColorsManager.dark200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: ColorsManager.primaryColor),
            horizontalSpace(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('موقع الإعلان', style: TextStyles.font12DarkGray400Weight),
                  verticalSpace(2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: hasValue ? TextStyles.font14Black500Weight : TextStyles.font14DarkGray400Weight,
                  ),
                ],
              ),
            ),
            horizontalSpace(8),
            const Icon(Icons.chevron_left_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RealEstateAdsCubit, RealEstateAdsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showSuccessDialog(context);
        }
      },
      builder: (context, state) {
        return SizedBox(
          height: 535.h,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الصور/الفيديو
                  CreateRealEstateAdAddPhotoVideo(
                    pickImage: _pickImage,
                    remove: (index) {
                      context.read<RealEstateAdsCubit>().removeImageAt(index);
                      if (mounted) setState(() {});
                    },
                    pickedImages: state.images,
                  ),
                  verticalSpace(16.h),

                  // عنوان الإعلان
                  SecondaryTextFormField(
                    label: 'عنوان الاعلان',
                    hint: 'مثال: فيلا للبيع في حي النسيم',
                    maxheight: 56.h,
                    minHeight: 56.h,
                    onChanged: context.read<RealEstateAdsCubit>().setTitle,
                  ),
                  verticalSpace(16.h),

                  // وصف العرض
                  SecondaryTextFormField(
                    label: 'وصف العرض',
                    hint: 'أكتب وصف للمنتج...',
                    maxheight: 96.w,
                    minHeight: 96.w,
                    maxLines: 4,
                    onChanged: context.read<RealEstateAdsCubit>().setDescription,
                  ),
                  verticalSpace(16.h),

                  // اختيار الموقع من الخريطة (بديل لحقول Lat/Lng)
                  _mapPickerTile(),
                  verticalSpace(16.h),

                  // السويتشات
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          inactiveTrackColor: ColorsManager.lightGrey,
                          thumbColor: ColorsManager.secondary500,
                          activeTrackColor: ColorsManager.secondary200,
                          value: isCommentsAvailable,
                          onChanged: (value) {
                            setState(() => isCommentsAvailable = value);
                            context.read<RealEstateAdsCubit>().setAllowComments(value);
                          },
                        ),
                      ),
                      Text('السماح بالتعليق على الاعلان', style: TextStyles.font14Dark500Weight),
                    ],
                  ),
                  verticalSpace(4),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          inactiveTrackColor: ColorsManager.lightGrey,
                          thumbColor: ColorsManager.secondary500,
                          activeTrackColor: ColorsManager.secondary200,
                          value: isAllowedToAdvertisingMarketing,
                          onChanged: (value) {
                            setState(() => isAllowedToAdvertisingMarketing = value);
                            context.read<RealEstateAdsCubit>().setAllowMarketing(value);
                          },
                        ),
                      ),
                      Text('السماح بتسويق الاعلان', style: TextStyles.font14Dark500Weight),
                    ],
                  ),
                  verticalSpace(16),

                  // زر النشر
                  NextButtonBar(
                    title: state.submitting ? 'جاري النشر...' : 'نشر الاعلان',
                    onPressed: state.submitting
                        ? null
                        : () {
                      debugPrint('[RealEstate] Publish button pressed');
                      context.read<RealEstateAdsCubit>().submit(
                        allowComments: isCommentsAvailable,
                        allowMarketing: isAllowedToAdvertisingMarketing,
                      );
                    },
                  ),
                  verticalSpace(16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}