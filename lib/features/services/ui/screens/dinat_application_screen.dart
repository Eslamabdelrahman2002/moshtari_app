import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/location/logic/cubit/location_state.dart';
import 'package:mushtary/features/services/data/model/service_request_payload.dart';
import 'package:mushtary/features/services/logic/cubit/service_request_cubit.dart';
import 'package:mushtary/features/services/logic/cubit/service_request_state.dart';

import '../widgets/map_picker_screen.dart';

class DinatApplicationScreen extends StatefulWidget {
  const DinatApplicationScreen({super.key});

  @override
  State<DinatApplicationScreen> createState() => _DinatApplicationScreenState();
}

class _DinatApplicationScreenState extends State<DinatApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Location fields (pickup/dropoff)
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  String? _pickupAddressAr;
  String? _dropoffAddressAr;

  // Dropdowns (Region/City)
  Region? selectedRegion;
  City? selectedCity;

  // Transport scope (داخل المدينة/بين المدن)
  bool inCity = true;

  // Dyna options (chips) - **تعديل قوائم الخيارات لتطابق الصورة**
  final List<String> cargoTypes = ['اثاث', 'مواشي', 'اعلاف', 'غير ذلك']; // تم التعديل
  final List<String> dynaSizes = ['كبيرة', 'متوسطة', 'صغيرة', 'أخرى']; // تم التعديل
  final List<String> extraDetails = ['عادية', 'مغطاة', 'تبريد', 'رافعة']; // تم التعديل

  String? selectedCargoType = 'اثاث';
  String? selectedDynaSize = 'كبيرة';
  String? selectedExtraDetail = 'عادية';

  // Schedule
  bool nowSelected = true;
  DateTime? _scheduledAt;

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

  @override
  void dispose() {
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap({required bool isPickup}) async {
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupLatLng = picked.latLng;
          _pickupAddressAr = picked.addressAr;
          _pickupCtrl.text = picked.addressAr ?? 'تم اختيار موقع التحميل';
        } else {
          _dropoffLatLng = picked.latLng;
          _dropoffAddressAr = picked.addressAr;
          _dropoffCtrl.text = picked.addressAr ?? 'تم اختيار موقع التنزيل';
        }
      });
    }
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now,
      locale: const Locale('ar'),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30))),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (pickedTime == null) return;
    final dt = DateTime(
      pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute,
    );
    setState(() => _scheduledAt = dt);
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
          leading: IconButton(onPressed: ()=>Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new,color: ColorsManager.darkGray300,)),
          title: Text('طلب دِينة', style: TextStyles.font20Black500Weight),
          backgroundColor: ColorsManager.white,
          elevation: 4,
          shadowColor: ColorsManager.black.withOpacity(0.1),
          centerTitle: true,
          surfaceTintColor: ColorsManager.transparent,
        ),
        body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
          listenWhen: (p, c) => c is ServiceRequestSuccess || c is ServiceRequestFailure,
          listener: (context, state) {
            final m = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
            if (state is ServiceRequestSuccess) {
              m.showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.of(context).maybePop();
            } else if (state is ServiceRequestFailure) {
              m.showSnackBar(SnackBar(content: Text(state.error.replaceFirst('Exception: ', ''))));
            }
          },
          builder: (context, reqState) {
            final submitting = reqState is ServiceRequestLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                child: Form(
                  key: _formKey,
                  child: BlocBuilder<LocationCubit, LocationState>(
                    builder: (context, state) {
                      final cubit = context.read<LocationCubit>();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // نوع النقل
                          DetailSelector(
                            title: 'نوع النقل',
                            widget: Row(
                              children: [
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'داخل المدينة',
                                    isSelected: inCity,
                                    onTap: () => setState(() => inCity = true),
                                  ),
                                ),
                                horizontalSpace(12),
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'بين المدن',
                                    isSelected: !inCity,

                                    onTap: () => setState(() => inCity = false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          verticalSpace(16),

                          // مواقع التحميل والتنزيل
                          DetailSelector(
                            title: 'موقع التحميل',
                            widget: SecondaryTextFormField(
                              label: 'موقع التحميل',
                              hint: 'اختر موقع التحميل من الخريطة',
                              maxheight: 56.w,
                              minHeight: 56.w,
                              controller: _pickupCtrl,
                              // readOnly: true,
                              onTap: () => _pickOnMap(isPickup: true),
                              suffexIcon: 'location-primary',
                              validator: (_) => _pickupLatLng == null ? 'الرجاء اختيار موقع التحميل' : null,
                            ),
                          ),
                          verticalSpace(12),
                          DetailSelector(
                            title: 'موقع التنزيل',
                            widget: SecondaryTextFormField(
                              label: 'موقع التنزيل',
                              hint: 'اختر موقع التنزيل من الخريطة',
                              maxheight: 56.w,
                              minHeight: 56.w,
                              controller: _dropoffCtrl,
                              // readOnly: true,
                              onTap: () => _pickOnMap(isPickup: false),
                              suffexIcon: 'location-primary',
                              validator: (_) => _dropoffLatLng == null ? 'الرجاء اختيار موقع التنزيل' : null,
                            ),
                          ),
                          verticalSpace(16),

                          // وصف
                          SecondaryTextFormField(
                            label: 'وصف الخدمة *',
                            hint: 'أدخل وصف الخدمة المطلوبة',
                            maxheight: 96.w,
                            minHeight: 96.w,
                            controller: _descCtrl,
                            maxLines: 3,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
                          ),
                          verticalSpace(16),

                          // نوع الحمولة (Chips)
                          DetailSelector(
                            title: 'نوع الحمولة',
                            widget: LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 8.0;

                                // حدّد أقل عرض مناسب للعنصر الواحد (عدّله حسب تصميمك)
                                const minItemWidth = 120.0;

                                // احسب عدد الأعمدة تلقائياً حسب عرض المساحة
                                int crossAxisCount = (constraints.maxWidth / (minItemWidth + spacing)).floor();
                                crossAxisCount = crossAxisCount.clamp(2, 4); // من 2 إلى 4 أعمدة مثلاً

                                // احسب العرض الفعلي لكل عنصر بحيث يملأ الصف
                                final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: cargoTypes.map((e) {
                                    final selected = selectedCargoType == e;
                                    return CustomizedChip(
                                      title: e,
                                      isSelected: selected,
                                      onTap: () => setState(() => selectedCargoType = e),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                          verticalSpace(16),

                          // حجم الدينة (Chips)
                          DetailSelector(
                            title: 'حجم الدِينة',
                            widget: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: dynaSizes.map((e) {
                                final selected = selectedDynaSize == e;
                                return CustomizedChip(
                                  title: e,
                                  isSelected: selected,
                                  onTap: () => setState(() => selectedDynaSize = e),

                                );
                              }).toList(),
                            ),
                          ),
                          verticalSpace(16),

                          // تفاصيل إضافية (Chips)
                          DetailSelector(
                            title: 'تفاصيل إضافية',
                            widget: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: extraDetails.map((e) {
                                final selected = selectedExtraDetail == e;
                                return CustomizedChip(
                                  title: e,
                                  isSelected: selected,
                                  onTap: () => setState(() => selectedExtraDetail = e),

                                );
                              }).toList(),
                            ),
                          ),
                          verticalSpace(16),

                          // المنطقة والمدينة
                          DetailSelector(
                            title: 'المنطقة',
                            widget: state.regionsLoading
                                ? const Center(child: CircularProgressIndicator.adaptive())
                                : DropdownButtonFormField<Region>(
                              value: selectedRegion,
                              items: state.regions
                                  .map((r) => DropdownMenuItem(value: r, child: Text(r.nameAr, style: TextStyles.font16Black500Weight)))
                                  .toList(),
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
                            title: 'المدينة',
                            widget: state.citiesLoading
                                ? const Center(child: CircularProgressIndicator.adaptive())
                                : DropdownButtonFormField<City>(
                              value: selectedCity,
                              items: state.cities
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr, style: TextStyles.font16Black500Weight)))
                                  .toList(),
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

                          // هاتف
                          SecondaryTextFormField(
                            label: 'رقم الهاتف',
                            hint: 'أدخل رقم الهاتف',
                            maxheight: 56.w,
                            minHeight: 56.w,
                            keyboardType: TextInputType.phone,
                            controller: _phoneCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
                          ),
                          verticalSpace(16),

                          // وقت الخدمة
                          DetailSelector(
                            title: 'تحديد وقت الخدمة',
                            widget: Row(
                              children: [
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'حالاً',
                                    isSelected: nowSelected,
                                    onTap: () => setState(() => nowSelected = true),
                                  ),
                                ),
                                horizontalSpace(12),
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'تحديد وقت لاحق', // **تعديل النص**
                                    isSelected: !nowSelected,

                                    onTap: () => setState(() => nowSelected = false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!nowSelected) ...[
                            verticalSpace(8),
                            OutlinedButton(
                              onPressed: _pickSchedule,
                              child: Text(_scheduledAt == null ? 'تحديد وقت الدق' : _scheduledAt!.toLocal().toString().substring(0, 16),style: TextStyles.font12Primary400400Weight,),
                            ),
                          ],
                          verticalSpace(16),

                          // ملاحظات
                          SecondaryTextFormField(
                            label: 'إضافات',
                            hint: 'اكتب إضافاتك',
                            maxheight: 96.w,
                            minHeight: 96.w,
                            controller: _notesCtrl,
                            maxLines: 3,
                          ),
                          verticalSpace(16),

                          // إرسال
                          MyButton(
                            label: submitting ? 'جارٍ الإرسال...' : 'إرسال الطلب',
                            onPressed: submitting
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState?.validate() != true) return;

                              if (selectedRegion == null || selectedCity == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('الرجاء اختيار المنطقة والمدينة')),
                                );
                                return;
                              }
                              if (_pickupLatLng == null || _dropoffLatLng == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('الرجاء اختيار موقع التحميل والتنزيل')),
                                );
                                return;
                              }
                              if (!nowSelected && _scheduledAt == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('حدد وقت الخدمة أو اختر "حالاً"')),
                                );
                                return;
                              }

                              final extras = <String, dynamic>{
                                'cargo_type': selectedCargoType,
                                'vehicle_size': selectedDynaSize, // حجم الدِينة
                                'extra_details': selectedExtraDetail,
                                'transport_scope': inCity ? 'in_city' : 'intercity',
                              };

                              final req = CreateServiceRequest(
                                serviceType: 'dyna',
                                description: _descCtrl.text.trim(),
                                phone: _phoneCtrl.text.trim(),
                                scheduleType: nowSelected ? 'now' : 'scheduled',
                                scheduleTimeIso: nowSelected ? null : _scheduledAt!.toIso8601String(),
                                notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                                cityId: selectedCity!.id,
                                regionId: selectedRegion!.id,
                                // مبدئياً نجعل إحداثيات الطلب = إحداثيات التحميل لملائمة الـ backend
                                latitude: _pickupLatLng!.latitude,
                                longitude: _pickupLatLng!.longitude,

                                pickupLocation: _pickupAddressAr ?? _pickupCtrl.text,
                                pickupLatitude: _pickupLatLng!.latitude,
                                pickupLongitude: _pickupLatLng!.longitude,

                                dropoffLocation: _dropoffAddressAr ?? _dropoffCtrl.text,
                                dropoffLatitude: _dropoffLatLng!.latitude,
                                dropoffLongitude: _dropoffLatLng!.longitude,

                                extras: extras,
                              );

                              context.read<ServiceRequestCubit>().create(req);
                            },
                            height: 52.w,
                            backgroundColor: ColorsManager.primaryColor,
                            radius: 12.r,
                            labelStyle: TextStyles.font16White500Weight,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}