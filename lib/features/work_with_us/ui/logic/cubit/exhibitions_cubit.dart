import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/work_with_us/data/repo/exhibitions_repo.dart';
import 'exhibitions_state.dart';

class ExhibitionsCubit extends Cubit<ExhibitionsState> {
  final ExhibitionsRepo _repo;
  ExhibitionsCubit(this._repo) : super(const ExhibitionsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.fetchAll();
      emit(state.copyWith(loading: false, items: list, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}