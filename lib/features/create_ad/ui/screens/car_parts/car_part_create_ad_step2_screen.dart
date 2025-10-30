import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart'; // ✅ لـ pickMultiImage

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import 'package:mushtary/features/create_ad/ui/widgets/photo_picker.dart';
import 'package:mushtary/features/create_ad/ui/widgets/media_grid_picker.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/two_step_header.dart';

import 'logic/cubit/car_part_ads_cubit.dart';
import 'logic/cubit/car_part_ads_state.dart';

import 'package:path/path.dart' as p;

class CarPartCreateAdStep2Screen extends StatefulWidget {
  const CarPartCreateAdStep2Screen({super.key});

  @override
  State<CarPartCreateAdStep2Screen> createState() => _CarPartCreateAdStep2ScreenState();
}

class _CarPartCreateAdStep2ScreenState extends State<CarPartCreateAdStep2Screen> {
  static const List<String> kAllowedMediaExt = ['.jpg', '.jpeg', '.png', '.mp4'];

  final _titleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _offerDescCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  final List<File> _picked = []; // ✅ قائمة للصور/الملفات المتعددة

  String priceType = 'fixed'; // fixed | negotiable
  bool allowComments = true;
  bool allowMarketing = true;
  bool allowNegotiationSwitch = false;

  bool chat = false;
  bool whatsapp = false;
  bool phone = false;

  @override
  void initState() {
    super.initState();
    // تنظيف قائمة الملفات المؤقتة لمنع "الملف موجود مسبقاً"
    PhotoPicker.clearSelectedFiles();

    final s = context.read<CarPartAdsCubit>().state;

    _titleCtrl.text = s.title ?? '';
    _offerDescCtrl.text = s.description ?? '';
    _phoneCtrl.text = s.phoneNumber ?? '';
    if (s.price != null) _priceCtrl.text = '${s.price}';

    priceType = s.priceType.isNotEmpty ? s.priceType : 'fixed';
    allowComments = s.allowComments;
    allowMarketing = s.allowMarketing;
    allowNegotiationSwitch = priceType == 'negotiable';

    final methods = s.communicationMethods ?? const <String>[];
    chat = methods.contains('chat');
    whatsapp = methods.contains('whatsapp');
    phone = methods.contains('call') || methods.contains('phone');

    // ✅ تهيئة _picked من State (دعم متعدد)
    if (s.images.isNotEmpty) {
      _picked.addAll(s.images);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _phoneCtrl.dispose();
    _offerDescCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  bool _isSupportedMedia(File f) {
    final ext = p.extension(f.path).toLowerCase();
    return kAllowedMediaExt.contains(ext);
  }

  Future<File> _compressImageIfNeeded(File file) async {
    // بدون ضغط (يمكن إضافة flutter_image_compress إذا مطلوب)
    return file;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  // ✅ اختيار صور/ملفات متعددة (حد أقصى 10)
  Future<void> pickImages() async {
    final cubit = context.read<CarPartAdsCubit>();
    final picker = ImagePicker(); // ✅ استخدام ImagePicker بدلاً من PhotoPicker للدعم الأفضل

    final images = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
      limit: 10, // حد أقصى 10 ملفات
    );

    if (!mounted || images.isEmpty) return;

    for (final x in images) {
      final file = File(x.path);
      if (!_isSupportedMedia(file)) {
        _showError('الملف ${p.basename(file.path)} ليس بصيغة مدعومة (png, jpg, mp4).');
        continue;
      }

      final finalFile = await _compressImageIfNeeded(file);
      _picked.add(finalFile);
      cubit.addImage(finalFile); // ✅ إضافة إلى Cubit
      print('>>> Added image: ${finalFile.path}'); // Debug
    }

    setState(() {}); // تحديث UI
    if (_picked.length >= 10) {
      _showError('تم الوصول للحد الأقصى (10 ملفات)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarPartAdsCubit>();

    return BlocListener<CarPartAdsCubit, CarPartAdsState>(
      listenWhen: (p, c) =>
      p.submitting != c.submitting || p.success != c.success || p.error != c.error,
      listener: (context, state) {
        if (state.submitting) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('جارٍ إنشاء الإعلان...')));
        } else if (state.success) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('تم إنشاء الإعلان بنجاح')));
          Navigator.pop(context);
          Navigator.pop(context);
        } else if (state.error != null) {
          _showError(state.error!);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: const TwoStepHeader(currentStep: 1),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ✅ قسم الوسائط (دعم متعدد)
                      if (_picked.isEmpty)
                        _addMediaBox(onTap: pickImages)
                      else
                        MediaGridPicker(
                          files: _picked, // ✅ تمرير القائمة المتعددة
                          onAdd: pickImages, // إضافة أكثر
                          onRemove: (i) {
                            cubit.removeImageAt(i); // ✅ حذف من Cubit
                            setState(() => _picked.removeAt(i)); // تحديث UI
                          },
                          maxCount: 10, // حد أقصى
                          title: 'الصور ومقاطع الفيديو',
                        ),
                      verticalSpace(16),

                      _field(
                        'عنوان الاعلان',
                        _titleCtrl,
                        hint: 'مثال: فلتر زيت أصلي',
                        onChanged: cubit.setTitle,
                      ),
                      verticalSpace(12),

                      _field(
                        'وصف العرض',
                        _offerDescCtrl,
                        hint: 'اكتب وصفًا للمنتج...',
                        maxLines: 3,
                        onChanged: cubit.setDescription,
                      ),
                      verticalSpace(12),

                      // السعر
                      TextField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (v) {
                          final parsed = num.tryParse(v.replaceAll(',', '').trim());
                          cubit.setPrice(parsed);
                        },
                        decoration: InputDecoration(
                          labelText: 'السعر',
                          hintText: 'مثال: 250',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: ColorsManager.dark200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: ColorsManager.primary300),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          suffixText: 'ر.س',
                        ),
                      ),
                      verticalSpace(12),

