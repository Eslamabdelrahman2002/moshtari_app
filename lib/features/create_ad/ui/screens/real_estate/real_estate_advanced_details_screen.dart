// lib/features/create_ad/ui/screens/real_estate/real_estate_advanced_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_mappers.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

import 'logic/cubit/real_estate_ads_cubit.dart';
import 'logic/cubit/real_estate_ads_state.dart';

class RealEstateAdvancedDetailsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const RealEstateAdvancedDetailsScreen({super.key, this.onNext});

  @override
  State<RealEstateAdvancedDetailsScreen> createState() =>
      _RealEstateAdvancedDetailsScreenState();
}

class _RealEstateAdvancedDetailsScreenState
    extends State<RealEstateAdvancedDetailsScreen> {
  final Set<String> selectedServices = {};

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RealEstateAdsCubit>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: BlocBuilder<RealEstateAdsCubit, RealEstateAdsState>(
          builder: (context, state) {
            return Column(
              children: [
                // السعر
                SecondaryTextFormField(
                  label: 'السعر',
                  hint: '1500000',
                  isNumber: true,
                  maxheight: 56.h,
                  minHeight: 56.h,
                  onChanged: (v) => cubit.setPrice(num.tryParse(v)),
                ),
                verticalSpace(16),

                // نوع السعر
                DetailSelector(
                  title: 'نوع السعر',
                  widget: Row(
                    children: [
                      Expanded(
                        child: CustomizedChip(
                          title: 'سعر محدد',
                          isSelected: state.priceType == 'fixed',
                          onTap: () => cubit.setPriceType(
                              RealEstateMappers.priceType('سعر محدد')),
                        ),
                      ),
                      horizontalSpace(16),
                      Expanded(
                        child: CustomizedChip(
                          title: 'علي السوم',
                          isSelected: state.priceType == 'negotiable',
                          onTap: () => cubit.setPriceType(
                              RealEstateMappers.priceType('علي السوم')),
                        ),
                      ),
                      horizontalSpace(16),
                      Expanded(
                        child: CustomizedChip(
                          title: 'مزاد',
                          isSelected: state.priceType == 'auction',
                          onTap: () => cubit.setPriceType(
                              RealEstateMappers.priceType('مزاد')),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(16),

                // المساحة
                SecondaryTextFormField(
                  label: 'المساحة (م²)',
                  hint: '400',
                  isNumber: true,
                  maxheight: 56.h,
                  minHeight: 56.h,
                  onChanged: (v) => cubit.setAreaM2(num.tryParse(v)),
                ),
                verticalSpace(16),

                // عدد الشوارع + الأدوار
                Row(
                  children: [
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'عدد الشوارع',
                        hint: '2',
                        isNumber: true,
                        maxheight: 56.h,
                        minHeight: 56.h,
                        onChanged: (v) =>
                            cubit.setStreetCount(int.tryParse(v)),
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'عدد الأدوار',
                        hint: '2',
                        isNumber: true,
                        maxheight: 56.h,
                        minHeight: 56.h,
                        onChanged: (v) => cubit.setFloorCount(int.tryParse(v)),
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // الغرف + الحمامات + الصالات
                Row(
                  children: [
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الغرف',
                        hint: '5',
                        isNumber: true,
                        maxheight: 56.h,
                        minHeight: 56.h,
                        onChanged: (v) => cubit.setRoomCount(int.tryParse(v)),
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحمامات',
                        hint: '3',
                        isNumber: true,
                        maxheight: 56.h,
                        minHeight: 56.h,
                        onChanged: (v) =>
                            cubit.setBathroomCount(int.tryParse(v)),
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الصالات',
                        hint: '2',
                        isNumber: true,
                        maxheight: 56.h,
                        minHeight: 56.h,
                        onChanged: (v) =>
                            cubit.setLivingroomCount(int.tryParse(v)),
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // عرض الشارع
                SecondaryTextFormField(
                  label: 'عرض الشارع (م)',
                  hint: '20',
                  isNumber: true,
                  maxheight: 56.h,
                  minHeight: 56.h,
                  onChanged: (v) => cubit.setStreetWidth(num.tryParse(v)),
                ),
                verticalSpace(16),

                // الواجهة
                DetailSelector(
                  title: 'الواجهة',
                  widget: Row(
                    children: [
                      Expanded(
                        child: CustomizedChip(
                          title: 'شمال',
                          isSelected: state.facade == 'north',
                          onTap: () =>
                              cubit.setFacade(RealEstateMappers.facade('شمال')),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'جنوب',
                          isSelected: state.facade == 'south',
                          onTap: () =>
                              cubit.setFacade(RealEstateMappers.facade('جنوب')),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'شرق',
                          isSelected: state.facade == 'east',
                          onTap: () =>
                              cubit.setFacade(RealEstateMappers.facade('شرق')),
                        ),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: CustomizedChip(
                          title: 'غرب',
                          isSelected: state.facade == 'west',
                          onTap: () =>
                              cubit.setFacade(RealEstateMappers.facade('غرب')),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(16),

                // عمر المبنى
                DetailSelector(
                  title: 'عمر المبنى',
                  widget: Row(
                    children: [
                      Expanded(
                        child: CustomizedChip(
                          title: 'جديد',
                          isSelected: state.buildingAge == 'new',
                          onTap: () => cubit.setBuildingAge(
                              RealEstateMappers.buildingAge('جديد')),
                        ),
                      ),
                      horizontalSpace(16),
                      Expanded(
                        child: CustomizedChip(
                          title: 'مستعمل',
                          isSelected: state.buildingAge == 'used',
                          onTap: () => cubit.setBuildingAge(
                              RealEstateMappers.buildingAge('مستعمل')),
                        ),
                      ),
                      horizontalSpace(16),
                      Expanded(
                        child: CustomizedChip(
                          title: 'قديم',
                          isSelected: state.buildingAge == 'old',
                          onTap: () => cubit.setBuildingAge(
                              RealEstateMappers.buildingAge('قديم')),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(16),

                // مفروش + الرخصة
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('مفروش'),
                        value: state.isFurnished ?? false,
                        onChanged: (v) => cubit.setIsFurnished(v),
                        activeColor: Colors.yellow,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'رقم الرخصة',
                        hint: '123456',
                        maxheight: 56.h,
                        minHeight: 56.h,
                        onChanged: (v) => cubit.setLicenseNumber(
                            v.trim().isEmpty ? null : v.trim()),
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // الخدمات
                DetailSelector(
                  title: 'الخدمات',
                  widget: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _serviceChip('electricity'),
                      _serviceChip('water'),
                      _serviceChip('gas'),
                      _serviceChip('sewage'),
                      _serviceChip('fiber'),
                    ],
                  ),
                ),
                verticalSpace(16),

                NextButtonBar(
                  onPressed: () {
                    context
                        .read<RealEstateAdsCubit>()
                        .setServices(selectedServices.toList());
                    widget.onNext?.call();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _serviceChip(String key) {
    final label = {
      'electricity': 'كهرباء',
      'water': 'مياه',
      'gas': 'غاز',
      'sewage': 'صرف',
      'fiber': 'ألياف',
    }[key]!;
    final selected = selectedServices.contains(key);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            selectedServices.remove(key);
          } else {
            selectedServices.add(key);
          }
        });
      },
      child: CustomizedChip(title: label, isSelected: selected),
    );
  }
}