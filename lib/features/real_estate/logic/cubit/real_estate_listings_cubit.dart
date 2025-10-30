// file: real_estate_listings_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';
// import 'package:mushtary/features/real_estate/data/model/real_estate_listing_item.dart'; // ❌ تم إزالة الاستيراد
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart'; // ✅ افتراض أن هذا هو RealEstateListModel
import 'package:mushtary/features/real_estate/data/repo/real_estate_listings_repo.dart';
import 'real_estate_listings_state.dart';

class RealEstateListingsCubit extends Cubit<RealEstateListingsState> {
  final RealEstateListingsRepo _repo;
  RealEstateListingsFilter _filter = const RealEstateListingsFilter(type: 'ad');
  bool _isGrid = true;

  RealEstateListingsCubit(this._repo) : super(ListingsInitial(const RealEstateListingsFilter(type: 'ad')));

  RealEstateListingsFilter get filter => _filter;
  bool get isGrid => _isGrid;

  Future<void> init({String type = 'ad'}) async {
    _filter = _filter.copyWith(type: type, page: 1);
    await _fetch();
  }

  Future<void> switchTab(String type) async {
    _filter = _filter.copyWith(type: type, page: 1);
    await _fetch();
  }

  Future<void> applyCombo({String? realEstateType, String? requestType}) async {
    _filter = _filter.copyWith(realEstateType: realEstateType, requestType: requestType, page: 1);
    await _fetch();
  }

  Future<void> applyCity(int? cityId) async {
    _filter = _filter.copyWith(cityId: cityId, page: 1);
    await _fetch();
  }

  Future<void> setLayout(bool grid) async {
    _isGrid = grid;
    final s = state;
    if (s is ListingsLoaded) {
      // ✅ استخدام copyWith لتحديث isGrid
      emit(s.copyWith(isGrid: grid));
    }
  }

  Future<void> _fetch() async {
    emit(ListingsLoading());
    try {
      // ✅ FIX: تغيير النوع المتوقع من الريبو
      final List<RealEstateListModel> items = await _repo.getListings(_filter).then((list) => list.cast<RealEstateListModel>());

      if (items.isEmpty) {
        emit(ListingsEmpty());
      } else {
        // ✅ FIX: تمرير القائمة بالنوع الصحيح
        emit(ListingsLoaded(items, filter: _filter, isGrid: _isGrid));
      }
    } catch (e) {
      emit(ListingsError(e.toString()));
    }
  }
}