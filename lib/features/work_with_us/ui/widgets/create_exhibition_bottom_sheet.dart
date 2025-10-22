import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

import 'package:mushtary/features/work_with_us/ui/logic/cubit/exhibition_create_cubit.dart';
import 'package:mushtary/features/work_with_us/ui/logic/cubit/exhibition_create_state.dart';

Future<bool?> showCreateExhibitionDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<LocationCubit>(
            create: (_) {
              final c = getIt<LocationCubit>();
              c.loadRegions();
              return c;
            },
          ),
          BlocProvider<ExhibitionCreateCubit>(
            create: (_) => getIt<ExhibitionCreateCubit>(),
          ),
        ],
        child: const _CreateExhibitionForm(),
      );
    },
  );
}

class _CreateExhibitionForm extends StatefulWidget {
  const _CreateExhibitionForm();

  @override
  State<_CreateExhibitionForm> createState() => _CreateExhibitionFormState();
}

class _CreateExhibitionFormState extends State<_CreateExhibitionForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _promoterIdCtrl = TextEditingController(); // اختياري

  String? _activityType; // 'car_ad' | 'real_estate_ad' | 'car_part_ad'
  Region? _selectedRegion;
  City? _selectedCity;
  File? _imageFile;

  final _activities = const [
    {'value': 'car_ad', 'label': 'إعلانات السيارات'},
    {'value': 'real_estate_ad', 'label': 'إعلانات العقارات'},
    {'value': 'car_part_ad', 'label': 'قطع الغيار'},
  ];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _promoterIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return BlocListener<ExhibitionCreateCubit, ExhibitionCreateState>(
      listener: (context, state) {
        if (state.success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100)),
                ),
                Text('إنشاء حساب معرض', style: TextStyles.font20Black500Weight, textAlign: TextAlign.center),
                SizedBox(height: 6.h),
                Text('يرجى ملء التفاصيل التالية', style: TextStyles.font12DarkGray400Weight, textAlign: TextAlign.center),
                verticalSpace(16),

                SecondaryTextFormField(
                  controller: _nameCtrl,
                  label: 'الاسم',
                  hint: 'اسم الحساب',
                  minHeight: 56,
                  maxheight: 56,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل اسم الحساب' : null,
                ),
                verticalSpace(12),

                DropdownButtonFormField<String>(
                  value: _activityType,
                  isExpanded: true,
                  items: _activities
                      .map((e) => DropdownMenuItem(value: e['value']!, child: Text(e['label']!)))
                      .toList(),
                  onChanged: (v) => setState(() => _activityType = v),
                  decoration: InputDecoration(
                    labelText: 'نشاط الحساب',
                    hintText: 'نشاط الحساب',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  ),
                  validator: (v) => v == null ? 'اختر نشاط الحساب' : null,
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  controller: _phoneCtrl,
                  label: 'رقم الجوال',
                  hint: '+966 5XXXXXXXX',
                  isNumber: true,
                  minHeight: 56,
                  maxheight: 56,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل رقم الجوال' : null,
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني',
                  hint: 'name@example.com',
                  minHeight: 56,
                  maxheight: 56,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل البريد الإلكتروني' : null,
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  controller: _addressCtrl,
                  label: 'العنوان',
                  hint: 'مثال: الرياض - طريق الملك فهد',
                  minHeight: 56,
                  maxheight: 56,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل العنوان' : null,
                ),
                verticalSpace(12),

                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        DropdownButtonFormField<Region>(
                          value: _selectedRegion,
                          isExpanded: true,
                          items: state.regions
                              .map((r) => DropdownMenuItem(value: r, child: Text(r.nameAr)))
                              .toList(),
                          onChanged: state.regionsLoading
                              ? null
                              : (r) {
                            setState(() {
                              _selectedRegion = r;
                              _selectedCity = null;
                            });
                            if (r != null) context.read<LocationCubit>().loadCities(r.id);
                          },
                          decoration: InputDecoration(
                            labelText: 'اختر منطقتك',
                            hintText: state.regionsLoading ? 'جاري التحميل...' : 'اختر منطقتك',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                          ),
                          validator: (_) => _selectedRegion == null ? 'اختر المنطقة' : null,
                        ),
                        SizedBox(height: 12.h),
                        DropdownButtonFormField<City>(
                          value: _selectedCity,
                          isExpanded: true,
                          items: state.cities
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr)))
                              .toList(),
                          onChanged: (_selectedRegion == null || state.citiesLoading)
                              ? null
                              : (c) => setState(() => _selectedCity = c),
                          decoration: InputDecoration(
                            labelText: 'اختر مدينتك',
                            hintText: state.citiesLoading
                                ? 'جاري التحميل...'
                                : (_selectedRegion == null ? 'اختر المنطقة أولاً' : 'اختر مدينتك'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                          ),
                          validator: (_) => _selectedCity == null ? 'اختر المدينة' : null,
                        ),
                      ],
                    );
                  },
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  controller: _promoterIdCtrl,
                  label: 'معرّف المروج (اختياري)',
                  hint: 'مثال: 6',
                  isNumber: true,
                  minHeight: 56,
                  maxheight: 56,
                ),
                verticalSpace(12),

                GestureDetector(
                  onTap: _pickImage,
                  child: DottedBorder(
                    color: ColorsManager.primaryColor.withOpacity(0.5),
                    strokeWidth: 1,
                    dashPattern: const [6, 6],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: Container(
                      height: 110.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ColorsManager.primary50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _imageFile == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MySvg(image: 'gallery-add'),
                          verticalSpace(8),
                          Text('رفع صورة للحساب', style: TextStyles.font14PrimaryColor400Weight),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                verticalSpace(16),

                BlocBuilder<ExhibitionCreateCubit, ExhibitionCreateState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: state.submitting ? 'جاري الإنشاء...' : 'إنشاء حساب',
                      isDisabled: state.submitting,
                      isLoading: state.submitting,
                      onPressed: _onSubmit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قم برفع صورة للحساب')));
      return;
    }
    if (_selectedRegion == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر المنطقة والمدينة')));
      return;
    }
    if (_activityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر نشاط الحساب')));
      return;
    }

    final promoterId = int.tryParse(_promoterIdCtrl.text.trim());

    context.read<ExhibitionCreateCubit>().submit(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      activityType: _activityType!,
      phoneNumber: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      cityId: _selectedCity!.id,
      regionId: _selectedRegion!.id,
      promoterId: promoterId,
      image: _imageFile!,
    );
  }
}