import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/user_profile_id/data/repo/publisher_repo.dart';
import 'package:mushtary/features/user_profile_id/data/model/my_auctions_model.dart';
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
      final msg = e.message;
      if ((e is AppException && (e.statusCode == 404)) || (msg.contains('لا يوجد'))) {
        emit(UserAuctionsSuccess(const []));
      } else {
        emit(UserAuctionsFailure(msg));
      }
    } catch (e) {
      emit(UserAuctionsFailure('حدث خطأ أثناء جلب المزادات: $e'));
    }
  }
}