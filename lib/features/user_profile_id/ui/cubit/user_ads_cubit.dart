import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/user_profile_id/data/repo/publisher_repo.dart'; // 🔄 Changed to PublisherRepo
import 'package:mushtary/features/user_profile_id/data/model/my_ads_model.dart';
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
  final PublisherRepo _repo;
  UserAdsCubit(this._repo) : super(UserAdsInitial());

  Future<void> fetchUserAds(int userId) async {
    emit(UserAdsLoading());
    try {
      final ads = await _repo.getPublisherAds(userId);
      emit(UserAdsSuccess(ads));
    } on AppException catch (e) {
      final msg = e.message;
      // لو الرسالة بتدل إنه مفيش بيانات، اعتبرها قائمة فاضية
      if ((e is AppException && (e.statusCode == 404)) || (msg.contains('لا يوجد'))) {
        emit(UserAdsSuccess(const []));
      } else {
        emit(UserAdsFailure(msg));
      }
    } catch (e) {
      emit(UserAdsFailure('حدث خطأ في جلب الإعلانات: ${e.toString()}'));
    }
  }
}