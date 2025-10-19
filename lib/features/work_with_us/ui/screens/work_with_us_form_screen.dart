import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Theme/Widgets
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/location/data/model/location_models.dart';
import '../logic/cubit/work_with_us_cubit.dart';
import '../logic/cubit/work_with_us_state.dart';

// شاشة البروفايل بعد التقديم
import 'work_with_us_profile_screen.dart';

class WorkWithUsFormScreen extends StatefulWidget {
  const WorkWithUsFormScreen({super.key});

  @override
  State<WorkWithUsFormScreen> createState() => _WorkWithUsFormScreenState();
}

class _WorkWithUsFormScreenState extends State<WorkWithUsFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _dateUiController = TextEditingController();
  String? _birthDateIso; // yyyy-MM-dd

  File? _imageFile;

  // employment toggle: index 0 -> working, index 1 -> available
  List<bool> _isSelected = [true, false];

  Region? _selectedRegion;
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      _dateUiController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      _birthDateIso = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateUiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>(
          create: (_) {
            final c = getIt<LocationCubit>();
            c.loadRegions(); // أول ما تفتح الشاشة حمل المناطق
            return c;
          },
        ),
        BlocProvider<WorkWithUsCubit>(
          create: (_) => getIt<WorkWithUsCubit>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorsManager.white,
          centerTitle: true,
          title: Text('العمل معنا', style: TextStyles.font20Black500Weight),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocListener<WorkWithUsCubit, WorkWithUsState>(
          listener: (context, state) {
            if (state.success) {
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WorkWithUsProfileScreen()),
              );
            } else if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SecondaryTextFormField(
                    controller: _nameController,
                    label: 'الاسم كامل',
                    hint: 'الاسم كامل',
                    maxheight: 56,
                    minHeight: 56,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء إدخال الاسم' : null,
                  ),
                  verticalSpace(16),

                  SecondaryTextFormField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    hint: '+966',
                    isNumber: true,
                    maxheight: 56,
                    minHeight: 56,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء إدخال الهاتف' : null,
                  ),
                  verticalSpace(16),
                  SecondaryTextFormField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'name@example.com',
                    maxheight: 56,
                    minHeight: 56,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء إدخال البريد' : null,
                  ),
                  verticalSpace(16),

                  SecondaryTextFormField(
                    controller: _nationalIdController,
                    label: 'رقم الرخصه / الاقامة',
                    hint: 'رقم الرخصه / الاقامة',
                    maxheight: 56,
                    minHeight: 56,
                    isNumber: true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء إدخال الرقم' : null,
                  ),
                  verticalSpace(16),

                  // تاريخ الميلاد (قابل للنقر)
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12.r),
                    child: AbsorbPointer(
                      child: SecondaryTextFormField(
                        controller: _dateUiController,
                        label: 'تاريخ الميلاد',
                        hint: '12/05/2024',
                        maxheight: 56,
                        minHeight: 56,
                        isEnabled: true,
                        suffexIcon: 'calendar',
                        validator: (_) => _birthDateIso == null ? 'برجاء اختيار التاريخ' : null,
                      ),
                    ),
                  ),
                  verticalSpace(16),

                  // المنطقة ثم المدينة
                  BlocBuilder<LocationCubit, LocationState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          _RegionDropdown(
                            regions: state.regions,
                            loading: state.regionsLoading,
                            value: _selectedRegion,
                            onChanged: (region) {
                              setState(() {
                                _selectedRegion = region;
                                _selectedCity = null;
                              });
                              if (region != null) {
                                context.read<LocationCubit>().loadCities(region.id);
                              }
                            },
                          ),
                          SizedBox(height: 16.h),
                          _CityDropdown(
                            cities: state.cities,
                            loading: state.citiesLoading,
                            enabled: _selectedRegion != null && !state.citiesLoading,
                            value: _selectedCity,
                            onChanged: (city) {
                              setState(() => _selectedCity = city);
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  verticalSpace(16),
                  ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == index;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    selectedColor: Colors.white,
                    color: ColorsManager.darkGray,
                    fillColor: ColorsManager.primaryColor,
                    borderColor: ColorsManager.dark200,
                    selectedBorderColor: ColorsManager.primaryColor,
                    children: [
                      _buildToggleChild('يعمل'),
                      _buildToggleChild('متفرغ'),
                    ],
                  ),
                  verticalSpace(24),

                  _buildImagePicker(),
                  verticalSpace(40),

                  BlocBuilder<WorkWithUsCubit, WorkWithUsState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: state.submitting ? 'جاري الإرسال...' : 'تقديم الطلب',
                        onPressed: () => _onSubmit(context),
                        isDisabled: state.submitting,
                        isLoading: state.submitting,
                      );
                    },
                  ),
                  verticalSpace(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _employmentStatus => _isSelected[0] ? 'working' : 'available';

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر منطقتك')));
      return;
    }
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر مدينتك')));
      return;
    }
    if (_birthDateIso == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر تاريخ الميلاد')));
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قم برفع صورة الهوية/الإقامة')));
      return;
    }

    context.read<WorkWithUsCubit>().submit(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      regionId: _selectedRegion!.id,
      cityId: _selectedCity!.id,
      employmentStatus: _employmentStatus,
      idDocument: _imageFile!,
      nationalId: _nationalIdController.text.trim(),
      birthDateIso: _birthDateIso!,
    );
  }

  Widget _buildToggleChild(String text) {
    return Container(
      width: (MediaQuery.of(context).size.width - 36.w) / 2,
      alignment: Alignment.center,
      child: Text(text),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        color: ColorsManager.primaryColor.withOpacity(0.5),
        strokeWidth: 1,
        dashPattern: const [6, 6],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.r),
        child: Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorsManager.primary50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: _imageFile == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MySvg(image: 'gallery-add'),
              verticalSpace(8),
              Text(
                'رفع صورة من الهوية / الاقامة',
                style: TextStyles.font14PrimaryColor400Weight,
              ),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _RegionDropdown extends StatelessWidget {
  final List<Region> regions;
  final bool loading;
  final Region? value;
  final ValueChanged<Region?> onChanged;

  const _RegionDropdown({
    required this.regions,
    required this.loading,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Region>(
      value: value,
      isExpanded: true,
      items: regions
          .map((r) => DropdownMenuItem(value: r, child: Text(r.nameAr)))
          .toList(),
      onChanged: loading ? null : onChanged,
      decoration: InputDecoration(
        labelText: 'اختر منطقتك',
        hintText: loading ? 'جاري التحميل...' : 'اختر منطقتك',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final List<City> cities;
  final bool loading;
  final bool enabled;
  final City? value;
  final ValueChanged<City?> onChanged;

  const _CityDropdown({
    required this.cities,
    required this.loading,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<City>(
      value: value,
      isExpanded: true,
      items: cities
          .map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr)))
          .toList(),
      onChanged: (!enabled || loading) ? null : onChanged,
      decoration: InputDecoration(
        labelText: 'اختر مدينتك',
        hintText: loading
            ? 'جاري التحميل...'
            : (enabled ? 'اختر مدينتك' : 'اختر المنطقة أولاً'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      ),
    );
  }
}