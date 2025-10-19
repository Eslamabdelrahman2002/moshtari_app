import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'category_item.dart';

class HomeCategoriesListView extends StatelessWidget {
  // ✨ UPDATE: Now receives the map of categories to display from the parent
  final Map<String, String> categoriesToShow;
  final Function(String? categoryKey) onCategorySelected;
  final String? selectedCategoryKey;

  const HomeCategoriesListView({
    super.key,
    required this.categoriesToShow,
    required this.onCategorySelected,
    this.selectedCategoryKey,
  });

  @override
  Widget build(BuildContext context) {
    // Add "All" at the beginning of the received list
    final displayCategories = {'الكل': 'الكل', ...categoriesToShow};
    final categoryKeys = displayCategories.keys.toList();

    return SizedBox(
      height: 45.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final key = categoryKeys[index];
          final name = displayCategories[key]!;

          final bool isSelected = (selectedCategoryKey ?? 'الكل') == key;

          return CategoryItem(
            name: name,
            isSelected: isSelected,
            onTap: () {
              if (key == 'الكل') {
                onCategorySelected(null);
              } else {
                onCategorySelected(key);
              }
            },
          );
        },
      ),
    );
  }
}