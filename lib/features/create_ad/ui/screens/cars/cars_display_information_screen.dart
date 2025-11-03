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
import '../../../../services/ui/widgets/map_picker_screen.dart'; // لـ PickedLocation
import '../../../data/car/utils/car_mappers.dart';
import 'logic/cubit/car_ads_cubit.dart';
import 'logic/cubit/car_ads_state.dart';

// (CarAdRequest Class remains the same)
class CarAdRequest {
  final String title;
  final String description;
  final num price;
  final String priceType;

  final int categoryId;
  final int? cityId;
  final int? regionId;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool contactChat;
  final bool contactWhatsapp;
  final bool contactCall;

  final String condition;
  final String saleType;
  final String warranty;
  final num mileage;
  final String transmission;
  final int cylinders;
  final String color;
  final String fuelType;
  final String driveType;
  final int horsepower;
  final String doors;
  final String vehicleType;
  final int brandId;
  final int modelId;
  final int year;
  final bool allowComments;
  final bool allowMarketing;

  final List<File> images;
  final File? technicalReport;

  CarAdRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.priceType,
    required this.categoryId,
    this.cityId,
    this.regionId,
    this.latitude,
    this.longitude,
    this.phone,
    required this.contactChat,
    required this.contactWhatsapp,
    required this.contactCall,
    required this.condition,
    required this.saleType,
    required this.warranty,
    required this.mileage,
    required this.transmission,
    required this.cylinders,
    required this.color,
    required this.fuelType,
    required this.driveType,
    required this.horsepower,
    required this.doors,
    required this.vehicleType,
    required this.brandId,
    required this.modelId,
    required this.year,
    required this.allowComments,
    required this.allowMarketing,
    required this.images,
    this.technicalReport,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'price_type': priceType,
      'category_id': 1,
      'city_id': cityId,
      'region_id': regionId,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'contact_chat': contactChat,
      'contact_whatsapp': contactWhatsapp,
      'contact_call': contactCall,
      'condition': condition,
      'sale_type': saleType,
      'warranty': warranty,
      'mileage': mileage,
      'transmission': transmission,
      'cylinders': cylinders,
      'color': color,
      'fuel_type': fuelType,
      'drive_type': driveType,
      'horsepower': horsepower,
      'doors': doors,
      'vehicle_type': vehicleType,
      'brand_id': brandId,
      'model_id': modelId,
      'year': year,
      'allow_comments': allowComments,
      'allow_marketing': allowMarketing,
    };
  }
}

class CarsDisplayInformationScreen extends StatefulWidget {
  final VoidCallback? onPressed;
  const CarsDisplayInformationScreen({super.key, this.onPressed});

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
    final state = context.read<CarAdsCubit>().state as dynamic;

    // التهيئة من الـ Cubit
    _titleCtrl = TextEditingController(text: state.title ?? '');
    _descriptionCtrl = TextEditingController(text: state.description ?? '');
    _priceCtrl = TextEditingController(text: state.price?.toString() ?? '');
    _phoneCtrl = TextEditingController(text: state.phone ?? '');

