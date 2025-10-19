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

class TankerStep2Specs extends StatefulWidget {
  final VoidCallback onNext;
  const TankerStep2Specs({super.key, required this.onNext});

  @override
  State<TankerStep2Specs> createState() => _TankerStep2SpecsState();
}

class _TankerStep2SpecsState extends State<TankerStep2Specs> {
  String? _selectedSize = '18 طن';

  final List<String> _serviceOptions = const [
    'مياه','مواد بترولية','مواد كيميائية','زيوت','مواد غذائية سائلة','أخرى',
  ];
  final Set<String> _selectedServiceTypes = {};

  final List<String> _carTypes = const ['مرسيدس','فولفو','مان','سكانيا','إيفيكو','ايسوزو','هيونداي'];
  String? _selectedCarType;

  late final List<String> _modelYears =
  List.generate(20, (i) => (DateTime.now().year - i).toString());
  String? _selectedModel;

  final _plateNumbersController = TextEditingController();
  final _plateLettersController = TextEditingController();

  @override
  void dispose() {
    _plateNumbersController.dispose();
    _plateLettersController.dispose();
    super.dispose();
  }

  Widget _buildSizeButton(String text) {
    bool isSelected = _selectedSize == text;
    return Expanded(
      child: PrimaryButton(
        text: text,
        onPressed: () => setState(() => _selectedSize = text),
        backgroundColor: isSelected ? ColorsManager.primaryColor : ColorsManager.white,
        textColor: isSelected ? ColorsManager.white : ColorsManager.black,
        isOutlineButton: !isSelected,
        borderColor: isSelected ? ColorsManager.primaryColor : ColorsManager.dark200,
        height: 50.h,
        borderRadius: 12,
      ),
    );
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
                side: MaterialStateBorderSide.resolveWith((_) => BorderSide(color: ColorsManager.dark200)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              SizedBox(width: 8.w),
              Expanded(child: Text(text, style: textStyle, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
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

  Future<void> _openServiceTypesDialog() async {
    final tempSelected = Set<String>.from(_selectedServiceTypes);

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          content: SizedBox(
            width: 320.w,
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
                          if (checked) tempSelected.remove(o);
                          else tempSelected.add(o);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('إلغاء', style: TextStyles.font14Primary500Weight)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          content: SizedBox(
            width: 320.w,
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

    if (selected != null) setState(() => onSelected(selected));
  }

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
        Text('حجم الصهريج', style: TextStyles.font14Black500Weight),
        verticalSpace(8),
        Row(
          children: [
            _buildSizeButton('18 طن'),
            horizontalSpace(10),
            _buildSizeButton('32 طن'),
            horizontalSpace(10),
            _buildSizeButton('غير ذلك'),
          ],
        ),
        verticalSpace(16),

        _buildSelectorField(
          label: 'نوع خدمات الصهريج',
          placeholder: 'نوع خدمات الصهريج',
          value: _serviceTypesSummary,
          onTap: _openServiceTypesDialog,
        ),
        verticalSpace(16),

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

        Text('رقم اللوحة', style: TextStyles.font14Black500Weight),
        verticalSpace(8),
        Row(
          children: [
            Expanded(
              child: SecondaryTextFormField(
                label: 'رقم اللوحة بالأرقام',
                hint: '2455',
                controller: _plateNumbersController,
                isNumber: true,
                minHeight: 52.h,
                maxheight: 52.h,
              ),
            ),
            horizontalSpace(10),
            Expanded(
              child: SecondaryTextFormField(
                label: 'رقم اللوحة بالحروف',
                hint: 'ع ل س',
                controller: _plateLettersController,
                minHeight: 52.h,
                maxheight: 52.h,
              ),
            ),
          ],
        ),
        verticalSpace(32),

        PrimaryButton(
          text: 'التالي',
          onPressed: () {
            final servicesSummary = _selectedServiceTypes.isEmpty ? null : _selectedServiceTypes.join('، ');
            context.read<ServiceRegistrationCubit>().updateData((m) {
              m.tankerSize = _selectedSize;
              m.tankerServices = servicesSummary;

              m.vehicleType = _selectedCarType; // ماركة الشاحنة
              m.vehicleModel = _selectedModel;  // الموديل/السنة

              m.plateNumbers = _plateNumbersController.text.trim().isEmpty ? null : _plateNumbersController.text.trim();
              m.plateLetters = _plateLettersController.text.trim().isEmpty ? null : _plateLettersController.text.trim();
            });
            widget.onNext();
          },
        ),
        verticalSpace(32),
      ],
    );
  }
}