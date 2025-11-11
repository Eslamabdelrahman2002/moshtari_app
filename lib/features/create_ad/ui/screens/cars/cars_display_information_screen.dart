// lib/features/create_ad/ui/screens/car/cars_display_information_screen.dart
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import '../../../../services/ui/widgets/map_picker_screen.dart';
import '../../../data/car/utils/car_mappers.dart';
import 'logic/cubit/car_ads_cubit.dart';
import 'logic/cubit/car_ads_state.dart';

class CarsDisplayInformationScreen extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool popOnSuccess; // جديد: لتحديد هل نعمل pop عند النجاح

  const CarsDisplayInformationScreen({
    super.key,
    this.onPressed,
    this.popOnSuccess = true, // افتراضي: نعم اعمل pop على النجاح
  });

  @override
  State<CarsDisplayInformationScreen> createState() => _CarsDisplayInformationScreenState();
}

class _CarsDisplayInformationScreenState extends State<CarsDisplayInformationScreen> {
  final _picker = ImagePicker();

  // المتحكمات
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<CarAdsCubit>().state;

    _titleCtrl = TextEditingController(text: state.title ?? '');
    _descriptionCtrl = TextEditingController(text: state.description ?? '');
    _priceCtrl = TextEditingController(text: state.price?.toString() ?? '');
    _phoneCtrl = TextEditingController(text: state.phone ?? '');

