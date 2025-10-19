import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_ad_app_bar.dart';
import 'package:mushtary/features/create_ad/ui/widgets/photo_picker.dart';
import 'package:mushtary/features/create_ad/ui/widgets/photo_video_item.dart';
import 'logic/cubit/car_part_ads_cubit.dart';
import 'logic/cubit/car_part_ads_state.dart';

class CarPartCreateAdScreen extends StatefulWidget {
  const CarPartCreateAdScreen({super.key});

  @override
  State<CarPartCreateAdScreen> createState() => _CarPartCreateAdScreenState();
}

class _CarPartCreateAdScreenState extends State<CarPartCreateAdScreen> {
  final _titleCtrl = TextEditingController();
  final _partNameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _brandIdCtrl = TextEditingController();
  final _modelsCtrl = TextEditingController(); // comma-separated: 2021,2022
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+966');

  final List<File> _picked = [];

  String condition = 'used';
  String priceType = 'fixed';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _partNameCtrl.dispose();
    _priceCtrl.dispose();
    _brandIdCtrl.dispose();
    _modelsCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarPartAdsCubit>();

    Future<void> pickImages() async {
      final picker = PhotoPicker(context);
      final files = await picker.pickMedia();
      if (!mounted) return;
      for (final f in files) {
        _picked.add(f);
        cubit.addImage(f);
      }
      setState(() {});
    }

    return BlocListener<CarPartAdsCubit, CarPartAdsState>(
      listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
      listener: (context, state) {
        if (state.submitting) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جارٍ إنشاء الإعلان...')));
        } else if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الإعلان بنجاح')));
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Row(children: [
                MySvg(image: "arrow_right",color: ColorsManager.black,),
                Text("إنشاء إعلان")
              ],),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('إنشاء إعلان - قطع غيار', style: TextStyles.font20Black500Weight),
                      verticalSpace(16),
                      _field('عنوان الإعلان', _titleCtrl, onChanged: cubit.setTitle),
                      verticalSpace(12),
                      _field('اسم القطعة', _partNameCtrl, onChanged: cubit.setPartName),
                      verticalSpace(12),
                      _field('الماركة (brand_id)', _brandIdCtrl, keyboardType: TextInputType.number, onChanged: (v) => cubit.setBrandId(int.tryParse(v))),
                      verticalSpace(12),
                      _field('الموديلات المدعومة (مثال: 2021,2022)', _modelsCtrl, onChanged: (v) {
                        final list = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                        cubit.setSupportedModels(list);
                      }),
                      verticalSpace(12),
                      _field('الوصف', _descCtrl, maxLines: 3, onChanged: cubit.setDescription),
                      verticalSpace(12),
                      Row(
                        children: [
                          Expanded(child: _field('السعر', _priceCtrl, keyboardType: TextInputType.number, onChanged: (v) => cubit.setPrice(num.tryParse(v)))),
                          horizontalSpace(12),
                          Expanded(
                            child: _segment(
                              title: 'نوع السعر',
                              items: const ['fixed', 'negotiable', 'auction'],
                              value: priceType,
                              onSelect: (v) {
                                setState(() => priceType = v);
                                cubit.setPriceType(v);
                              },
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(12),
                      _segment(
                        title: 'الحالة',
                        items: const ['new', 'used'],
                        value: condition,
                        onSelect: (v) {
                          setState(() => condition = v);
                          cubit.setCondition(v);
                        },
                      ),
                      verticalSpace(12),
                      _field('رقم الجوال (اختياري)', _phoneCtrl, keyboardType: TextInputType.phone, onChanged: cubit.setPhoneNumber),
                      verticalSpace(16),
                      Text('الصور ومقاطع الفيديو', style: TextStyles.font16Black500Weight),
                      verticalSpace(12),
                      _picked.isEmpty
                          ? OutlinedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة صور/فيديو'),
                      )
                          : SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _picked.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return PhotoVideoItem(
                              imageFile: _picked[index],
                              remove: () {
                                cubit.removeImageAt(index);
                                setState(() => _picked.removeAt(index));
                              },
                            );
                          },
                        ),
                      ),
                      verticalSpace(24),
                      MyButton(
                        label: 'نشر الإعلان',
                        onPressed: () {
                          cubit.submit();
                        },
                        backgroundColor: ColorsManager.primary500,
                      ),
                      verticalSpace(24),
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

  Widget _field(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
        int maxLines = 1,
        Function(String)? onChanged,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _segment({
    required String title,
    required List<String> items,
    required String value,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyles.font16Dark500400Weight),
        verticalSpace(8),
        Wrap(
          spacing: 8,
          children: items.map((e) {
            final selected = e == value;
            return ChoiceChip(
              label: Text(e),
              selected: selected,
              onSelected: (_) => onSelect(e),
            );
          }).toList(),
        ),
      ],
    );
  }
}