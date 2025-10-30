import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/user_profile/data/model/my_ads_model.dart';
import 'package:mushtary/features/user_profile_id/data/repo/publisher_repo.dart'; // 🔄 Changed to PublisherRepo

// States
abstract class UserAdsState {}

class UserAdsInitial extends UserAdsState {}

class UserAdsLoading extends UserAdsState {}

class UserAdsSuccess extends UserAdsState {
  final List<MyAdsModel> ads;
  UserAdsSuccess(this.ads);
}

class UserAdsFailure extends UserAdsState {
  final String error;
  UserAdsFailure(this.error);
}

// Cubit
class UserAdsCubit extends Cubit<UserAdsState> {
  final PublisherRepo _repo; // 🔄 Changed type to PublisherRepo

  UserAdsCubit(this._repo) : super(UserAdsInitial());

  Future<void> fetchUserAds(int userId) async {
    emit(UserAdsLoading());
    try {
      // 🔄 Changed method call to use PublisherRepo's method
      final ads = await _repo.getPublisherAds(userId);
      emit(UserAdsSuccess(ads));
    } on AppException catch (e) {
      emit(UserAdsFailure(e.message));
    } catch (e) {
      emit(UserAdsFailure('حدث خطأ في جلب الإعلانات: ${e.toString()}'));
    }
  }
}