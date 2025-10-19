import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart'; // ✨ FIX: Import the correct model
import 'package:mushtary/features/home/ui/widgets/grid_view_item.dart';

class SimilarAds extends StatelessWidget {
  // ✨ FIX: Add a list to receive similar ads data
  final List<HomeAdModel> similarAds;

  const SimilarAds({super.key, required this.similarAds});

  @override
  Widget build(BuildContext context) {
    // ✨ FIX: Use ListView.builder to display items from the list dynamically
    return SizedBox(
      height: 185.h, // Provide a fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: similarAds.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.w : 8.w, // Add padding to the first item
              right: index == similarAds.length - 1 ? 16.w : 8.w, // Add padding to the last item
            ),
            child: SizedBox(
              width: 150.w,
              child: GridViewItem(
                // Pass the ad model to the item
                adModel: similarAds[index],
              ),
            ),
          );
        },
      ),
    );
  }
}