    // تهيئة متحكم الموقع
    String locationText = 'اختر الموقع على الخريطة أو ابحث';
    if (state.addressAr != null && state.addressAr!.isNotEmpty) {
      locationText = state.addressAr!;
    } else if (state.latitude != null && state.longitude != null) {
      locationText = 'تم اختيار الموقع (خ.ط: ${state.latitude!.toStringAsFixed(4)}, د.ع: ${state.longitude!.toStringAsFixed(4)})';
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

  // ✅ اختيار صور متعددة (حد أقصى 10 صور)
  Future<void> _pickImages(BuildContext context) async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
      limit: 10,
    );
    if (images.isNotEmpty) {
      final cubit = context.read<CarAdsCubit>() as dynamic;
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

  // اختيار تقرير فني (صورة واحدة)
  Future<void> _pickTechnicalReport(BuildContext context) async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      context.read<CarAdsCubit>().setTechnicalReport(File(x.path));
    }
  }

  // ✅ عرض اسم المكان (addressAr) أو الإحداثيات كبديل
  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (picked != null) {
      final cubit = context.read<CarAdsCubit>() as dynamic;
      cubit.setLatLng(picked.latLng.latitude, picked.latLng.longitude);

      // تحديث المتحكم لعرض اسم المكان أو الإحداثيات
      String locationText = 'تم اختيار الموقع (خ.ط: ${picked.latLng.latitude.toStringAsFixed(4)}, د.ع: ${picked.latLng.longitude.toStringAsFixed(4)})';
      if (picked.addressAr != null && picked.addressAr!.isNotEmpty) {
        locationText = picked.addressAr!;
      }

      setState(() {
        _locationCtrl.text = locationText;
      });
    }
  }

  // ✅ عنصر إضافة صور/فيديو (بعرض الشاشة إذا لا توجد صور)
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
                Text('أضف صورة/فيديو (حتى 10)', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0A45A6), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ عنصر إضافة صور/فيديو (في الشريط الأفقي)
  Widget _addMediaTileHorizontal(BuildContext context) {
    return InkWell(
      onTap: () => _pickImages(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 110.w, // عرض ثابت في الشريط
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
              Text('إضافة',
                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF0A45A6)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ عنصر عرض صورة/فيديو
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
              onTap: () => (cubit as dynamic).removeImageAt(index),
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

  // عنصر عرض التقرير الفني في الشريط الأفقي
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

  // مربع مرفق الفحص الفني (بعرض الشاشة)
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
    final cubit = context.read<CarAdsCubit>() as dynamic;
    return BlocConsumer<CarAdsCubit, CarAdsState>(
      listener: (context, state) {
        if (state.error != null && !state.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final dynamicState = state as dynamic;
        final hasImages = state.images.isNotEmpty;
        final showReport = state.technicalReport != null;

        // حساب عدد العناصر في الشريط الأفقي
        int imagesCount = state.images.length;
        // عدد العناصر في الـ ListView: صور + (التقرير إذا موجود) + (زر الإضافة إذا لم نصل لـ 10)
        int listCount = imagesCount + (showReport ? 1 : 0) + (imagesCount < 10 ? 1 : 0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(12),

                // قسم الوسائط (صور متعددة)
                Text('الصور ومقاطع الفيديو', style: TextStyles.font14DarkGray400Weight),
                SizedBox(height: 8.h),

                // ✅ عرض شريط أفقي عند وجود الصور، أو مربع إضافة بعرض الشاشة عند عدم وجود صور
                if (!hasImages)
                  _addMediaTileFullWidth(context) // مربع كامل إذا لا توجد صور
                else
                  SizedBox(
                    height: 90.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: listCount,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        if (index < imagesCount) {
                          // 1. عرض الصور المضافة
                          final f = state.images[index];
                          return _imageTile(f, cubit, index);
                        } else if (showReport && index == imagesCount) {
                          // 2. عرض التقرير الفني (بعد آخر صورة)
                          return _reportTileHorizontal(state.technicalReport!, cubit);
                        } else {
                          // 3. عرض أيقونة الإضافة (في نهاية الشريط)
                          return _addMediaTileHorizontal(context);
                        }
                      },
                    ),
                  ),
                verticalSpace(16.h),

                // مربع مرفق الفحص الفني (بعرض الشاشة)
                state.technicalReport == null
                    ? _dottedReportBox(context)
                    : _reportTileHorizontal(state.technicalReport!, cubit), // عرض التقرير بعرض الشاشة إذا كان وحيداً
                verticalSpace(16.h),

                // عنوان الإعلان
                SecondaryTextFormField(
                  label: 'عنوان الاعلان',
                  hint: 'مثال: كامري 2024 جديد',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  controller: _titleCtrl,
                  onChanged: cubit.setTitle,
                ),
                verticalSpace(12),

                // وصف العرض
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

                // السعر
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

                // الموقع (يعرض اسم المكان أو الإحداثيات)
                SecondaryTextFormField(
                  label: 'موقع الخدمة',
                  hint: _locationCtrl.text,
                  maxheight: 56.h,
                  minHeight: 56.h,
                  controller: _locationCtrl,
                  onTap: _pickLocation, // فتح خريطة
                ),
                verticalSpace(12),

                // نوع البيع
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

                // رقم الجوال
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

                // التواصل
                DetailSelector(
                  title: 'التواصل',
                  widget: Row(
                    children: [
                      Expanded(
                        child: CustomizedChip(
                          title: 'محادثة',
                          isSelected: dynamicState.contactChat,
                          onTap: () => cubit.setContactChat(!dynamicState.contactChat),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'واتساب',
                          isSelected: dynamicState.contactWhatsapp,
                          onTap: () => cubit.setContactWhatsapp(!dynamicState.contactWhatsapp),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'جوال',
                          isSelected: dynamicState.contactCall,
                          onTap: () => cubit.setContactCall(!dynamicState.contactCall),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(12),

                // سويتشات
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

                // زر النشر
                NextButtonBar(
                  title: state.submitting ? 'جاري النشر...' : 'نشر الاعلان',
                  onPressed: () {
                    if (state.submitting) return;
                    // ... (منطق إرسال البيانات)
                    cubit
                      ..setPrice(num.tryParse(_priceCtrl.text))
                      ..setPhone(_phoneCtrl.text)
                      ..setTitle(_titleCtrl.text)
                      ..setDescription(_descriptionCtrl.text);

                    final request = CarAdRequest(
                      // ... (باقي الحقول)
                      title: _titleCtrl.text, description: _descriptionCtrl.text, price: num.tryParse(_priceCtrl.text) ?? 0, priceType: state.priceType ?? 'fixed', categoryId: 1, contactChat: dynamicState.contactChat, contactWhatsapp: dynamicState.contactWhatsapp, contactCall: dynamicState.contactCall, condition: dynamicState.condition ?? '', saleType: dynamicState.saleType ?? '', warranty: dynamicState.warranty ?? '', mileage: dynamicState.mileage ?? 0, transmission: dynamicState.transmission ?? '', cylinders: dynamicState.cylinders ?? 0, color: dynamicState.color ?? '', fuelType: dynamicState.fuelType ?? '', driveType: dynamicState.driveType ?? '', horsepower: dynamicState.horsepower ?? 0, doors: dynamicState.doors ?? '', vehicleType: dynamicState.vehicleType ?? '', brandId: dynamicState.brandId ?? 0, modelId: dynamicState.modelId ?? 0, year: dynamicState.year ?? 0, allowComments: state.allowComments, allowMarketing: state.allowMarketing, images: state.images, technicalReport: state.technicalReport,
                    );
                    final payload = request.toMap();
                    if (widget.onPressed != null) {
                      widget.onPressed!();
                    } else {
                      cubit.submit(payload: payload);
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