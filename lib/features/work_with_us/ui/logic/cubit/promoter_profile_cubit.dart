import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/promoter_profile_models.dart';
import '../../../data/repo/promoter_profile_repo.dart';
import 'promoter_profile_state.dart';

class PromoterProfileCubit extends Cubit<PromoterProfileState> {
  final PromoterProfileRepo _repo;
  PromoterProfileCubit(this._repo) : super(const PromoterProfileState());

  Future<void> loadProfile() async {
    // نبدأ التحميل ونمسح أي خطأ سابق
    emit(state.copyWith(loading: true, clearError: true));
    try {
      // قد يرجع الريبو Data أو Response (أو حتى Map/String)، نطبعها كلها لـ Response
      final Object? raw = await _repo.fetchProfile();

      final PromoterProfileResponse response;
      if (raw is PromoterProfileResponse) {
        response = raw;
      } else if (raw is PromoterProfileData) {
        response = PromoterProfileResponse(
          success: true,
          message: '',
          data: raw,
        );
      } else if (raw is Map<String, dynamic>) {
        response = PromoterProfileResponse.fromJson(raw);
      } else if (raw is String) {
        response = PromoterProfileResponse.fromRaw(raw);
      } else {
        throw Exception('Unexpected response type: ${raw.runtimeType}');
      }

      emit(state.copyWith(loading: false, data: response, clearError: true));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(loading: false, error: errorMessage));
    }
  }
}