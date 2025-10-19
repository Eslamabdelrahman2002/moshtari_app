import '../../data/model/laborer_type_model.dart';

class LaborerTypesState {
  final bool loading;
  final List<LaborerType> types;
  final String? error;

  const LaborerTypesState({
    this.loading = false,
    this.types = const [],
    this.error,
  });

  LaborerTypesState copyWith({
    bool? loading,
    List<LaborerType>? types,
    String? error,
  }) {
    return LaborerTypesState(
      loading: loading ?? this.loading,
      types: types ?? this.types,
      error: error,
    );
  }
}