// lib/features/work_with_us/ui/screens/transport_step1_personal.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/register_service/logic/cubit/service_registration_cubit.dart';

class TransportStep1Personal extends StatefulWidget {
  final VoidCallback onNext;
  const TransportStep1Personal({super.key, required this.onNext});

  @override
  State<TransportStep1Personal> createState() => _TransportStep1PersonalState();
}

class _TransportStep1PersonalState extends State<TransportStep1Personal> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  String? selectedNationality;
  DateTime? selectedDOB;

  final List<String> nationalities = const [
    'السعودية','الإمارات','الكويت','قطر','البحرين','عُمان','مصر','الأردن',
    'لبنان','سوريا','العراق','اليمن','فلسطين','ليبيا','تونس','الجزائر',
    'المغرب','السودان','تركيا','الهند','باكستان','الفلبين',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Widget _buildSelectorField({
    required String label,
    required String placeholder,
    required String? value,
    required VoidCallback onTap,
    String iconAsset = 'arrow-down',
  }) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    hasValue ? value! : placeholder,
                    style: hasValue
                        ? TextStyles.font14DarkGray400Weight
                        : TextStyles.font12DarkGray400Weight,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
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

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String? get _birthDateIso {
    if (selectedDOB == null) return null;
    final y = selectedDOB!.year.toString().padLeft(4, '0');
    final m = selectedDOB!.month.toString().padLeft(2, '0');
    final d = selectedDOB!.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB ?? eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تم',
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );

    if (picked != null) {
      setState(() => selectedDOB = picked);
    }
  }

  Future<void> _showNationalityDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          title: Text('اختر الجنسية', style: TextStyles.font14Black500Weight),
          content: SizedBox(
            width: double.maxFinite,
            height: 400.h,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: nationalities.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: ColorsManager.dark200),
              itemBuilder: (context, index) {
                final n = nationalities[index];
                final isSelected = n == selectedNationality;
                return ListTile(
                  title: Text(n),
                  trailing: isSelected ? Icon(Icons.check, color: ColorsManager.primary300) : null,
                  onTap: () => Navigator.of(context).pop(n),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => selectedNationality = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecondaryTextFormField(
          label: 'الاسم كامل',
          hint: 'الاسم كامل',
          controller: _nameController,
          maxLines: 1,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(16),

        SecondaryTextFormField(
          label: 'رقم الهوية / الإقامة',
          hint: 'رقم الهوية / الإقامة',
          controller: _idController,
          maxLines: 1,
          isNumber: true,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(16),

        _buildSelectorField(
          label: 'تاريخ الميلاد',
          placeholder: 'اختر تاريخ الميلاد',
          value: selectedDOB == null ? null : _formatDate(selectedDOB!),
          onTap: _pickDOB,
          iconAsset: 'calendar',
        ),
        verticalSpace(16),

        _buildSelectorField(
          label: 'الجنسية',
          placeholder: 'اختر الجنسية',
          value: selectedNationality,
          onTap: _showNationalityDialog,
          iconAsset: 'arrow-down',
        ),
        verticalSpace(32),

        PrimaryButton(
          text: 'التالي',
          onPressed: () {
            context.read<ServiceRegistrationCubit>().updateData((m) {
              m.fullName = _nameController.text.trim();
              m.idNumber = _idController.text.trim();
              m.birthDate = _birthDateIso;
              m.nationality = selectedNationality;
            });
            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}