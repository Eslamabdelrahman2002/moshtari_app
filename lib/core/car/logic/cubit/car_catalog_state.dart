// lib/features/cars/logic/cubit/car_catalog_state.dart

import '../../data/model/car_model.dart';
import '../../data/model/car_type.dart';


class CarCatalogState {
  final bool brandsLoading;
  final bool modelsLoading;
  final List<CarType> brands;
  final List<CarModel> models;
  final CarType? selectedBrand;
  final CarModel? selectedModel;
  final String? error;

  const CarCatalogState({
    this.brandsLoading = false,
    this.modelsLoading = false,
    this.brands = const [],
    this.models = const [],
    this.selectedBrand,
    this.selectedModel,
    this.error,
  });

  CarCatalogState copyWith({
    bool? brandsLoading,
    bool? modelsLoading,
    List<CarType>? brands,
    List<CarModel>? models,
    CarType? selectedBrand,
    CarModel? selectedModel,
    String? error,
  }) {
    return CarCatalogState(
      brandsLoading: brandsLoading ?? this.brandsLoading,
      modelsLoading: modelsLoading ?? this.modelsLoading,
      brands: brands ?? this.brands,
      models: models ?? this.models,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: selectedModel ?? this.selectedModel,
      error: error,
    );
  }
}