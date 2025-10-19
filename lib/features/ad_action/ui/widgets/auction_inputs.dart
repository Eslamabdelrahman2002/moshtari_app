import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class OptionListCard extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final double? height;

  const OptionListCard({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: height != null ? BoxConstraints(minHeight: height!) : null,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorsManager.dark200, width: 1.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h, right: 4.w),
              child: Text(title, style: TextStyles.font14Dark500Weight),
            ),
          ...options.map((text) {
            final isSel = text == selected;
            return _RadioRow(
              text: text,
              selected: isSel,
              onTap: () => onChanged(text),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final bool selected;
  final String text;
  final VoidCallback onTap;
  const _RadioRow({required this.selected, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: selected
                    ? TextStyles.font14Blue500Weight.copyWith(
                    color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)
                    : TextStyles.font14Black500Weight,
              ),
            ),
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? ColorsManager.primaryColor : ColorsManager.dark300,
                    width: 1.8),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? ColorsManager.primaryColor : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterField extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterField({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: ColorsManager.dark200),
          ),
          child: Row(
            children: [
              _squareBtn(icon: 'ic_plus', onTap: onIncrement),
              Expanded(
                child: Center(
                  child: Text(value.toString(), style: TextStyles.font16Black500Weight),
                ),
              ),
              _squareBtn(icon: 'ic_minus', onTap: onDecrement),
            ],
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _squareBtn({required String icon, required VoidCallback onTap}) {
    return SizedBox(
      width: 48.w,
      height: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Center(child: MySvg(image: icon, width: 16.w, height: 16.h)),
        ),
      ),
    );
  }
}

class NumberCounterField extends StatelessWidget {
  final String label;
  final int value;
  final int step;
  final int min;
  final ValueChanged<int> onChanged;

  const NumberCounterField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 100,
    this.min = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CounterField(
      label: label,
      value: value,
      onIncrement: () => onChanged(value + step),
      onDecrement: () => onChanged(value - step < min ? min : value - step),
    );
  }
}

class SegmentedTwo extends StatelessWidget {
  final String left; // إيجار أو لا
  final String right; // بيع أو نعم
  final String selected;
  final ValueChanged<String> onChange;

  const SegmentedTwo({
    super.key,
    required this.left,
    required this.right,
    required this.selected,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = selected == left;
    return Row(
      children: [
        Expanded(child: _segButton(text: left, filled: isLeft, onTap: () => onChange(left))),
        SizedBox(width: 8.w),
        Expanded(child: _segButton(text: right, filled: !isLeft, onTap: () => onChange(right))),
      ],
    );
  }

  Widget _segButton({required String text, required bool filled, required VoidCallback onTap}) {
    return SizedBox(
      height: 44.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? ColorsManager.primaryColor : Colors.white,
          foregroundColor: filled ? Colors.white : Colors.black,
          side: BorderSide(color: filled ? ColorsManager.primaryColor : ColorsManager.dark200, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}