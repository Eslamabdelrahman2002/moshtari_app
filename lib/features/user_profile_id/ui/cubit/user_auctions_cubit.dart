import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/user_profile/data/model/my_auctions_model.dart';
import 'package:mushtary/features/user_profile_id/data/repo/publisher_repo.dart';

abstract class UserAuctionsState {}
class UserAuctionsInitial extends UserAuctionsState {}
class UserAuctionsLoading extends UserAuctionsState {}
class UserAuctionsSuccess extends UserAuctionsState {
  final List<MyAuctionModel> auctions;
  UserAuctionsSuccess(this.auctions);
}
class UserAuctionsFailure extends UserAuctionsState {
  final String error;
  UserAuctionsFailure(this.error);
}

class UserAuctionsCubit extends Cubit<UserAuctionsState> {
  final PublisherRepo _repo;
  UserAuctionsCubit(this._repo) : super(UserAuctionsInitial());

  Future<void> fetchUserAuctions(int userId) async {
    emit(UserAuctionsLoading());
    try {
      final auctions = await _repo.getPublisherAuctions(userId);
      emit(UserAuctionsSuccess(auctions));
    } on AppException catch (e) {
      emit(UserAuctionsFailure(e.message));
    } catch (e) {
      emit(UserAuctionsFailure('حدث خطأ أثناء جلب المزادات: $e'));
    }
  }
}