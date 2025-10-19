// lib/features/work_with_us/ui/screens/transport_step2_details.dart

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

class TransportStep2Details extends StatefulWidget {
  final VoidCallback onNext;
  const TransportStep2Details({super.key, required this.onNext});

  @override
  State<TransportStep2Details> createState() => _TransportStep2DetailsState();
}

class _TransportStep2DetailsState extends State<TransportStep2Details> {
  String? selectedMake;
  String? selectedModel;

  final _plateController = TextEditingController();
  final _cargoController = TextEditingController();

  final List<String> carMakes = const [
    'تويوتا','هيونداي','نيسان','كيا','شفروليه',
    'فورد','مرسيدس','بي ام دبليو','هوندا','مازدا',
    'جيلي','شانجان','ام جي',
  ];

  final Map<String, List<String>> carModels = const {
    'تويوتا': ['يارس','كورولا','كامري','هايلكس','لاندكروزر'],
    'هيونداي': ['أكسنت','النترا','سوناتا','توسان','كريتا'],
    'نيسان': ['صني','التيما','باترول','فتيارا'],
    'كيا': ['بيكانتو','سيراتو','سبورتاج','سورينتو'],
    'شفروليه': ['كروز','ماليبو','تاهو','سلفرادو'],
    'فورد': ['فوكس','فيوجن','اكسبلورر','اف 150'],
    'مرسيدس': ['C-Class','E-Class','GLC','GLE'],
    'بي ام دبليو': ['3 Series','5 Series','X3','X5'],
    'هوندا': ['سيفيك','أكورد','CR-V'],
    'مازدا': ['مازدا 3','مازدا 6','CX-5'],
    'جيلي': ['الريان','كولراي','ازكارا'],
    'شانجان': ['السفن','CS35','CS75'],
    'ام جي': ['MG5','RX5','ZS'],
  };

  @override
  void dispose() {
    _plateController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Widget _buildSelectorField({
    required String label,
    required String placeholder,
    required String? value,
    required VoidCallback onTap,
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
                    style: TextStyles.font14DarkGray400Weight,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const MySvg(image: 'arrow-down', width: 18, height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListRow({
    required String text,
    required bool checked,
    required VoidCallback onTap,
  }) {
    final textStyle = checked
        ? TextStyles.font14Black500Weight.copyWith(color: ColorsManager.primaryColor)
        : TextStyles.font14Black500Weight;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: (_) => onTap(),
                checkColor: ColorsManager.white,
                activeColor: ColorsManager.primaryColor,
                side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(color: ColorsManager.dark200),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(text, style: textStyle, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledListScrollable({
    required int itemCount,
    required Widget Function(int index) itemBuilder,
    double maxHeight = 400,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.white,
        border: Border.all(color: ColorsManager.dark200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      constraints: BoxConstraints(maxHeight: maxHeight.h),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          separatorBuilder: (_, __) => Divider(height: 1, thickness: 1, color: ColorsManager.dark200),
          itemBuilder: (context, index) => itemBuilder(index),
        ),
      ),
    );
  }

  Future<void> _openMakeDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          content: SizedBox(
            width: 320.w,
            child: _buildStyledListScrollable(
              itemCount: carMakes.length,
              itemBuilder: (i) {
                final make = carMakes[i];
                final checked = selectedMake == make;
                return _buildListRow(
                  text: make,
                  checked: checked,
                  onTap: () => Navigator.of(context).pop(make),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedMake = selected;
        selectedModel = null;
      });
    }
  }

  Future<void> _openModelDialog() async {
    if (selectedMake == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر نوع السيارة أولاً')));
      return;
    }
    final models = carModels[selectedMake!] ?? const <String>[];
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          content: SizedBox(
            width: 320.w,
            child: _buildStyledListScrollable(
              itemCount: models.length,
              itemBuilder: (i) {
                final m = models[i];
                final checked = selectedModel == m;
                return _buildListRow(
                  text: m,
                  checked: checked,
                  onTap: () => Navigator.of(context).pop(m),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() => selectedModel = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectorField(
          label: 'نوع السيارة',
          placeholder: 'حدد نوع السيارة',
          value: selectedMake,
          onTap: _openMakeDialog,
        ),
        verticalSpace(16),

        _buildSelectorField(
          label: 'الموديل',
          placeholder: 'حدد الموديل',
          value: selectedModel,
          onTap: _openModelDialog,
        ),
        verticalSpace(16),

        SecondaryTextFormField(
          label: 'رقم اللوحة',
          hint: '**** **** ****',
          controller: _plateController,
          maxLines: 1,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(16),

        SecondaryTextFormField(
          label: 'وصف نوع الحمولة التي يمكن نقلها',
          hint: 'وصف نوع الحمولة التي يمكن نقلها',
          controller: _cargoController,
          maxLines: 4,
          minHeight: 120.h,
          maxheight: 120.h,
        ),
        verticalSpace(32),

        PrimaryButton(
          text: 'التالي',
          onPressed: () {
            context.read<ServiceRegistrationCubit>().updateData((m) {
              m.vehicleType = selectedMake;     // الماركة
              m.vehicleModel = selectedModel;   // الموديل
              m.vehiclePlateNumber = _plateController.text.trim().isEmpty
                  ? null
                  : _plateController.text.trim();
              m.cargoDescription = _cargoController.text.trim().isEmpty
                  ? null
                  : _cargoController.text.trim();
            });
            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}