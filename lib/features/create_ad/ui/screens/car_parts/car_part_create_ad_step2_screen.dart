import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/create_ad/ui/widgets/media_grid_picker.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/two_step_header.dart';

import 'logic/cubit/car_part_ads_cubit.dart';
import 'logic/cubit/car_part_ads_state.dart';

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

  final List<File> _picked = [];

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
    final s = context.read<CarPartAdsCubit>().state;

    _titleCtrl.text = s.title ?? '';
    _offerDescCtrl.text = s.description ?? '';
    _phoneCtrl.text = s.phoneNumber ?? '';
    if (s.price != null) _priceCtrl.text = '${s.price}';

    priceType = s.priceType.isNotEmpty ? s.priceType : 'fixed';
    allowComments = s.allowComments;
    allowMarketing = s.allowMarketing;
    allowNegotiationSwitch = priceType == 'negotiable';

    final methods = s.communicationMethods;
    chat = methods.contains('chat');
    whatsapp = methods.contains('whatsapp');
    phone = methods.contains('call') || methods.contains('phone');

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
    // بدون ضغط حالياً
    return file;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600),
    );
  }

  // اختيار صور متعددة مع احترام الحد الإجمالي (قديمة + جديدة <= 10)
  Future<void> _pickImages() async {
    final cubit = context.read<CarPartAdsCubit>();
    final existingCount = cubit.state.existingImageUrls.length;
    final remaining = 10 - existingCount - _picked.length;

    if (remaining <= 0) {
      _showError('لا يمكنك إضافة المزيد من الصور. الحد الأقصى 10 صور.');
      return;
    }

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (!mounted || images.isEmpty) return;

    var added = 0;
    for (final x in images) {
      if (added >= remaining) break;
      final file = File(x.path);
      if (!_isSupportedMedia(file)) {
        _showError('الملف ${p.basename(file.path)} ليس بصيغة مدعومة (png, jpg, mp4).');
        continue;
      }
      final finalFile = await _compressImageIfNeeded(file);
      _picked.add(finalFile);
      cubit.addImage(finalFile);
      added++;
    }

    if (added == 0 && remaining <= 0) {
      _showError('تم الوصول للحد الأقصى (10 صور)');
    }
    if (mounted) setState(() {});
  }

  void _updateComms(CarPartAdsCubit cubit) {
    final methods = <String>[];
    if (chat) methods.add('chat');
    if (whatsapp) methods.add('whatsapp');
    if (phone) methods.add('call');
    cubit.setCommunicationMethods(methods);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarPartAdsCubit>();
    final s = context.watch<CarPartAdsCubit>().state;

    return BlocListener<CarPartAdsCubit, CarPartAdsState>(
      listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
      listener: (context, state) {
        if (state.submitting) {
          final msg = state.isEditing ? 'جارٍ حفظ التغييرات...' : 'جارٍ إنشاء الإعلان...';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        } else if (state.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (state.isEditing) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التغييرات')));
            Navigator.pop(context, true); // لإعادة تحميل التفاصيل
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الإعلان بنجاح')));
            Navigator.pop(context);
            Navigator.pop(context);
          }
        } else if (state.error != null) {
          _showError(state.error!);
        }
      },
      child: Scaffold(
        // ✅ AppBar يظهر فقط في وضع التعديل
        appBar: s.isEditing
            ? AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title:  Text(
            'تعديل إعلان قطع غيار',
            style: TextStyles.font18Black500Weight,
          ),
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300),
            tooltip: 'رجوع',
          ),
        )
            : null,
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
                      // صور الشبكة القديمة (إن وجدت)
                      if (s.existingImageUrls.isNotEmpty) ...[
                        Text('الصور الحالية', style: TextStyles.font14DarkGray400Weight),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 90.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: s.existingImageUrls.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8.w),
                            itemBuilder: (_, i) {
                              final url = s.existingImageUrls[i];
                              return Stack(
                                children: [
                                  Container(
                                    width: 110.w,
                                    height: 82.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: const Color(0xFFE6E6E6)),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(url, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () => context.read<CarPartAdsCubit>().removeExistingImageAt(i),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.delete, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        verticalSpace(12),
                      ],

                      // قسم الوسائط (ملفات جديدة)
                      if (_picked.isEmpty)
                        _addMediaBox(onTap: _pickImages)
                      else
                        MediaGridPicker(
                          files: _picked,
                          onAdd: _pickImages,
                          onRemove: (i) {
                            cubit.removeImageAt(i);
                            setState(() => _picked.removeAt(i));
                          },
                          maxCount: 10,
                          title: 'الصور ومقاطع الفيديو',
                        ),
                      verticalSpace(16),

                      _field('عنوان الاعلان', _titleCtrl, hint: 'مثال: فلتر زيت أصلي', onChanged: cubit.setTitle),
                      verticalSpace(12),

                      _field('وصف العرض', _offerDescCtrl, hint: 'اكتب وصفًا للمنتج...', maxLines: 3, onChanged: cubit.setDescription),
                      verticalSpace(12),

                      // السعر
                      TextField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (v) => cubit.setPrice(num.tryParse(v.replaceAll(',', '').trim())),
                        decoration: InputDecoration(
                          labelText: 'السعر',
                          hintText: priceType == 'negotiable' ? 'لن يتم إرسال السعر (على السوم)' : 'مثال: 250',
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

                      _field('رقم الهاتف', _phoneCtrl, keyboardType: TextInputType.phone, onChanged: cubit.setPhoneNumber),
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

                      // زر الحفظ/النشر
                      BlocBuilder<CarPartAdsCubit, CarPartAdsState>(
                        buildWhen: (p, c) => p.submitting != c.submitting || p.isEditing != c.isEditing,
                        builder: (context, st) {
                          final btnText = st.submitting
                              ? (st.isEditing ? 'جارٍ الحفظ...' : 'جارٍ النشر...')
                              : (st.isEditing ? 'حفظ التغييرات' : 'نشر الاعلان');
                          return AbsorbPointer(
                            absorbing: st.submitting,
                            child: PrimaryButton(
                              text: btnText,
                              onPressed: () {
                                if (st.submitting) return;

                                // مزامنة نهائية قبل الإرسال
                                cubit
                                  ..setTitle(_titleCtrl.text)
                                  ..setDescription(_offerDescCtrl.text)
                                  ..setPhoneNumber(_phoneCtrl.text)
                                  ..setPrice(num.tryParse(_priceCtrl.text));

                                cubit.submit();
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
                'ندعم صيغ png, jpg, mp4 (حتى 10 ملفات إجمالاً)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
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