    String locationText = 'اختر الموقع على الخريطة أو ابحث';
    if (state.addressAr != null && state.addressAr!.isNotEmpty) {
      locationText = state.addressAr!;
    } else if (state.latitude != null && state.longitude != null) {
      locationText =
      'تم اختيار الموقع (خ.ط: ${state.latitude!.toStringAsFixed(4)}, د.ع: ${state.longitude!.toStringAsFixed(4)})';
    }
    _locationCtrl = TextEditingController(text: locationText);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages(BuildContext context) async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
      limit: 10,
    );
    if (images.isNotEmpty) {
      final cubit = context.read<CarAdsCubit>();
      for (final x in images) {
        if (cubit.state.images.length < 10) {
          cubit.addImage(File(x.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الوصول للحد الأقصى (10 صور)')),
          );
          break;
        }
      }
    }
  }

  Future<void> _pickTechnicalReport(BuildContext context) async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      context.read<CarAdsCubit>().setTechnicalReport(File(x.path));
    }
  }

  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (picked != null) {
      final cubit = context.read<CarAdsCubit>();
      cubit.setLatLng(picked.latLng.latitude, picked.latLng.longitude);

      if (picked.addressAr != null && picked.addressAr!.isNotEmpty) {
        cubit.setAddressAr(picked.addressAr);
      }

      String locationText =
          'تم اختيار الموقع (خ.ط: ${picked.latLng.latitude.toStringAsFixed(4)}, د.ع: ${picked.latLng.longitude.toStringAsFixed(4)})';
      if (picked.addressAr != null && picked.addressAr!.isNotEmpty) {
        locationText = picked.addressAr!;
      }

      setState(() {
        _locationCtrl.text = locationText;
      });
    }
  }

  Widget _addMediaTileFullWidth(BuildContext context) {
    return DottedBorder(
      color: const Color(0xFFCDD6E1),
      strokeWidth: 1.2,
      dashPattern: const [6, 4],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.r),
      child: InkWell(
        onTap: () => _pickImages(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          height: 66.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_photo_alternate_outlined, size: 24, color: Color(0xFF0A45A6)),
                SizedBox(width: 8.w),
                Text('أضف صورة/فيديو (حتى 10)',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0A45A6), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _addMediaTileHorizontal(BuildContext context) {
    return InkWell(
      onTap: () => _pickImages(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 110.w,
        height: 82.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined, size: 24, color: Color(0xFF0A45A6)),
              SizedBox(height: 4.h),
              Text('إضافة', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF0A45A6)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageTile(File file, CarAdsCubit cubit, int index) {
    return Container(
      width: 110.w,
      height: 82.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => cubit.removeImageAt(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTileHorizontal(File file, CarAdsCubit cubit) {
    return Container(
      width: 110.w,
      height: 82.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf, size: 18, color: Color(0xFF0A45A6)),
                SizedBox(width: 6.w),
                Text('تقرير فني', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0A45A6))),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => cubit.setTechnicalReport(null),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dottedReportBox(BuildContext context) {
    return DottedBorder(
      color: const Color(0xFFCDD6E1),
      strokeWidth: 1.2,
      dashPattern: const [6, 4],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _pickTechnicalReport(context),
        child: SizedBox(
          width: double.infinity,
          height: 66.h,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: Color(0xFF0A45A6)),
                SizedBox(width: 8.w),
                Text(
                  'إرفاق ملف الفحص الفني',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0A45A6), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarAdsCubit>();
    return BlocConsumer<CarAdsCubit, CarAdsState>(
      listenWhen: (prev, curr) => prev.success != curr.success || prev.error != curr.error,
      listener: (context, state) {
        if (state.success) {
          final msg = state.isEditing ? 'تم تحديث الإعلان بنجاح ✅' : 'تم نشر الإعلان بنجاح ✅';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

          // اعمل pop عند النجاح لو مطلوب
          if (widget.popOnSuccess && Navigator.canPop(context)) {
            Navigator.maybePop(context);
          }
        } else if (state.error != null && !state.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final hasImages = state.images.isNotEmpty;
        final showReport = state.technicalReport != null;

        int imagesCount = state.images.length;
        int listCount = imagesCount + (showReport ? 1 : 0) + (imagesCount < 10 ? 1 : 0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(12),

                Text('الصور ومقاطع الفيديو', style: TextStyles.font14DarkGray400Weight),
                SizedBox(height: 8.h),

                if (!hasImages)
                  _addMediaTileFullWidth(context)
                else
                  SizedBox(
                    height: 90.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: listCount,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        if (index < imagesCount) {
                          final f = state.images[index];
                          return _imageTile(f, cubit, index);
                        } else if (showReport && index == imagesCount) {
                          return _reportTileHorizontal(state.technicalReport!, cubit);
                        } else {
                          return _addMediaTileHorizontal(context);
                        }
                      },
                    ),
                  ),
                verticalSpace(16.h),

                state.technicalReport == null
                    ? _dottedReportBox(context)
                    : _reportTileHorizontal(state.technicalReport!, cubit),
                verticalSpace(16.h),

                SecondaryTextFormField(
                  label: 'عنوان الاعلان',
                  hint: 'مثال: كامري 2024 جديد',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  controller: _titleCtrl,
                  onChanged: cubit.setTitle,
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'وصف العرض',
                  hint: 'أكتب وصف للمنتج...',
                  maxheight: 96.h,
                  minHeight: 96.h,
                  maxLines: 10,
                  controller: _descriptionCtrl,
                  onChanged: cubit.setDescription,
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'السعر (ريال سعودي)',
                  hint: '2000000',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  isNumber: true,
                  controller: _priceCtrl,
                  onChanged: (v) => cubit.setPrice(num.tryParse(v)),
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'موقع الخدمة',
                  hint: _locationCtrl.text,
                  maxheight: 56.h,
                  minHeight: 56.h,
                  controller: _locationCtrl,
                  onTap: _pickLocation,
                ),
                verticalSpace(12),

                DetailSelector(
                  title: 'نوع البيع',
                  widget: Row(
                    children: [
                      Expanded(
                        child: CustomizedChip(
                          title: 'سعر محدد',
                          isSelected: state.priceType == 'fixed',
                          onTap: () {
                            cubit.setPriceType(CarMappers.priceType('سعر محدد'));
                            cubit.setPrice(num.tryParse(_priceCtrl.text));
                          },
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'علي السوم',
                          isSelected: state.priceType == 'negotiable',
                          onTap: () => cubit.setPriceType(CarMappers.priceType('علي السوم')),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'مزاد',
                          isSelected: state.priceType == 'auction',
                          onTap: () => cubit.setPriceType(CarMappers.priceType('مزاد')),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'رقم الجوال',
                  hint: '9660322653815',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  isNumber: true,
                  controller: _phoneCtrl,
                  onChanged: cubit.setPhone,
                ),
                verticalSpace(12),

                DetailSelector(
                  title: 'التواصل',
                  widget: Row(
                    children: [
                      Expanded(
                        child: CustomizedChip(
                          title: 'محادثة',
                          isSelected: state.contactChat,
                          onTap: () => cubit.setContactChat(!state.contactChat),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'واتساب',
                          isSelected: state.contactWhatsapp,
                          onTap: () => cubit.setContactWhatsapp(!state.contactWhatsapp),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'جوال',
                          isSelected: state.contactCall,
                          onTap: () => cubit.setContactCall(!state.contactCall),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(12),

                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('استقبال عروض للتسوق'),
                        value: state.allowMarketing,
                        onChanged: cubit.setAllowMarketing,
                        activeColor: Colors.yellow,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('السماح بالتعليق على الاعلان'),
                        value: state.allowComments,
                        onChanged: cubit.setAllowComments,
                        activeColor: Colors.yellow,
                      ),
                    ),
                  ],
                ),
                verticalSpace(12),

                NextButtonBar(
                  title: state.submitting
                      ? (state.isEditing ? 'جاري التحديث...' : 'جاري النشر...')
                      : (state.isEditing ? 'تحديث الاعلان' : 'نشر الاعلان'),
                  onPressed: () {
                    if (state.submitting) return;

                    cubit
                      ..setPrice(num.tryParse(_priceCtrl.text))
                      ..setPhone(_phoneCtrl.text)
                      ..setTitle(_titleCtrl.text)
                      ..setDescription(_descriptionCtrl.text);

                    if (widget.onPressed != null) {
                      widget.onPressed!();
                    } else {
                      cubit.submit();
                    }
                  },
                ),
                verticalSpace(16),
              ],
            ),
          ),
        );
      },
    );
  }
}