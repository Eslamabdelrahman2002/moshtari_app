import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/location/data/repo/location_repo.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepo _repo;
  LocationCubit(this._repo) : super(const LocationState());

  Future<void> loadRegions() async {
    emit(state.copyWith(regionsLoading: true, regionsError: null));
    try {
      final data = await _repo.fetchRegions();
      emit(state.copyWith(regionsLoading: false, regions: data, regionsError: null));
    } catch (e) {
      emit(state.copyWith(regionsLoading: false, regionsError: 'تعذّر تحميل المناطق'));
    }
  }

  Future<void> loadCities(int regionId) async {
    emit(state.copyWith(citiesLoading: true, citiesError: null, cities: const []));
    try {
      final data = await _repo.fetchCities(regionId);
      emit(state.copyWith(citiesLoading: false, cities: data, citiesError: null));
    } catch (e) {
      emit(state.copyWith(citiesLoading: false, citiesError: 'تعذّر تحميل المدن'));
    }
  }
}