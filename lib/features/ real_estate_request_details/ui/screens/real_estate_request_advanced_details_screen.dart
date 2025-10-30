import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

import '../cubit/real_estate_requests_cubit.dart';
import '../cubit/real_estate_requests_state.dart';

class RealEstateRequestAdvancedDetailsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const RealEstateRequestAdvancedDetailsScreen({super.key, this.onNext});

  @override
  State<RealEstateRequestAdvancedDetailsScreen> createState() =>
      _RealEstateRequestAdvancedDetailsScreenState();
}

class _RealEstateRequestAdvancedDetailsScreenState extends State<RealEstateRequestAdvancedDetailsScreen> {
  final Set<String> selectedServices = <String>{};
  String? selectedFacade;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RealEstateRequestsCubit>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: BlocBuilder<RealEstateRequestsCubit, RealEstateRequestsState>(
          builder: (context, state) {
            print('>>> [Advanced] Build - Services: $selectedServices, Facade: $selectedFacade'); // Debug
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ميزانية السعر (Min/Max)
                Text('ميزانية الشراء/الإيجار', style: TextStyles.font16DarkGrey500Weight),
                verticalSpace(8),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحد الأدنى',
                        hint: '50000',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Budget Min changed: $v'); // Debug
                          cubit.setBudgetMin(num.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحد الأقصى',
                        hint: '100000',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Budget Max changed: $v'); // Debug
                          cubit.setBudgetMax(num.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // المساحة المطلوبة (Min/Max)
                Text('المساحة المطلوبة (م²)', style:TextStyles.font16DarkGrey500Weight),
                verticalSpace(8),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحد الأدنى',
                        hint: '120',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Area Min changed: $v'); // Debug
                          cubit.setAreaMin(num.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحد الأقصى',
                        hint: '300',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Area Max changed: $v'); // Debug
                          cubit.setAreaMax(num.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // عرض الشارع المطلوب (Min/Max)
                Text('عرض الشارع المطلوب (م)', style: TextStyles.font16DarkGrey500Weight),
                verticalSpace(8),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحد الأدنى',
                        hint: '10',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Street Min changed: $v'); // Debug
                          cubit.setStreetWidthMin(int.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحد الأقصى',
                        hint: '20',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Street Max changed: $v'); // Debug
                          cubit.setStreetWidthMax(int.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // الأدوار + الغرف + الحمامات + الصالات
                SecondaryTextFormField(
                  label: 'الأدوار المفضلة',
                  hint: '2',
                  isNumber: true,
                  onChanged: (v) {
                    print('>>> [Advanced] Floors changed: $v'); // Debug
                    cubit.setPreferredFloors(int.tryParse(v));
                  },
                  maxheight: 56.h,
                  minHeight: 56.h,
                ),
                verticalSpace(16),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الغرف المفضلة',
                        hint: '3',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Rooms changed: $v'); // Debug
                          cubit.setPreferredRooms(int.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الحمامات المفضلة',
                        hint: '2',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Bathrooms changed: $v'); // Debug
                          cubit.setPreferredBathrooms(int.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: SecondaryTextFormField(
                        label: 'الصالات المفضلة',
                        hint: '1',
                        isNumber: true,
                        onChanged: (v) {
                          print('>>> [Advanced] Livingrooms changed: $v'); // Debug
                          cubit.setPreferredLivingrooms(int.tryParse(v));
                        },
                        maxheight: 56.h,
                        minHeight: 56.h,
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),

                // الواجهة المفضلة (Chips مثل الـ Create)
                DetailSelector(
                  title: 'الواجهة المفضلة',
                  widget: Row(
                    children: [
                      _buildFacadeChip(cubit, 'north', 'شمال'),
                      horizontalSpace(8),
                      _buildFacadeChip(cubit, 'south', 'جنوب'),
                      horizontalSpace(8),
                      _buildFacadeChip(cubit, 'east', 'شرق'),
                      horizontalSpace(8),
                      _buildFacadeChip(cubit, 'west', 'غرب'),
                    ],
                  ),
                ),
                verticalSpace(16),

                // الخدمات (Wrap Chips مثل الـ Create)
                DetailSelector(
                  title: 'الخدمات المطلوبة',
                  widget: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _serviceChip(cubit, 'electricity', 'كهرباء'),
                      _serviceChip(cubit, 'water', 'مياه'),
                      _serviceChip(cubit, 'gas', 'غاز'),
                      _serviceChip(cubit, 'sewage', 'صرف'),
                      _serviceChip(cubit, 'fiber', 'ألياف'),
                    ],
                  ),
                ),
                verticalSpace(16),

                NextButtonBar(
                  onPressed: () {
                    print('>>> [Advanced] Next pressed - Services: $selectedServices'); // Debug
                    cubit.setServices(selectedServices.toList());
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

  Widget _buildFacadeChip(RealEstateRequestsCubit cubit, String key, String label) {
    return Expanded(
      child: CustomizedChip(
        title: label,
        isSelected: selectedFacade == key,
        onTap: () {
          setState(() => selectedFacade = key);
          cubit.setPreferredFacade(key);
          print('>>> [Advanced] Facade selected: $key ($label)'); // Debug
        },
      ),
    );
  }

  Widget _serviceChip(RealEstateRequestsCubit cubit, String key, String label) {
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
        print('>>> [Advanced] Service $key ($label) ${selected ? 'removed' : 'added'}'); // Debug
      },
      child: CustomizedChip(title: label, isSelected: selected),
    );
  }
}