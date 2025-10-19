// lib/features/car_details/logic/cubit/car_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/car_details_model.dart';
import '../../../data/repo/car_details_repo.dart';
part 'car_details_state.dart';

class CarDetailsCubit extends Cubit<CarDetailsState> {
  final CarDetailsRepo repo;

  CarDetailsCubit(this.repo) : super(CarDetailsInitial());

  Future<void> fetchCarDetails(int id) async {
    emit(CarDetailsLoading());
    try {
      final details = await repo.fetchCarDetails(id);
      emit(CarDetailsSuccess(details));
    } catch (e) {
      emit(CarDetailsFailure(e.toString()));
    }
  }
}