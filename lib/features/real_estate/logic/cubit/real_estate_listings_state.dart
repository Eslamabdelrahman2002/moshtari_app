import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';

abstract class RealEstateListingsState {}

class ListingsInitial extends RealEstateListingsState {
  final RealEstateListingsFilter filter;
  ListingsInitial(this.filter);
}

class ListingsLoading extends RealEstateListingsState {}

class ListingsEmpty extends RealEstateListingsState {}

class ListingsError extends RealEstateListingsState {
  final String message;
  ListingsError(this.message);
}

class ListingsLoaded extends RealEstateListingsState {
  final List<RealEstateListModel> items;
  final RealEstateListingsFilter filter;
  final bool isGrid;

  ListingsLoaded(
      this.items, {
        required this.filter,
        required this.isGrid,
      });

  ListingsLoaded copyWith({
    List<RealEstateListModel>? items,
    RealEstateListingsFilter? filter,
    bool? isGrid,
  }) {
    return ListingsLoaded(
      items ?? this.items,
      filter: filter ?? this.filter,
      isGrid: isGrid ?? this.isGrid,
    );
  }
}