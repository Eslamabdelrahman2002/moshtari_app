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

class CreateDynaTripScreen extends StatefulWidget {
  final int providerId; // from profile.provider.provider_id
  const CreateDynaTripScreen({super.key, required this.providerId});

  @override
  State<CreateDynaTripScreen> createState() => _CreateDynaTripScreenState();
}

class _CreateDynaTripScreenState extends State<CreateDynaTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fromCityCtrl = TextEditingController();
  final TextEditingController _toCityCtrl = TextEditingController();
  final TextEditingController _departCtrl = TextEditingController();
  final TextEditingController _arriveCtrl = TextEditingController();
  final TextEditingController _capacityCtrl = TextEditingController(text: '5');

  City? _fromCity;
  City? _toCity;
  DateTime? _departure;
  DateTime? _arrival;

  final _fmtUi = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    _fromCityCtrl.dispose();
    _toCityCtrl.dispose();
    _departCtrl.dispose();
    _arriveCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCity({required bool isFrom}) async {
    final c = await showCitySelectorDialog(context);
    if (c != null) {
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
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
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

  String? _validateCity(String? _) {
    if (_fromCity == null) return 'اختر موقع الانطلاق';
    if (_toCity == null) return 'اختر موقع الوصول';
    return null;
  }

  String? _validateDate(String? _) {
    if (_departure == null) return 'اختر وقت الانطلاق';
    if (_arrival == null) return 'اختر وقت الوصول';
    if (_arrival!.isBefore(_departure!)) return 'وقت الوصول لا يجب أن يسبق الانطلاق';
    return null;
  }

  String? _validateCapacity(String? v) {
    if (v == null || v.trim().isEmpty) return 'أدخل سعة الديّنا';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'سعة غير صالحة';
    return null;
  }

  void _onSubmit() {
    final cityErr = _validateCity(null);
    final dateErr = _validateDate(null);
    final capErr = _validateCapacity(_capacityCtrl.text);
    if (cityErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cityErr)));
      return;
    }
    if (dateErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dateErr)));
      return;
    }
    if (capErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(capErr)));
      return;
    }

    final req = DynaTripCreateRequest(
      providerId: widget.providerId,
      fromCityId: _fromCity!.id,
      toCityId: _toCity!.id,
      dynaCapacity: int.parse(_capacityCtrl.text.trim()),
      departureDate: _departure!,
      arrivalDate: _arrival!,
    );
    context.read<DynaTripCreateCubit>().submit(req);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DynaTripCreateCubit>(
      create: (_) => getIt<DynaTripCreateCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text('إنشاء رحلة جديدة', style: TextStyles.font20Black500Weight),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocListener<DynaTripCreateCubit, DynaTripCreateState>(
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الرحلة بنجاح')));
              Navigator.of(context).pop(true);
            } else if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // موقع الانطلاق
                            GestureDetector(
                              onTap: () => _pickCity(isFrom: true),
                              child: AbsorbPointer(
                                child: SecondaryTextFormField(
                                  controller: _fromCityCtrl,
                                  label: 'موقع الانطلاق',
                                  hint: 'موقع الانطلاق',
                                  minHeight: 56, maxheight: 56,
                                  validator: (_) => _fromCity == null ? 'اختر موقع الانطلاق' : null,
                                  suffexIcon: 'arrow-down',
                                ),
                              ),
                            ),
                            verticalSpace(12),

                            // موقع الوصول
                            GestureDetector(
                              onTap: () => _pickCity(isFrom: false),
                              child: AbsorbPointer(
                                child: SecondaryTextFormField(
                                  controller: _toCityCtrl,
                                  label: 'موقع الوصول',
                                  hint: 'موقع الوصول',
                                  minHeight: 56, maxheight: 56,
                                  validator: (_) => _toCity == null ? 'اختر موقع الوصول' : null,
                                  suffexIcon: 'arrow-down',
                                ),
                              ),
                            ),
                            verticalSpace(12),

                            // وقت الانطلاق
                            GestureDetector(
                              onTap: () => _pickDateTime(isDeparture: true),
                              child: AbsorbPointer(
                                child: SecondaryTextFormField(
                                  controller: _departCtrl,
                                  label: 'وقت الانطلاق',
                                  hint: 'وقت الانطلاق',
                                  minHeight: 56, maxheight: 56,
                                  suffexIcon: 'calendar',
                                ),
                              ),
                            ),
                            verticalSpace(12),

                            // وقت الوصول المتوقع
                            GestureDetector(
                              onTap: () => _pickDateTime(isDeparture: false),
                              child: AbsorbPointer(
                                child: SecondaryTextFormField(
                                  controller: _arriveCtrl,
                                  label: 'وقت الوصول المتوقع',
                                  hint: 'وقت الوصول المتوقع',
                                  minHeight: 56, maxheight: 56,
                                  suffexIcon: 'calendar',
                                ),
                              ),
                            ),
                            verticalSpace(12),

                            // سعة الديّنا
                            SecondaryTextFormField(
                              controller: _capacityCtrl,
                              label: 'سعة الديّنا',
                              hint: 'مثال: 5',
                              isNumber: true,
                              minHeight: 56, maxheight: 56,
                              validator: _validateCapacity,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  BlocBuilder<DynaTripCreateCubit, DynaTripCreateState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: state.submitting ? 'جاري الإنشاء...' : 'إنشاء رحلة',
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
      ),
    );
  }
}