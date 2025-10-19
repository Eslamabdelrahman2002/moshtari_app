import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/register_service/logic/cubit/service_registration_cubit.dart';

class CompleteProfileStep3Location extends StatefulWidget {
  final VoidCallback onNext;
  const CompleteProfileStep3Location({super.key, required this.onNext});

  @override
  State<CompleteProfileStep3Location> createState() => _CompleteProfileStep3LocationState();
}

class _CompleteProfileStep3LocationState extends State<CompleteProfileStep3Location> {
  String? selectedCity;

  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> cities = const [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'الطائف',
    'تبوك',
    'حائل',
    'أبها',
    'خميس مشيط',
    'جازان',
    'نجران',
    'الباحة',
    'سكاكا',
    'عرعر',
    'الجوف',
    'ينبع',
    'رابغ',
    'القطيف',
    'الأحساء',
    'بيشة',
    'القنفذة',
    'القريات',
  ];

  @override
  void dispose() {
    _districtController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildSelectorField({
    required String label,
    required String placeholder,
    required String? value,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Black500Weight),
        verticalSpace(12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ColorsManager.dark200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value?.isNotEmpty == true ? value! : placeholder,
                    style: value == null || value!.isEmpty
                        ? TextStyles.font12Dark500400Weight
                        : TextStyles.font14Black500Weight,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MySvg(image: iconAsset, width: 18, height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCityDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          title: Text('اختر المدينة', style: TextStyles.font14Black500Weight),
          content: SizedBox(
            width: double.maxFinite,
            height: 400.h,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cities.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: ColorsManager.dark200),
              itemBuilder: (context, index) {
                final c = cities[index];
                final isSelected = c == selectedCity;
                return ListTile(
                  title: Text(c),
                  trailing: isSelected ? Icon(Icons.check, color: ColorsManager.primary300) : null,
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء', style: TextStyles.font14Primary500Weight),
            )
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => selectedCity = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        _buildSelectorField(
          label: 'المدينة',
          placeholder: 'اختر المدينة',
          value: selectedCity,
          iconAsset: 'arrow-down',
          onTap: _showCityDialog,
        ),
        verticalSpace(16),
        SecondaryTextFormField(
          label: 'الحي',
          hint: 'الحي',
          controller: _districtController,
          maxLines: 1,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(16),
        SecondaryTextFormField(
          label: 'العنوان بالكامل',
          hint: 'العنوان بالكامل',
          controller: _addressController,
          maxLines: 1,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(16),
        SecondaryTextFormField(
          label: 'رقم التواصل',
          hint: 'ادخل رقم التواصل',
          controller: _phoneController,
          isPhone: true,
          maxLength: 10,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(32),
        PrimaryButton(
          text: 'التالي',
          onPressed: () {
            context.read<ServiceRegistrationCubit>().updateData((m) {
              m.city = selectedCity;
              m.district = _districtController.text.trim();
              m.fullAddress = _addressController.text.trim();
              m.phone = _phoneController.text.trim();
            });
            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}