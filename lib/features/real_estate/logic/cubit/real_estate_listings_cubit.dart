// file: real_estate_listings_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';
import 'package:mushtary/features/real_estate/data/repo/real_estate_listings_repo.dart';
import 'real_estate_listings_state.dart';

class RealEstateListingsCubit extends Cubit<RealEstateListingsState> {
  final RealEstateListingsRepo _repo;

  // الحالة الافتراضية عند البداية: عرض "الإعلانات"
  RealEstateListingsFilter _filter =
  const RealEstateListingsFilter(type: 'ad');
  bool _isGrid = true;

  RealEstateListingsCubit(this._repo)
      : super(
    ListingsInitial(
      const RealEstateListingsFilter(type: 'ad'),
      listings: const [], // ✅ إضافة listings فارغة
    ),
  );

  RealEstateListingsFilter get filter => _filter;
  bool get isGrid => _isGrid;

  /// تحميل أول بيانات بعد فتح الصفحة
  Future<void> init({String type = 'ad'}) async {
    _filter = _filter.copyWith(type: type, page: 1);
    await _fetch();
  }

  /// التبديل بين تبويب "الإعلانات" و"الطلبات"
  Future<void> switchTab(String type) async {
    _filter = _filter.copyWith(type: type, page: 1);
    await _fetch();
  }

  /// تطبيق فلاتر النوع والغرض (بيع / إيجار)
  Future<void> applyCombo({
    String? realEstateType,
    String? requestType,
  }) async {
    // 🧠 تعديل الغرض تلقائيًا عند تبويب الطلبات
    String? adjustedPurpose = requestType;
    if (_filter.type == 'request') {
      // الطلب المقابل للبيع هو "شراء"
      if (requestType == 'sell') {
        adjustedPurpose = 'buy';
      }
    }

    _filter = _filter.copyWith(
      realEstateType: realEstateType,
      requestType: adjustedPurpose,
      page: 1,
    );

    await _fetch();
  }

  /// فلترة حسب المدينة
  Future<void> applyCity(int? cityId) async {
    _filter = _filter.copyWith(cityId: cityId, page: 1);
    await _fetch();
  }

  /// تغيير طريقة العرض (شبكة أو قائمة)
  Future<void> setLayout(bool grid) async {
    _isGrid = grid;
    final s = state;
    if (s is ListingsLoaded) {
      emit(s.copyWith(isGrid: grid)); // ✅ يعمل الآن مع listings
    }
  }

  /// الوظيفة الأساسية لجلب القوائم من الريبو
  Future<void> _fetch() async {
    emit(ListingsLoading());
    try {
      // 🛰️ جلب البيانات مع جميع الفلاتر النشطة
      final List<RealEstateListModel> fetchedListings = // ✅ تغيير الاسم للوضوح
      await _repo.getListings(_filter);

      // 🧾 طباعة الفلتر في الكونسول وقت التطوير (اختياري)
      // print('➡️ Fetching listings with params: ${_filter.toQuery()}');

      if (fetchedListings.isEmpty) {
        emit(ListingsEmpty());
      } else {
        emit(
          ListingsLoaded(
            fetchedListings, // ✅ تغيير من items إلى listings
            filter: _filter,
            isGrid: _isGrid,
          ),
        );
      }
    } catch (e) {
      emit(ListingsError(e.toString()));
    }
  }
}