                      _field(
                        'رقم الهاتف',
                        _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        onChanged: cubit.setPhoneNumber,
                      ),
                      verticalSpace(16),

                      Text('التواصل', style: TextStyles.font16Black500Weight),
                      verticalSpace(8),
                      Row(
                        children: [
                          Expanded(
                            child: _contactButton(
                              text: 'محادثة',
                              selected: chat,
                              onTap: () {
                                setState(() => chat = !chat);
                                _updateComms(cubit);
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _contactButton(
                              text: 'واتساب',
                              selected: whatsapp,
                              onTap: () {
                                setState(() => whatsapp = !whatsapp);
                                _updateComms(cubit);
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _contactButton(
                              text: 'جوال',
                              selected: phone,
                              onTap: () {
                                setState(() => phone = !phone);
                                _updateComms(cubit);
                              },
                            ),
                          ),
                        ],
                      ),

                      verticalSpace(16),
                      const Divider(height: 1, color: Color(0xFFEAEAEA)),
                      verticalSpace(8),

                      _switchTile(
                        title: 'السماح بالتعليق على الاعلان',
                        value: allowComments,
                        onChanged: (v) {
                          setState(() => allowComments = v);
                          cubit.setAllowComments(v);
                        },
                      ),
                      _switchTile(
                        title: 'استقبال عروض للتسويق',
                        value: allowMarketing,
                        onChanged: (v) {
                          setState(() => allowMarketing = v);
                          cubit.setAllowMarketing(v);
                        },
                      ),
                      _switchTile(
                        title: 'السماح بالتفاوض على الإعلان',
                        value: allowNegotiationSwitch,
                        onChanged: (v) {
                          setState(() {
                            allowNegotiationSwitch = v;
                            priceType = v ? 'negotiable' : 'fixed';
                          });
                          cubit.setPriceType(priceType);
                        },
                      ),
                      verticalSpace(20),

                      // زر النشر: نعطّل أثناء الإرسال
                      BlocBuilder<CarPartAdsCubit, CarPartAdsState>(
                        buildWhen: (p, c) => p.submitting != c.submitting,
                        builder: (context, s) {
                          return AbsorbPointer(
                            absorbing: s.submitting,
                            child: PrimaryButton(
                              text: s.submitting ? 'جارٍ النشر...' : 'نشر الاعلان',
                              onPressed: () {
                                // ✅ تحديث نهائي للقيم قبل Submit
                                cubit
                                  ..setTitle(_titleCtrl.text)
                                  ..setDescription(_offerDescCtrl.text)
                                  ..setPhoneNumber(_phoneCtrl.text)
                                  ..setPrice(num.tryParse(_priceCtrl.text));

                                cubit.submit(); // ✅ Submit مع الصور المتعددة
                              },
                            ),
                          );
                        },
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addMediaBox({required VoidCallback onTap}) {
    return DottedBorder(
      color: ColorsManager.dark200,
      strokeWidth: 1.2,
      dashPattern: const [6, 4],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 22.h),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.collections_rounded, size: 28.sp, color: ColorsManager.primary400),
              SizedBox(height: 8.h),
              Text('إضافة صورة أو مقطع فيديو', style: TextStyles.font14Blue500Weight),
              SizedBox(height: 6.h),
              Text(
                'ندعم صيغ png, jpg, mp4 (حتى 10 ملفات)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateComms(CarPartAdsCubit cubit) {
    final methods = <String>[];
    if (chat) methods.add('chat');
    if (whatsapp) methods.add('whatsapp');
    if (phone) methods.add('call');
    cubit.setCommunicationMethods(methods);
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
        int maxLines = 1,
        String? hint,
        Function(String)? onChanged,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: ColorsManager.dark200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: ColorsManager.primary300),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  Widget _contactButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? ColorsManager.primaryColor : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black87,
          side: BorderSide(
            color: selected ? Colors.transparent : ColorsManager.dark200,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
        ),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              inactiveTrackColor: ColorsManager.lightGrey,
              activeTrackColor: ColorsManager.secondary200,
              thumbColor: ColorsManager.secondary500,
            ),
          ),
          horizontalSpace(8),
          Expanded(
            child: Text(title, style: TextStyles.font14Dark500Weight),
          ),
        ],
      ),
    );
  }
}