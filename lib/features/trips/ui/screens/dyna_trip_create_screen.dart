import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import '../../data/model/dyna_trip_models.dart';
import '../logic/cubit/dyna_trip_create_cubit.dart';
import '../logic/cubit/dyna_trip_create_state.dart';
import '../widgets/city_selector_dialog.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';

class CreateDynaTripScreen extends StatefulWidget {
  final int providerId;
  final int? tripId; // إذا وُجد فهي تعديل

  const CreateDynaTripScreen({super.key, required this.providerId, this.tripId});

  @override
  State<CreateDynaTripScreen> createState() => _CreateDynaTripScreenState();
}

class _CreateDynaTripScreenState extends State<CreateDynaTripScreen> {
  final _formKey = GlobalKey<FormState>();
  // controllers
  final _fromCityCtrl = TextEditingController();
  final _toCityCtrl = TextEditingController();
  final _departCtrl = TextEditingController();
  final _arriveCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '5');
  final _routeStartCtrl = TextEditingController();
  final _routeEndCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  City? _fromCity;
  City? _toCity;
  DateTime? _departure;
  DateTime? _arrival;
  String? _selectedCargoType;
  String? _selectedVehicleSize;
  String _scheduleType = 'once';

  final _fmtUi = DateFormat('dd/MM/yyyy HH:mm');
  final List<String> _cargoTypes = const [
    'أثاث منزلي', 'أجهزة كهربائية', 'مواد بناء', 'أغراض شخصية', 'أخرى'
  ];
  final List<String> _vehicleSizes = const [
    'دينّا صغيرة', 'دينّا متوسطة', 'دينّا كبيرة'
  ];

  @override
  void dispose() {
    _fromCityCtrl.dispose();
    _toCityCtrl.dispose();
    _departCtrl.dispose();
    _arriveCtrl.dispose();
    _capacityCtrl.dispose();
    _routeStartCtrl.dispose();
    _routeEndCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCity({required bool isFrom}) async {
    final c = await showCitySelectorDialog(context);
    if (c == null) return;
    setState(() {
      if (isFrom) {
        _fromCity = c;
        _fromCityCtrl.text = c.nameAr;
      } else {
        _toCity = c;
        _toCityCtrl.text = c.nameAr;
      }
    });
  }

  Future<void> _pickDateTime({required bool isDeparture}) async {
    final now = DateTime.now();
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (d == null) return;
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (t == null) return;
    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() {
      if (isDeparture) {
        _departure = dt;
        _departCtrl.text = _fmtUi.format(dt);
      } else {
        _arrival = dt;
        _arriveCtrl.text = _fmtUi.format(dt);
      }
    });
  }

  void _onSubmit(BuildContext context) {
    // تحقق من الحقول
    if (_fromCity == null || _toCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر مدينتي الرحلة')));
      return;
    }

    if (_departure == null || _arrival == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر وقتي الانطلاق والوصول')));
      return;
    }

    final req = DynaTripCreateRequest(
      providerRequestId: widget.providerId,
      fromCityId: _fromCity!.id,
      toCityId: _toCity!.id,
      dynaCapacity: _capacityCtrl.text.trim(),
      departureDate: _departure!,
      arrivalDate: _arrival!,
      cargoType: _selectedCargoType ?? 'أخرى',
      vehicleSize: _selectedVehicleSize ?? 'دينّا صغيرة',
      routeStart: _routeStartCtrl.text.trim(),
      routeEnd: _routeEndCtrl.text.trim(),
      scheduleType: _scheduleType,
      extraDetails:
      _extraCtrl.text.trim().isEmpty ? null : _extraCtrl.text.trim(),
    );

    final cubit = context.read<DynaTripCreateCubit>();
    if (widget.tripId != null) {
      cubit.updateTrip(widget.tripId!, req.toJson());
    } else {
      cubit.submit(req);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tripId != null;
    final title = isEdit ? 'تعديل الرحلة' : 'إنشاء رحلة جديدة';

    return BlocProvider(
      create: (_) => getIt<DynaTripCreateCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(title, style: TextStyles.font20Black500Weight),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<DynaTripCreateCubit, DynaTripCreateState>(
          listener: (ctx, state) {
            if (state.success) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(isEdit
                      ? 'تم حفظ التعديلات بنجاح'
                      : 'تم إنشاء الرحلة بنجاح')));
              Navigator.pop(ctx, true);
            } else if (state.error != null) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SecondaryTextFormField(
                          controller: _fromCityCtrl,
                          label: 'مدينة الانطلاق',
                          hint: 'اختر مدينة الانطلاق',
                          onTap: () => _pickCity(isFrom: true),
                          minHeight: 56, maxheight: 56,
                        ),
                        verticalSpace(12),
                        SecondaryTextFormField(
                          controller: _toCityCtrl,
                          label: 'مدينة الوصول',
                          hint: 'اختر مدينة الوصول',
                          onTap: () => _pickCity(isFrom: false),
                          minHeight: 56, maxheight: 56,
                        ),
                        verticalSpace(12),
                        SecondaryTextFormField(
                          controller: _routeStartCtrl,
                          label: 'نقطة البداية',
                          hint: '...مثال: جدة - حي الصفا',
                          minHeight: 56, maxheight: 56,
                        ),
                        verticalSpace(12),
                        SecondaryTextFormField(
                          controller: _routeEndCtrl,
                          label: 'نقطة النهاية',
                          hint: '...مثال: مكة - حي الزاهر',
                          minHeight: 56, maxheight: 56,
                        ),
                        verticalSpace(12),
                        SecondaryTextFormField(
                          controller: _departCtrl,
                          label: 'وقت الانطلاق',
                          hint: 'حدد وقت الانطلاق',
                          onTap: () => _pickDateTime(isDeparture: true),
                          minHeight: 56, maxheight: 56,


                        ),
                        verticalSpace(12),
                        SecondaryTextFormField(
                          controller: _arriveCtrl,
                          label: 'وقت الوصول المتوقع',
                          hint: 'حدد وقت الوصول المتوقع',
                          minHeight: 56, maxheight: 56,
                          onTap: () => _pickDateTime(isDeparture: false),
                        ),
                        verticalSpace(16),
                        SecondaryTextFormField(
                          controller: _capacityCtrl,
                          label: 'سعة الدينا',
                          hint: 'مثال: 5',
                          minHeight: 56, maxheight: 56,
                        ),
                        verticalSpace(24),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<DynaTripCreateCubit, DynaTripCreateState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: state.submitting
                          ? (isEdit ? 'جاري الحفظ...' : 'جاري الإنشاء...')
                          : (isEdit ? 'حفظ التعديلات' : 'إنشاء الرحلة'),
                      isDisabled: state.submitting,
                      isLoading: state.submitting,
                      onPressed: () => _onSubmit(context),
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
}