import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_filtering_chip.dart';
import 'package:mushtary/features/real_estate/data/model/mock_data.dart';

class RealEstateFilteringChipsBar extends StatefulWidget {
  const RealEstateFilteringChipsBar({
    super.key,
  });

  @override
  State<RealEstateFilteringChipsBar> createState() =>
      _RealEstateFilteringChipsBarState();
}

class _RealEstateFilteringChipsBarState
    extends State<RealEstateFilteringChipsBar> {
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: mockCategories.length,
      itemBuilder: (context, index) {
        final category = mockCategories[index];
        return Padding(
          padding: EdgeInsetsDirectional.only(end: 16.w),
          child: RealEstateFilteringChip(
            title: category.name,
            // isSelected: category.documentRef == selectedCategory,
            onTap: () {
              setState(() {
                // selectedCategory = category.documentRef;
              });
            },
          ),
        );
      },
    );
  }
}
