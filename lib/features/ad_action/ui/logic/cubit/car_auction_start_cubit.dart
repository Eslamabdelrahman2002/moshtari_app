import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/car_auction_start_repo.dart';
import 'auction_start_state.dart';

class CarAuctionStartCubit extends Cubit<AuctionStartState> {
  final CarAuctionStartRepo repo;
  CarAuctionStartCubit(this.repo) : super(const AuctionStartState());

  Future<void> submit({
    required String type,
    required String title,
    required String description,
    required bool isAutoApproval,
    String? startDateIso,
    required String endDateIso,
    required num minBidValue,
    required String itemsJson,
    File? thumbnail,
    List<File> images = const [],
    List<File> pdfs = const [],
  }) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      final resp = await repo.start(
        type: type,
        title: title,
        description: description,
        isAutoApproval: isAutoApproval,
        startDateIso: startDateIso,
        endDateIso: endDateIso,
        minBidValue: minBidValue,
        itemsJson: itemsJson,
        thumbnail: thumbnail,
        images: images,
        pdfs: pdfs,
      );
      emit(state.copyWith(submitting: false, success: true, serverMessage: resp['message']?.toString()));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }
}