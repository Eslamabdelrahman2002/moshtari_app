import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';

import 'package:mushtary/features/services/data/model/service_request_payload.dart';
import 'package:mushtary/features/services/logic/cubit/service_request_cubit.dart';
import 'package:mushtary/features/services/logic/cubit/service_request_state.dart';

import '../widgets/map_picker_screen.dart'; // PickedLocation

class ShrejScreen extends StatefulWidget {
  const ShrejScreen({super.key});

  @override
  State<ShrejScreen> createState() => _ShrejScreenState();
}

class _ShrejScreenState extends State<ShrejScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Dropdown sources
  final List<String> tankSizes = ['صغر', 'متوسط', 'كبير'];
  final List<String> waterTypes = ['مياه عذبة', 'مياه مفلترة', 'مياه صالحة للشرب', 'مياه صناعية'];
  final List<String> requiredServices = ['مضخة رفع الماء للخزان العلوي', 'رشاش سفلي في الصهريج'];

  // Selected values
  String? selectedTankSize;
  String? selectedWaterType;
  String? selectedReqService;
  Region? selectedRegion;
  City? selectedCity;

  // Map result
  LatLng? _pickedLatLng;

  // Schedule
  bool nowSelected = true;

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyles.font14DarkGray400Weight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: ColorsManager.grey200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: ColorsManager.grey200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: ColorsManager.primaryColor),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    filled: true,
    fillColor: ColorsManager.white,
  );

  Future<void> _pickLocationOnMap() async {
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (picked != null) {
      setState(() {
        _pickedLatLng = picked.latLng;
        _locationCtrl.text = picked.addressAr ?? 'تم اختيار الموقع';
      });
    }
  }

  Future<void> _pickCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خدمة الموقع غير مفعّلة')));
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم يتم منح إذن الموقع')));
        return;
      }
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _pickedLatLng = LatLng(p.latitude, p.longitude);
        _locationCtrl.text = 'تم اختيار الموقع';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر تحديد الموقع: $e')));
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocationCubit>()..loadRegions()),
        BlocProvider(create: (_) => getIt<ServiceRequestCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300)),
          title: Text('طلب صهريج ماء', style: TextStyles.font20Black500Weight),
          backgroundColor: ColorsManager.white,
          elevation: 4,
          shadowColor: ColorsManager.black.withOpacity(0.1),
          centerTitle: true,
          surfaceTintColor: ColorsManager.transparent,
        ),
        body: SafeArea(
          child: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
            listenWhen: (p, c) => c is ServiceRequestSuccess || c is ServiceRequestFailure,
            listener: (context, state) {
              final m = ScaffoldMessenger.of(context);
              m.hideCurrentSnackBar();
              if (state is ServiceRequestSuccess) {
                m.showSnackBar(SnackBar(content: Text(state.message)));
                Navigator.of(context).maybePop();
              } else if (state is ServiceRequestFailure) {
                m.showSnackBar(SnackBar(content: Text(state.error.replaceFirst('Exception: ', ''))));
              }
            },
            builder: (context, reqState) {
              final submitting = reqState is ServiceRequestLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                child: Form(
                  key: _formKey,
                  child: BlocBuilder<LocationCubit, LocationState>(
                    builder: (context, state) {
                      final cubit = context.read<LocationCubit>();

                      return Column(
                        children: [
                          SecondaryTextFormField(
                            label: 'وصف الخدمة *',
                            hint: 'أدخل وصف الخدمة المطلوبة',
                            maxheight: 110.w,
                            minHeight: 96.w,
                            controller: _descCtrl,
                            maxLines: 3,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
                          ),
                          verticalSpace(16),

                          DetailSelector(
                            title: 'حجم الصهريج *',
                            widget: DropdownButtonFormField<String>(
                              value: selectedTankSize,
                              items: tankSizes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyles.font16Black500Weight))).toList(),
                              onChanged: (v) => setState(() => selectedTankSize = v),
                              decoration: _dec('حدد حجم الصهريج'),
                              validator: (v) => v == null ? 'الحقل مطلوب' : null,
                            ),
                          ),
                          verticalSpace(16),

                          DetailSelector(
                            title: 'نوع المياه *',
                            widget: DropdownButtonFormField<String>(
                              value: selectedWaterType,
                              items: waterTypes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyles.font16Black500Weight))).toList(),
                              onChanged: (v) => setState(() => selectedWaterType = v),
                              decoration: _dec('حدد نوع المياه'),
                              validator: (v) => v == null ? 'الحقل مطلوب' : null,
                            ),
                          ),
                          verticalSpace(16),

                          DetailSelector(
                            title: 'الخدمات المطلوبة *',
                            widget: DropdownButtonFormField<String>(
                              value: selectedReqService,
                              items: requiredServices.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyles.font16Black500Weight))).toList(),
                              onChanged: (v) => setState(() => selectedReqService = v),
                              decoration: _dec('حدد الخدمات المطلوبة'),
                              validator: (v) => v == null ? 'الحقل مطلوب' : null,
                            ),
                          ),
                          verticalSpace(16),

                          DetailSelector(
                            title: 'المنطقة *',
                            widget: state.regionsLoading
                                ? const Center(child: CircularProgressIndicator.adaptive())
                                : DropdownButtonFormField<Region>(
                              value: selectedRegion,
                              items: state.regions.map((r) => DropdownMenuItem(value: r, child: Text(r.nameAr, style: TextStyles.font16Black500Weight))).toList(),
                              onChanged: (r) {
                                setState(() {
                                  selectedRegion = r;
                                  selectedCity = null;
                                });
                                if (r != null) cubit.loadCities(r.id);
                              },
                              decoration: _dec('حدد المنطقة'),
                              validator: (v) => v == null ? 'الحقل مطلوب' : null,
                            ),
                          ),
                          if (state.regionsError != null) ...[
                            verticalSpace(8),
                            Align(alignment: Alignment.centerRight, child: Text(state.regionsError!, style: TextStyles.font14Red500Weight)),
                          ],
                          verticalSpace(16),

                          DetailSelector(
                            title: 'المدينة *',
                            widget: state.citiesLoading
                                ? const Center(child: CircularProgressIndicator.adaptive())
                                : DropdownButtonFormField<City>(
                              value: selectedCity,
                              items: state.cities.map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr, style: TextStyles.font16Black500Weight))).toList(),
                              onChanged: (c) => setState(() => selectedCity = c),
                              decoration: _dec('حدد المدينة'),
                              validator: (v) => v == null ? 'الحقل مطلوب' : null,
                            ),
                          ),
                          if (state.citiesError != null) ...[
                            verticalSpace(8),
                            Align(alignment: Alignment.centerRight, child: Text(state.citiesError!, style: TextStyles.font14Red500Weight)),
                          ],
                          verticalSpace(16),

                          SecondaryTextFormField(
                            label: 'رقم الهاتف *',
                            hint: 'أدخل رقم الهاتف',
                            maxheight: 56.w,
                            minHeight: 56.w,
                            keyboardType: TextInputType.phone,
                            controller: _phoneCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
                          ),
                          verticalSpace(16),

                          SecondaryTextFormField(
                            label: 'موقع الخدمة',
                            hint: 'اختر الموقع على الخريطة أو ابحث',
                            maxheight: 56.w,
                            minHeight: 56.w,
                            controller: _locationCtrl,
                            onTap: _pickLocationOnMap,
                            suffexIcon: 'location-primary',
                          ),
                          verticalSpace(8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(onPressed: _pickCurrentLocation, child: const Text('موقعي الحالي')),
                              if (_pickedLatLng != null) Text('تم تحديد الموقع', style: TextStyles.font12Green400Weight),
                            ],
                          ),
                          verticalSpace(16),

                          DetailSelector(
                            title: 'حدد وقت الخدمة',
                            widget: Row(
                              children: [
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'حالاً',
                                    isSelected: nowSelected,
                                    onTap: () => setState(() => nowSelected = true),
                                  ),
                                ),
                                horizontalSpace(16),
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'لاحقاً',
                                    isSelected: !nowSelected,
                                    onTap: () => setState(() => nowSelected = false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          verticalSpace(16),

                          SecondaryTextFormField(
                            label: 'ملاحظات إضافية',
                            hint: 'ادخل تفاصيل إضافية للخدمة',
                            maxheight: 96.w,
                            minHeight: 96.w,
                            controller: _notesCtrl,
                            maxLines: 3,
                          ),
                          verticalSpace(16),

                          MyButton(
                            label: submitting ? 'جارٍ الإرسال...' : 'إرسال الطلب',
                            onPressed: submitting
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState?.validate() != true) return;

                              if (selectedRegion == null || selectedCity == null || _pickedLatLng == null) {
                                final m = ScaffoldMessenger.of(context);
                                m.hideCurrentSnackBar();
                                m.showSnackBar(const SnackBar(content: Text('الرجاء اختيار المنطقة والمدينة والموقع')));
                                return;
                              }
                              if (selectedTankSize == null || selectedWaterType == null || selectedReqService == null) {
                                final m = ScaffoldMessenger.of(context);
                                m.hideCurrentSnackBar();
                                m.showSnackBar(const SnackBar(content: Text('الرجاء استكمال حقول الصهريج')));
                                return;
                              }

                              final extras = <String, dynamic>{
                                'tank_size': selectedTankSize,
                                'water_type': selectedWaterType,
                                'required_service': selectedReqService,
                              };

                              final req = CreateServiceRequest(
                                serviceType: 'tanker', // عدّلها لو الباك يستخدم قيمة أخرى
                                description: _descCtrl.text.trim(),
                                phone: _phoneCtrl.text.trim(),
                                scheduleType: nowSelected ? 'now' : 'later',
                                scheduleTimeIso: null,
                                notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                                cityId: selectedCity!.id,
                                regionId: selectedRegion!.id,
                                latitude: _pickedLatLng!.latitude,
                                longitude: _pickedLatLng!.longitude,
                                extras: extras,
                              );

                              context.read<ServiceRequestCubit>().create(req);
                            },
                            height: 52.w,
                            backgroundColor: ColorsManager.primaryColor,
                            radius: 12.r,
                            labelStyle: TextStyles.font16White500Weight,
                          ),

                          if (submitting) ...[
                            verticalSpace(12),
                            const Center(child: CircularProgressIndicator.adaptive()),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}