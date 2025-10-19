import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/promoter_profile_repo.dart';
import 'promoter_profile_state.dart';

class PromoterProfileCubit extends Cubit<PromoterProfileState> {
  final PromoterProfileRepo _repo;
  PromoterProfileCubit(this._repo) : super(const PromoterProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await _repo.fetchProfile();
      emit(state.copyWith(loading: false, data: data, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}