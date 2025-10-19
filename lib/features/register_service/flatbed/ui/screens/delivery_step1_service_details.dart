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

class DeliveryStep1ServiceDetails extends StatefulWidget {
  final VoidCallback onNext;
  const DeliveryStep1ServiceDetails({super.key, required this.onNext});

  @override
  State<DeliveryStep1ServiceDetails> createState() => _DeliveryStep1ServiceDetailsState();
}

class _DeliveryStep1ServiceDetailsState extends State<DeliveryStep1ServiceDetails> {
  // (سطحه / تريلا)
  String _selectedVehicleType = 'سطحه';

  // نوع خدمات السطحة (متعدد)
  final List<String> _serviceOptions = const [
    'مقطورة',
    'نقل كامل',
    'نصف نقل',
    'ونش',
  ];
  final Set<String> _selectedServiceTypes = {};

  // نوع السيارة (مفرد)
  final List<String> _carTypes = const [
    'سطحة صغيرة',
    'سطحة متوسطة',
    'سطحة كبيرة',
    'تريلا',
    'ونش',
  ];
  String? _selectedCarType;

  // الموديل (سنة) (مفرد)
  late final List<String> _modelYears =
  List.generate(12, (i) => (DateTime.now().year - i).toString());
  String? _selectedModel;

  // رقم اللوحة
  final _plateController = TextEditingController();

  // مقاسات الديالوج الصغيرة + أقصى ارتفاع للّست
  double get _dialogWidth => 320.w;       // عرض صغير
  double get _dialogMaxHeight => 220.h;   // ارتفاع صغير + Scroll

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  // زر اختيار نوع المركبة
  Widget _buildVehicleTypeButton(String type) {
    bool isSelected = _selectedVehicleType == type;
    return Expanded(
      child: PrimaryButton(
        text: type,
        onPressed: () => setState(() => _selectedVehicleType = type),
        backgroundColor: isSelected ? ColorsManager.primaryColor : ColorsManager.white,
        textColor: isSelected ? ColorsManager.white : ColorsManager.black,
        isOutlineButton: !isSelected,
        borderColor: ColorsManager.dark200,
        height: 52.h,
        borderRadius: 12.r,
      ),
    );
  }

  // حقل اختيار عام (Container + سهم) يفتح الديالوج
  Widget _buildSelectorField({
    required String label,
    required String placeholder,
    required String? value,
    required VoidCallback onTap,
  }) {
    final bool hasValue = value != null && value!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(8),
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

  // عنصر صف (Checkbox يمين + نص)
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  text,
                  style: textStyle,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // حاوية القائمة Scrollable (أبيض + حدود + فواصل)
  Widget _buildStyledListScrollable({
    required int itemCount,
    required Widget Function(int index) itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.white,
        border: Border.all(color: ColorsManager.dark200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      constraints: BoxConstraints(maxHeight: _dialogMaxHeight),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          separatorBuilder: (_, __) =>
              Divider(height: 1, thickness: 1, color: ColorsManager.dark200),
          itemBuilder: (context, index) => itemBuilder(index),
        ),
      ),
    );
  }

