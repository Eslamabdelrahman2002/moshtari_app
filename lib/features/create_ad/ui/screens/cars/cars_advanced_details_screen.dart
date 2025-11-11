import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import '../../../data/car/utils/car_mappers.dart';
import '../../widgets/customized_chip.dart';
import 'logic/cubit/car_ads_cubit.dart';
import 'logic/cubit/car_ads_state.dart';

class CarsAdvancedDetailsScreen extends StatefulWidget {
  final VoidCallback? onPressed;
  const CarsAdvancedDetailsScreen({super.key, this.onPressed});

  @override
  State<CarsAdvancedDetailsScreen> createState() => _CarsAdvancedDetailsScreenState();
}

class _CarsAdvancedDetailsScreenState extends State<CarsAdvancedDetailsScreen> {
  // المتحكمات
  late final TextEditingController _mileageCtrl;
  late final TextEditingController _cylindersCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _horsepowerCtrl;
  late final TextEditingController _vehicleTypeCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<CarAdsCubit>().state;
    // التهيئة من الـ Cubit
    _mileageCtrl = TextEditingController(text: state.mileage?.toString() ?? '');
    _cylindersCtrl = TextEditingController(text: state.cylinders?.toString() ?? '');
    _colorCtrl = TextEditingController(text: state.color ?? '');
    _horsepowerCtrl = TextEditingController(text: state.horsepower?.toString() ?? '');
    _vehicleTypeCtrl = TextEditingController(text: state.vehicleType ?? '');
  }

  @override
  void dispose() {
    _mileageCtrl.dispose();
    _cylindersCtrl.dispose();
    _colorCtrl.dispose();
    _horsepowerCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarAdsCubit>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: BlocBuilder<CarAdsCubit, CarAdsState>(
            builder: (context, state) {
              return Column(
                children: [
                  verticalSpace(16),
                  DetailSelector(
                    title: 'البيع',
                    widget: Row(
                      children: [
                        Expanded(
                          child: CustomizedChip(
                            title: 'تقسيط',
                            isSelected: state.saleType == 'installment',
                            onTap: () => cubit.setSaleType(CarMappers.saleType('تقسيط')),
                          ),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: CustomizedChip(
                            title: 'كاش',
                            isSelected: state.saleType == 'cash',
                            onTap: () => cubit.setSaleType(CarMappers.saleType('كاش')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(16),
                  DetailSelector(
                    title: 'الضمان',
                    widget: Row(
                      children: [
                        Expanded(
                          child: CustomizedChip(
                            title: 'خارج الضمان',
                            isSelected: state.warranty == 'out_of_warranty',
                            onTap: () => cubit.setWarranty(CarMappers.warranty('خارج الضمان')),
                          ),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: CustomizedChip(
                            title: 'تحت الضمان',
                            isSelected: state.warranty == 'under_warranty',
                            onTap: () => cubit.setWarranty(CarMappers.warranty('تحت الضمان')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(16),
                  SecondaryTextFormField(
                    label: 'الممشي',
                    hint: 'أدخل الممشي الحالي للسيارة',
                    maxheight: 56.h,
                    minHeight: 56.h,
                    isNumber: true,
                    controller: _mileageCtrl,
                    onChanged: (v) => cubit.setMileage(num.tryParse(v)),
                  ),
                  verticalSpace(16),
                  DetailSelector(
                    title: 'القير',
                    widget: Row(
                      children: [
                        Expanded(
                          child: CustomizedChip(
                            title: 'قير عادي',
                            isSelected: state.transmission == 'manual',
                            onTap: () => cubit.setTransmission(CarMappers.transmission('قير عادي')),
                          ),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: CustomizedChip(
                            title: 'اوتوماتيك',
                            isSelected: state.transmission == 'automatic',
                            onTap: () => cubit.setTransmission(CarMappers.transmission('اوتوماتيك')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(16),
                  SecondaryTextFormField(
                    label: 'الاسطونات',
                    hint: 'أختر عدد الاسطونات',
                    maxheight: 56.h,
                    minHeight: 56.h,
                    isNumber: true,
                    controller: _cylindersCtrl,
                    onChanged: (v) => cubit.setCylinders(int.tryParse(v)),
                  ),
                  verticalSpace(16),
                  SecondaryTextFormField(
                    label: 'اللون',
                    hint: 'لون السيارة',
                    maxheight: 56.h,
                    minHeight: 56.h,
                    controller: _colorCtrl,
                    onChanged: cubit.setColor,
                  ),
                  verticalSpace(16),
                  DetailSelector(
                    title: 'الوقود',
                    widget: Row(
                      children: [
                        Expanded(child: CustomizedChip(title: 'بنزين', isSelected: state.fuelType=='gasoline', onTap: ()=>cubit.setFuelType(CarMappers.fuel('بنزين')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: 'ديزل', isSelected: state.fuelType=='diesel', onTap: ()=>cubit.setFuelType(CarMappers.fuel('ديزل')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: 'كهربا', isSelected: state.fuelType=='electric', onTap: ()=>cubit.setFuelType(CarMappers.fuel('كهربا')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: 'هايبرد', isSelected: state.fuelType=='hybrid', onTap: ()=>cubit.setFuelType(CarMappers.fuel('هايبرد')))),
                      ],
                    ),
                  ),
                  verticalSpace(16),
                  DetailSelector(
                    title: 'الدفع',
                    widget: Row(
                      children: [
                        Expanded(child: CustomizedChip(title: 'أمامي', isSelected: state.driveType=='front_wheel', onTap: ()=>cubit.setDriveType(CarMappers.driveType('أمامي')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: 'خلفي', isSelected: state.driveType=='rear_wheel', onTap: ()=>cubit.setDriveType(CarMappers.driveType('خلفي')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: 'رباعي', isSelected: state.driveType=='all_wheel', onTap: ()=>cubit.setDriveType(CarMappers.driveType('رباعي')))),
                      ],
                    ),
                  ),
                  verticalSpace(16),
                  SecondaryTextFormField(
                    label: 'قوة الحصان',
                    hint: 'أدخل قوة الحصان',
                    maxheight: 56.h,
                    minHeight: 56.h,
                    isNumber: true,
                    controller: _horsepowerCtrl,
                    onChanged: (v) => cubit.setHorsepower(int.tryParse(v)),
                  ),
                  verticalSpace(16),
                  DetailSelector(
                    title: 'أبواب',
                    widget: Row(
                      children: [
                        Expanded(child: CustomizedChip(title: 'بابين', isSelected: state.doors=='two_door', onTap: ()=>cubit.setDoors(CarMappers.doors('بابين')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: '4 ابواب', isSelected: state.doors=='four_door', onTap: ()=>cubit.setDoors(CarMappers.doors('4 ابواب')))),
                        horizontalSpace(16),
                        Expanded(child: CustomizedChip(title: 'أخري', isSelected: state.doors=='other', onTap: ()=>cubit.setDoors(CarMappers.doors('أخري')))),
                      ],
                    ),
                  ),
                  verticalSpace(16),
                  SecondaryTextFormField(
                    label: 'نوع المركبة',
                    hint: 'سيدان / SUV ...',
                    maxheight: 56.h,
                    minHeight: 56.h,
                    controller: _vehicleTypeCtrl,
                    onChanged: (v) => cubit.setVehicleType(v.trim().isEmpty ? null : v.trim()),
                  ),
                  verticalSpace(16),
                  NextButtonBar(onPressed: widget.onPressed),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}