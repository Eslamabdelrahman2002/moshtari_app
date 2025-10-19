import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/register_service/logic/cubit/service_registration_cubit.dart';

class CompleteProfileStep1Personal extends StatefulWidget {
  final VoidCallback onNext;
  const CompleteProfileStep1Personal({super.key, required this.onNext});

  @override
  State<CompleteProfileStep1Personal> createState() => _CompleteProfileStep1PersonalState();
}

class _CompleteProfileStep1PersonalState extends State<CompleteProfileStep1Personal> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  String? selectedNationality;
  DateTime? selectedDOB;

  final List<String> nationalities = const [
    'السعودية','الإمارات','الكويت','قطر','البحرين','عُمان','مصر','الأردن',
    'لبنان','سوريا','العراق','اليمن','فلسطين','ليبيا','تونس','الجزائر',
    'المغرب','السودان','تركيا','الهند','باكستان','الفلبين',
  ];

  // Image picker and files
  final ImagePicker _picker = ImagePicker();
  File? _personalImage;
  File? _idImage;
  File? _extraDocImage;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  // BottomSheet لاختيار كاميرا/معرض ثم الالتقاط
  Future<void> _pickImageWithSheet({
    required void Function(File file) onPicked,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? x = await _picker.pickImage(source: source, imageQuality: 85);
    if (x != null) onPicked(File(x.path));
  }

  Widget _preview(File? file) {
    if (file == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.file(
          file,
          height: 90.h,
          width: 160.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // صندوق الرفع مع onTap + معاينة
  Widget _buildImageUploadBox(
      String title, {
        bool isOptional = false,
        required VoidCallback onTap,
        bool attached = false,
        File? file,
        String description = 'يجب إرفاق صورة رخصة القيادة بوضوح',
      }) {
    final String optionalText = isOptional ? ' (اختياري)' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title$optionalText', style: TextStyles.font14Black500Weight),
        verticalSpace(12),
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(12.r),
          padding: EdgeInsets.zero,
          dashPattern: const [8, 4],
          strokeWidth: 1.5,
          color: ColorsManager.primary300,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MySvg(image: 'gallery-add', width: 20, height: 20),
                      SizedBox(width: 10.w),
                      Text(attached ? 'تم إرفاق صورة' : 'إضافة صورة',
                          style: TextStyles.font14Primary300500Weight),
                    ],
                  ),
                  Text(description, style: TextStyles.font12Dark500400Weight, textAlign: TextAlign.center),
                  _preview(file),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
                        ? TextStyles.font12DarkGray400Weight
                        : TextStyles.font14DarkGray400Weight,
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
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );

    if (picked != null) setState(() => selectedDOB = picked);
  }

  Future<void> _showNationalityDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return Directionality(
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
                child: Text('إلغاء', style: TextStyles.font14Primary500Weight),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) setState(() => selectedNationality = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
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
          iconAsset: 'calendar',
          onTap: _pickDOB,
        ),
        verticalSpace(16),

        _buildSelectorField(
          label: 'الجنسية',
          placeholder: 'اختر الجنسية',
          value: selectedNationality,
          iconAsset: 'arrow-down',
          onTap: _showNationalityDialog,
        ),
        verticalSpace(24),

        // صورة شخصية
        _buildImageUploadBox(
          'صورة شخصية',
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _personalImage = file);
            context.read<ServiceRegistrationCubit>().updateData((m) => m.personalImage = file);
          }),
          attached: _personalImage != null,
          file: _personalImage,
          description: 'ارفق صورة شخصية واضحة',
        ),
        verticalSpace(16),

        // صورة بطاقة الهوية / الإقامة
        _buildImageUploadBox(
          'صورة بطاقة الهوية / الإقامة',
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _idImage = file);
            context.read<ServiceRegistrationCubit>().updateData((m) => m.idImage = file);
          }),
          attached: _idImage != null,
          file: _idImage,
          description: 'ارفق صورة بطاقة الهوية/الإقامة بوضوح',
        ),
        verticalSpace(16),

        // صورة إضافية للمستندات (اختياري) — تُحفظ في extraImages
        _buildImageUploadBox(
          'صورة إضافية للمستندات',
          isOptional: true,
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _extraDocImage = file);
            context.read<ServiceRegistrationCubit>().updateData((m) {
              final extras = <File>[file];
              if (m.extraImages != null) {
                for (final f in m.extraImages!) {
                  if (f.path != file.path) extras.add(f);
                }
              }
              m.extraImages = extras;
            });
          }),
          attached: _extraDocImage != null,
          file: _extraDocImage,
          description: 'يمكنك إرفاق أي مستند إضافي يدعم طلبك',
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