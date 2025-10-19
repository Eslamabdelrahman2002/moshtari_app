import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

class RealEstateAreaSelectorBottomSheetView extends StatefulWidget {
  const RealEstateAreaSelectorBottomSheetView({
    super.key,
    this.areas = const [],
    this.selectedAreaIds = const [],
    this.onSave,
  });

  final List<Map<String, dynamic>> areas; // [{id: 1, name: "حي النور"}]
  final List<int> selectedAreaIds;
  final VoidCallback? onSave;

  @override
  State<RealEstateAreaSelectorBottomSheetView> createState() =>
      _RealEstateAreaSelectorBottomSheetViewState();
}

class _RealEstateAreaSelectorBottomSheetViewState
    extends State<RealEstateAreaSelectorBottomSheetView> {
  List<int> selectedIds = [];

  @override
  void initState() {
    super.initState();
    selectedIds = List.from(widget.selectedAreaIds);
  }

  void toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w, top: 16.w, left: 16.w),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const MySvg(image: 'arrow-right')),
              const Spacer(),
              Text('الحي', style: TextStyles.font20Black500Weight),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          verticalSpace(24.h),
          Row(
            children: [
              Text('يمكنك أختيار اكثر من حي',
                  style: TextStyles.font14Dark500Weight),
            ],
          ),
          verticalSpace(24.h),
          SecondaryTextFormField(
            hint: 'ابحث بأسم الحي...',
            maxheight: 48.h,
            minHeight: 48.w,
            prefixIcon: 'search-normal',
            onChanged: (value) {
              // مجرد UI، هنا ممكن تعمل فلترة حسب value
            },
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.areas.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => MyDivider(height: 4.w),
              itemBuilder: (context, index) {
                final area = widget.areas[index];
                final id = area['id'] as int;
                final name = area['name'] as String;
                final isSelected = selectedIds.contains(id);

                return ListTile(
                  title: Row(
                    children: [
                      MySvg(
                          image: isSelected
                              ? 'tick-square-check'
                              : 'tick-square'),
                      horizontalSpace(8.w),
                      Text(name),
                    ],
                  ),
                  onTap: () => toggleSelection(id),
                );
              },
            ),
          ),
          SafeArea(
            child: NextButtonBar(
              title: 'حفظ',
              onPressed: () {
                widget.onSave?.call();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
