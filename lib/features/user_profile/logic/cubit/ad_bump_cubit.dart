import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/ad_bump_repo.dart';
import 'ad_bump_state.dart';


class AdBumpCubit extends Cubit<AdBumpState> {
  final AdsBumpRepo _repo;
  AdBumpCubit(this._repo) : super(const AdBumpState());

  Future<void> bump(String adType, int adId) async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, success: false, error: null));
    try {
      await _repo.bumpAd(adType: adType, adId: adId);
      emit(state.copyWith(loading: false, success: true, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, success: false, error: e.toString()));
      emit(state.copyWith(error: null)); // reset error after showing
    }
  }

  void reset() => emit(const AdBumpState());
}