// lib/features/cars/logic/cubit/car_catalog_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../data/model/car_model.dart';
import '../../data/model/car_type.dart';

import '../../data/repo/car_catalog_repo.dart';
import 'car_catalog_state.dart';

class CarCatalogCubit extends Cubit<CarCatalogState> {
  final CarCatalogRepo _repo;

  CarCatalogCubit(this._repo) : super(const CarCatalogState());

  Future<void> loadBrands({int? preselectBrandId, int? preselectModelId, bool autoSelectFirst = true}) async {
    debugPrint('[Catalog DEBUG] Starting loadBrands...');
    emit(state.copyWith(brandsLoading: true, error: null));
    try {
      final brands = await _repo.fetchCarTypes();
      debugPrint('[Catalog DEBUG] Brands fetched: ${brands.length}');

      CarType? selected;
      if (preselectBrandId != null) {
        selected = brands.where((b) => b.id == preselectBrandId).cast<CarType?>().fold<CarType?>(null, (p, e) => e ?? p);
      }
      selected ??= (autoSelectFirst && brands.isNotEmpty) ? brands.first : null;

      debugPrint('[Catalog DEBUG] Selected Brand: ${selected?.name}');

      emit(state.copyWith(
        brandsLoading: false,
        brands: brands,
        selectedBrand: selected,
      ));

      if (selected != null) {
        await loadModels(selected.id, preselectModelId: preselectModelId, autoSelectFirst: autoSelectFirst);
      }
    } catch (e) {
      debugPrint('[Catalog ERROR] Failed to load brands: $e');
      emit(state.copyWith(brandsLoading: false, error: 'تعذر جلب الماركات'));
    }
  }

  Future<void> loadModels(int brandId, {int? preselectModelId, bool autoSelectFirst = true}) async {
    debugPrint('[Catalog DEBUG] Starting loadModels for ID: $brandId');
    emit(state.copyWith(modelsLoading: true, models: const [], selectedModel: null, error: null));
    try {
      final models = await _repo.fetchModels(brandId);
      debugPrint('[Catalog DEBUG] Models fetched: ${models.length}');

      CarModel? selectedModel;
      if (preselectModelId != null) {
        selectedModel = models.where((m) => m.id == preselectModelId).cast<CarModel?>().fold<CarModel?>(null, (p, e) => e ?? p);
      }
      selectedModel ??= (autoSelectFirst && models.isNotEmpty) ? models.first : null;

      emit(state.copyWith(modelsLoading: false, models: models, selectedModel: selectedModel));
    } catch (e) {
      debugPrint('[Catalog ERROR] Failed to load models: $e');
      emit(state.copyWith(modelsLoading: false, error: 'تعذر جلب الموديلات'));
    }
  }

  void selectBrand(CarType brand) {
    debugPrint('[Catalog DEBUG] Selected Brand: ${brand.name}');
    emit(state.copyWith(selectedBrand: brand, selectedModel: null));
    loadModels(brand.id);
  }

  void selectModel(CarModel model) {
    debugPrint('[Catalog DEBUG] Selected Model: ${model.displayName}');
    emit(state.copyWith(selectedModel: model));
  }
}