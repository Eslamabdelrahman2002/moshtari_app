import 'package:flutter/material.dart';
import 'package:mushtary/features/home/ui/widgets/home_list_view_item.dart';
import '../../data/models/home_data_model.dart';

class HomeListView extends StatelessWidget {
  final List<HomeAdModel>? ads;
  final HomeDataModel? data;
  final int? categoryId;
  final bool isLoading;

  const HomeListView({
    super.key,
    this.ads,
    this.data,
    this.categoryId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final List<HomeAdModel> items = ads ??
        (data != null && categoryId != null
            ? data!.adsByCategory(categoryId!)
            : <HomeAdModel>[]);

    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('لا توجد عناصر للعرض')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => HomeListViewItem(adModel: items[index]),
        childCount: items.length,
      ),
    );
  }
}