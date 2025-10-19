import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/register_service/logic/cubit/service_registration_cubit.dart';

class DeliveryStep3Documents extends StatefulWidget {
  final VoidCallback onNext;
  const DeliveryStep3Documents({super.key, required this.onNext});

  @override
  State<DeliveryStep3Documents> createState() => _DeliveryStep3DocumentsState();
}

class _DeliveryStep3DocumentsState extends State<DeliveryStep3Documents> {
  final ImagePicker _picker = ImagePicker();

  File? _frontImage;
  File? _backImage;
  File? _licenseImage;
  File? _registrationImage; // الاستمارة

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

  // صندوق الرفع (بدوتد بوردر) + onTap + معاينة
  Widget _buildImageUploadBox(
      String title, {
        String? description,
        bool isOptional = false,
        required VoidCallback onTap,
        bool attached = false,
        File? file,
      }) {
    final String desc = (description != null && description.trim().isNotEmpty)
        ? description
        : 'يجب إرفاق صورة رخصة القيادة بوضوح';
    final String optionalText = isOptional ? ' (اختياري)' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title$optionalText', style: TextStyles.font14DarkGray400Weight),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MySvg(image: 'gallery-add', width: 20, height: 20),
                      SizedBox(width: 10.w),
                      Text(
                        attached ? 'تم إرفاق صورة' : 'إضافة صورة',
                        style: TextStyles.font14Primary300500Weight,
                      ),
                    ],
                  ),
                  Text(
                    desc,
                    style: TextStyles.font12Dark500400Weight,
                    textAlign: TextAlign.center,
                  ),
                  _preview(file),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateCubitImages() {
    context.read<ServiceRegistrationCubit>().updateData((m) {
      m.frontImage = _frontImage;
      m.backImage = _backImage;
      m.licenseImage = _licenseImage;

      if (_registrationImage != null) {
        final extras = <File>[_registrationImage!];
        if (m.extraImages != null) {
          for (final f in m.extraImages!) {
            if (f.path != _registrationImage!.path) extras.add(f);
          }
        }
        m.extraImages = extras;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageUploadBox(
          'صورة وجه السيارة الأمامي',
          description: 'يجب أن يظهر وجه السيارة الأمامي بوضوح ورقم السيارة',
          attached: _frontImage != null,
          file: _frontImage,
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _frontImage = file);
            context.read<ServiceRegistrationCubit>().updateData((m) => m.frontImage = file);
          }),
        ),
        verticalSpace(16),

        _buildImageUploadBox(
          'صورة وجه السيارة الخلفي',
          description: 'يجب أن يظهر وجه السيارة الخلفي بوضوح ورقم السيارة',
          attached: _backImage != null,
          file: _backImage,
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _backImage = file);
            context.read<ServiceRegistrationCubit>().updateData((m) => m.backImage = file);
          }),
        ),
        verticalSpace(16),

        _buildImageUploadBox(
          'صورة رخصة القيادة',
          description: 'يجب إرفاق صورة رخصة القيادة بوضوح',
          attached: _licenseImage != null,
          file: _licenseImage,
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _licenseImage = file);
            context.read<ServiceRegistrationCubit>().updateData((m) => m.licenseImage = file);
          }),
        ),
        verticalSpace(16),

        _buildImageUploadBox(
          'صورة الاستمارة',
          description: 'يجب إرفاق صورة الاستمارة بوضوح',
          attached: _registrationImage != null,
          file: _registrationImage,
          onTap: () => _pickImageWithSheet(onPicked: (file) {
            setState(() => _registrationImage = file);
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
        ),
        verticalSpace(32),

        PrimaryButton(
          text: 'إرسال',
          onPressed: () {
            _updateCubitImages();
            // ممكن تستدعي submitRegistration هنا لو جاهز
            // await context.read<ServiceRegistrationCubit>().submitRegistration();
            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}