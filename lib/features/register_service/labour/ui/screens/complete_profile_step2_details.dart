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

class CompleteProfileStep2Details extends StatefulWidget {
  final VoidCallback onNext;
  const CompleteProfileStep2Details({super.key, required this.onNext});

  @override
  State<CompleteProfileStep2Details> createState() => _CompleteProfileStep2DetailsState();
}

class _CompleteProfileStep2DetailsState extends State<CompleteProfileStep2Details> {
  bool hasTransportation = true;
  String? selectedSpecialization;
  final _descController = TextEditingController();

  final List<String> specializations = const [
    'نجار',
    'كهربائي',
    'سباك',
    'فني تكييف',
    'سائق',
    'مندوب توصيل',
    'محاسب',
    'بائع',
    'مدخل بيانات',
    'حارس أمن',
    'ممرض',
    'معلم',
    'مترجم',
    'مصمم جرافيك',
    'مطور تطبيقات',
    'مطور ويب',
    'مهندس مدني',
    'مهندس معماري',
    'طاهٍ',
    'باريستا',
  ];

  @override
  void dispose() {
    _descController.dispose();
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

  Future<void> _showSpecializationDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          title: Text('اختر المهنة / التخصص', style: TextStyles.font14Black500Weight),
          content: SizedBox(
            width: double.maxFinite,
            height: 400.h,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: specializations.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: ColorsManager.dark200),
              itemBuilder: (context, index) {
                final item = specializations[index];
                final isSelected = item == selectedSpecialization;
                return ListTile(
                  title: Text(item),
                  trailing: isSelected ? Icon(Icons.check, color: ColorsManager.primary300) : null,
                  onTap: () => Navigator.of(context).pop(item),
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
      setState(() => selectedSpecialization = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        _buildSelectorField(
          label: 'المهنة / التخصص المطلوب تقديمه',
          placeholder: 'اختر المهنة / التخصص',
          value: selectedSpecialization,
          iconAsset: 'arrow-down',
          onTap: _showSpecializationDialog,
        ),
        verticalSpace(16),
        SecondaryTextFormField(
          hint: 'اكتب الوصف المناسب',
          controller: _descController,
          maxLines: 5,
          minHeight: 120.h,
          maxheight: 120.h,
        ),
        verticalSpace(16),
        Text('وصف مختصر للخبرات أو الأعمال السابقة', style: TextStyles.font14DarkGray400Weight),
        verticalSpace(24),
        Text('توفر وسيلة مواصلات', style: TextStyles.font16Black500Weight),
        verticalSpace(12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => hasTransportation = true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: hasTransportation ? ColorsManager.primaryColor : ColorsManager.white,
                  side: BorderSide(
                    color: hasTransportation ? ColorsManager.primaryColor : ColorsManager.dark200,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  'نعم',
                  style: TextStyles.font16Black500Weight.copyWith(
                    color: hasTransportation ? ColorsManager.white : ColorsManager.black,
                  ),
                ),
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => hasTransportation = false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: !hasTransportation ? ColorsManager.primaryColor : ColorsManager.white,
                  side: BorderSide(
                    color: !hasTransportation ? ColorsManager.primaryColor : ColorsManager.dark200,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  'لا',
                  style: TextStyles.font16Black500Weight.copyWith(
                    color: !hasTransportation ? ColorsManager.white : ColorsManager.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        verticalSpace(32),
        PrimaryButton(
          text: 'التالي',
          onPressed: () {
            context.read<ServiceRegistrationCubit>().updateData((m) {
              m.specialization = selectedSpecialization;
              m.experienceDescription = _descController.text.trim();
              m.hasTransportation = hasTransportation;
            });
            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}