  // Dialog: متعدد الاختيار — نوع خدمات السطحة
  Future<void> _openServiceTypesDialog() async {
    final tempSelected = Set<String>.from(_selectedServiceTypes);

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          content: SizedBox(
            width: _dialogWidth,
            child: StatefulBuilder(
              builder: (context, setInner) {
                return _buildStyledListScrollable(
                  itemCount: _serviceOptions.length,
                  itemBuilder: (i) {
                    final o = _serviceOptions[i];
                    final checked = tempSelected.contains(o);
                    return _buildListRow(
                      text: o,
                      checked: checked,
                      onTap: () {
                        setInner(() {
                          if (checked) {
                            tempSelected.remove(o);
                          } else {
                            tempSelected.add(o);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء', style: TextStyles.font14Primary500Weight),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedServiceTypes
                    ..clear()
                    ..addAll(tempSelected);
                });
                Navigator.of(context).pop();
              },
              child: Text('تم', style: TextStyles.font14Primary500Weight),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog: اختيار مفرد (نوع السيارة / الموديل)
  Future<void> _openSingleSelectDialog({
    required String title,
    required List<String> options,
    required String? current,
    required void Function(String value) onSelected,
  }) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          content: SizedBox(
            width: _dialogWidth,
            child: _buildStyledListScrollable(
              itemCount: options.length,
              itemBuilder: (i) {
                final o = options[i];
                final checked = current == o;
                return _buildListRow(
                  text: o,
                  checked: checked,
                  onTap: () => Navigator.of(context).pop(o),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() => onSelected(selected));
    }
  }

  // تلخيص الخدمات المختارة
  String? get _serviceTypesSummary {
    if (_selectedServiceTypes.isEmpty) return null;
    final list = _selectedServiceTypes.toList();
    if (list.length <= 2) return list.join('، ');
    return 'تم اختيار ${list.length} عناصر';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text('حجم السطحه', style: TextStyles.font14DarkGray400Weight),
        verticalSpace(8),
        Row(
          children: [
            _buildVehicleTypeButton('سطحه'),
            horizontalSpace(16),
            _buildVehicleTypeButton('تريلا'),
          ],
        ),
        verticalSpace(16),

        // نوع خدمات السطحة — Container يفتح Dialog
        _buildSelectorField(
          label: 'نوع خدمات السطحة',
          placeholder: 'حدد نوع خدمات السطحة',
          value: _serviceTypesSummary,
          onTap: _openServiceTypesDialog,
        ),
        verticalSpace(16),

        // نوع السيارة — Container يفتح Dialog
        _buildSelectorField(
          label: 'نوع السيارة',
          placeholder: 'حدد نوع السيارة',
          value: _selectedCarType,
          onTap: () => _openSingleSelectDialog(
            title: 'نوع السيارة',
            options: _carTypes,
            current: _selectedCarType,
            onSelected: (v) => _selectedCarType = v,
          ),
        ),
        verticalSpace(16),

        // الموديل — Container يفتح Dialog
        _buildSelectorField(
          label: 'الموديل',
          placeholder: 'حدد الموديل',
          value: _selectedModel,
          onTap: () => _openSingleSelectDialog(
            title: 'الموديل',
            options: _modelYears,
            current: _selectedModel,
            onSelected: (v) => _selectedModel = v,
          ),
        ),
        verticalSpace(16),

        // رقم اللوحة
        SecondaryTextFormField(
          label: 'رقم اللوحة',
          hint: '**** **** ****',
          controller: _plateController,
          maxLines: 1,
          minHeight: 52.h,
          maxheight: 52.h,
        ),
        verticalSpace(32),

        // التالي: حفظ في Cubit ثم الانتقال
        PrimaryButton(
          text: 'التالي',
          onPressed: () {
            final servicesSummary = _selectedServiceTypes.isEmpty
                ? null
                : _selectedServiceTypes.join('، ');

            context.read<ServiceRegistrationCubit>().updateData((m) {
              // نخزن نوع المركبة المختار (سطحه/تريلا)
              m.vehicleType = _selectedVehicleType;

              // السنة (الموديل)
              m.vehicleModel = _selectedModel;

              // وصف إضافي: نوع السيارة + الخدمات المختارة
              final parts = <String>[];
              if (_selectedCarType != null) parts.add('نوع السيارة: $_selectedCarType');
              if (servicesSummary != null) parts.add('الخدمات: $servicesSummary');
              m.cargoDescription = parts.isEmpty ? null : parts.join(' | ');

              // رقم اللوحة
              final plate = _plateController.text.trim();
              m.vehiclePlateNumber = plate.isEmpty ? null : plate;
            });

            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}