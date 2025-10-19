import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/exhibition_details_repo.dart';
import 'exhibition_details_state.dart';

class ExhibitionDetailsCubit extends Cubit<ExhibitionDetailsState> {
  final ExhibitionDetailsRepo _repo;
  ExhibitionDetailsCubit(this._repo) : super(const ExhibitionDetailsState());

  Future<void> load(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await _repo.fetchById(id);
      emit(state.copyWith(loading: false, data: data));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}