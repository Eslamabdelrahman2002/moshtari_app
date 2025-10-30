// file: real_estate_listings_state.dart

// import 'package:mushtary/features/real_estate/data/model/real_estate_listing_item.dart'; // ❌ تم إزالة الاستيراد
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart'; // ✅ استيراد النموذج الصحيح
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';

abstract class RealEstateListingsState {}

class ListingsInitial extends RealEstateListingsState {
  final RealEstateListingsFilter filter;
  ListingsInitial(this.filter);
}

class ListingsLoading extends RealEstateListingsState {}

class ListingsLoaded extends RealEstateListingsState {
  // ✅ FIX: استخدام RealEstateListModel بدلاً من RealEstateListingItem
  final List<RealEstateListModel> items;
  final RealEstateListingsFilter filter;
  final bool isGrid;

  ListingsLoaded(this.items, {required this.filter, required this.isGrid});

  ListingsLoaded copyWith({
    List<RealEstateListModel>? items, // ✅ FIX: تغيير نوع القائمة في copyWith
    RealEstateListingsFilter? filter,
    bool? isGrid,
  }) {
    return ListingsLoaded(items ?? this.items, filter: filter ?? this.filter, isGrid: isGrid ?? this.isGrid);
  }
}

class ListingsEmpty extends RealEstateListingsState {}

class ListingsError extends RealEstateListingsState {
  final String message;
  ListingsError(this.message);
}