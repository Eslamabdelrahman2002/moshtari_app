// lib/features/home/logic/cubit/home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  HomeCubit(this._homeRepo) : super(HomeInitial());

  void fetchHomeData() async {
    emit(HomeLoading());
    try {
      final homeData = await _homeRepo.getHomeData();
      emit(HomeSuccess(homeData));
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }
}