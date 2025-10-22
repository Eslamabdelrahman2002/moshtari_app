// lib/features/car_auctions/ui/logic/cubit/car_auction_details_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/car_auction_repo.dart';
import 'car_auction_details_state.dart';

// 🟢 حالات عملية القبول/الرفض
abstract class AuctionActionState {}
class AuctionActionInitial extends AuctionActionState {}
class AuctionActionLoading extends AuctionActionState {}
class AuctionActionSuccess extends AuctionActionState {
  final String message;
  AuctionActionSuccess(this.message);
}
class AuctionActionFailure extends AuctionActionState {
  final String message;
  AuctionActionFailure(this.message);
}

class CarAuctionDetailsCubit extends Cubit<CarAuctionDetailsState> {
  final CarAuctionRepo repo;
  // 🟢 NEW: Cubit for Approval/Rejection
  final _actionCubit = AuctionActionCubit();

  CarAuctionDetailsCubit(this.repo) : super(CarAuctionDetailsInitial());

  // Getter for the action Cubit to be exposed to the UI
  AuctionActionCubit get actionCubit => _actionCubit;

  // الدالة الأساسية لجلب تفاصيل المزاد
  Future<void> fetchAuction(int id) async {
    emit(CarAuctionDetailsLoading());
    try {
      // نفترض وجود fetchCarAuction(id) في Repo
      final data = await repo.fetchCarAuction(id);
      emit(CarAuctionDetailsSuccess(data));
    } catch (e) {
      emit(CarAuctionDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // 🟢 NEW: Approve auction result
  Future<void> approveAuction(int id, String auctionType) async {
    _actionCubit.emit(AuctionActionLoading());
    try {
      // نفترض وجود دالة approveAuction(id, type) في Repo
      final response = await repo.approveAuction(id, auctionType);
      final message = response['message'] ?? 'تم قبول المزايدة بنجاح';
      _actionCubit.emit(AuctionActionSuccess(message));
      // Refresh details after action
      await fetchAuction(id);
      _actionCubit.reset(); // إعادة تعيين حالة الإجراء
    } catch (e) {
      _actionCubit.emit(AuctionActionFailure(e.toString()));
    }
  }

  // 🟢 NEW: Reject auction result
  Future<void> rejectAuction(int id, String auctionType) async {
    _actionCubit.emit(AuctionActionLoading());
    try {
      // نفترض وجود دالة rejectAuction(id, type) في Repo
      final response = await repo.rejectAuction(id, auctionType);
      final message = response['message'] ?? 'تم رفض نتيجة المزاد بنجاح';
      _actionCubit.emit(AuctionActionSuccess(message));
      // Refresh details after action
      await fetchAuction(id);
      _actionCubit.reset(); // إعادة تعيين حالة الإجراء
    } catch (e) {
      _actionCubit.emit(AuctionActionFailure(e.toString()));
    }
  }
}

// 🟢 NEW: Dedicated Cubit for Action
class AuctionActionCubit extends Cubit<AuctionActionState> {
  AuctionActionCubit() : super(AuctionActionInitial());

  void reset() => emit(AuctionActionInitial());
}