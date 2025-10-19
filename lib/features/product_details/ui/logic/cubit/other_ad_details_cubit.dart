// lib/features/other_ads/ui/logic/cubit/other_ad_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/other_ads_repo.dart';
import 'other_ad_details_state.dart';

class OtherAdDetailsCubit extends Cubit<OtherAdDetailsState> {
  final OtherAdsRepo repo;
  OtherAdDetailsCubit(this.repo) : super(OtherAdDetailsInitial());

  Future<void> fetchOtherAdDetails(int id) async {
    emit(OtherAdDetailsLoading());
    try {
      final details = await repo.fetchOtherAdDetails(id);
      emit(OtherAdDetailsSuccess(details));
    } catch (e) {
      emit(OtherAdDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}