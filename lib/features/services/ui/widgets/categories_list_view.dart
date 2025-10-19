import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/features/home/ui/widgets/category_item.dart';
import 'package:mushtary/features/real_estate/data/model/mock_data.dart';

class CategoriesListView extends StatefulWidget {
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel>? onSelect;

  const CategoriesListView({super.key, required this.categories, this.onSelect});

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 45.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final c = widget.categories[index];
            return CategoryItem(
              name: c.name,
              isSelected: selectedCategoryIndex == index,
              onTap: () {
                setState(() => selectedCategoryIndex = index); // تحديث الـ UI
                widget.onSelect?.call(c);
              },
            );
          },
        ),
      ),
    );
  }
}