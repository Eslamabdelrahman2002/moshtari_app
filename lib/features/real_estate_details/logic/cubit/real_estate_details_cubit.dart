import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../real_estate/data/repo/real_estate_repo.dart';
import 'real_estate_details_state.dart';


class RealEstateDetailsCubit extends Cubit<RealEstateDetailsState> {
  final RealEstateRepo realEstateRepo;

  RealEstateDetailsCubit(this.realEstateRepo) : super(RealEstateDetailsInitial());

  Future<void> getRealEstateDetails(int id) async {
    emit(RealEstateDetailsLoading());
    try {
      final details = await realEstateRepo.getRealEstateAdById(id);
      emit(RealEstateDetailsSuccess(details));
    } catch (e) {
      emit(RealEstateDetailsFailure(e.toString()));
    }
  }
}