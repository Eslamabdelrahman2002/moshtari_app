import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/services/data/repo/laborer_types_repo.dart';
import 'laborer_type_state.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class LaborerTypesCubit extends Cubit<LaborerTypesState> {
  final LaborerTypesRepo repo;
  LaborerTypesCubit(this.repo) : super(const LaborerTypesState());

  Future<void> fetch() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.fetch();
      debugPrint('API Fetched Laborer Types: ${data.length} items');
      if (data.isNotEmpty) {
        debugPrint('First Type: ID=${data.first.id}, NameAr=${data.first.nameAr}, NameEn=${data.first.nameEn}');
      } else {
        debugPrint('No types returned from API');
      }
      emit(state.copyWith(loading: false, types: data));
    } catch (e) {
      debugPrint('Error fetching types from API: $e');
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}