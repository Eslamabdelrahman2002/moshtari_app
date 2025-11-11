// file: real_estate_listings_state.dart

import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';

abstract class RealEstateListingsState {}

class ListingsInitial extends RealEstateListingsState {
  final RealEstateListingsFilter filter;
  final List<RealEstateListModel> listings; // ✅ تغيير من items إلى listings

  ListingsInitial(this.filter, {this.listings = const []}); // ✅ افتراضي فارغ
}

class ListingsLoading extends RealEstateListingsState {}

class ListingsEmpty extends RealEstateListingsState {}

class ListingsError extends RealEstateListingsState {
  final String message;
  ListingsError(this.message);
}

class ListingsLoaded extends RealEstateListingsState {
  final List<RealEstateListModel> listings; // ✅ تغيير من items إلى listings
  final RealEstateListingsFilter filter;
  final bool isGrid;

  ListingsLoaded(
      this.listings, { // ✅ تغيير من items إلى listings
        required this.filter,
        required this.isGrid,
      });

  ListingsLoaded copyWith({
    List<RealEstateListModel>? listings, // ✅ تغيير من items إلى listings
    RealEstateListingsFilter? filter,
    bool? isGrid,
  }) {
    return ListingsLoaded(
      listings ?? this.listings, // ✅ تغيير من items إلى listings
      filter: filter ?? this.filter,
      isGrid: isGrid ?? this.isGrid,
    );
  }
}