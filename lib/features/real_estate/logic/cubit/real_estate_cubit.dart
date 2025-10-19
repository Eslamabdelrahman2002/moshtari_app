import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/real_estate_repo.dart';
import '../../data/model/real_estate_filter_params.dart';
import 'real_estate_state.dart';

class RealEstateCubit extends Cubit<RealEstateState> {
  final RealEstateRepo repository;

  RealEstateCubit(this.repository) : super(RealEstateInitial());

  Future<void> fetchAllAds() async {
    emit(RealEstateLoading());
    try {
      final ads = await repository.getRealEstateAds();
      emit(RealEstateLoaded(ads));
    } catch (e) {
      emit(RealEstateError(e.toString()));
    }
  }

  Future<void> fetchAdDetails(int id) async {
    emit(RealEstateLoading());
    try {
      final details = await repository.getRealEstateAdById(id);
      emit(RealEstateDetailsLoaded(details));
    } catch (e) {
      emit(RealEstateError(e.toString()));
    }
  }

  // ✨ المتود الجديدة اللي بتدعم الفلترة
  Future<void> fetchRealEstateAds(RealEstateFilterParams filterParams) async {
    emit(RealEstateLoading());
    try {
      final ads = await repository.getFilteredRealEstateAds(filterParams);
      emit(RealEstateLoaded(ads));
    } catch (e) {
      emit(RealEstateError(e.toString()));
    }
  }
}
