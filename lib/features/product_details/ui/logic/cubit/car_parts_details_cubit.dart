
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/car_parts_repo.dart';
import 'car_parts_details_state.dart';


class CarPartsDetailsCubit extends Cubit<CarPartsDetailsState> {
  final CarPartsRepo repo;
  CarPartsDetailsCubit(this.repo) : super(CarPartsDetailsInitial());

  Future<void> fetchCarPartDetails(int id) async {
    emit(CarPartsDetailsLoading());
    try {
      final details = await repo.getCarPartAdById(id);
      emit(CarPartsDetailsSuccess(details));
    } catch (e) {
      emit(CarPartsDetailsFailure(e.toString()));
    }
  }
}