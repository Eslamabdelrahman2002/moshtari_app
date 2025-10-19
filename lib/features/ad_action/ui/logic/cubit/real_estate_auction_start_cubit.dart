import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/real_estate_auction_start_repo.dart';
import 'auction_start_state.dart';

class RealEstateAuctionStartCubit extends Cubit<AuctionStartState> {
  final RealEstateAuctionStartRepo repo;
  RealEstateAuctionStartCubit(this.repo) : super(const AuctionStartState());

  Future<void> submit({
    required String title,
    required String description,
    required num startPrice,
    required num hiddenLimit,
    required num bidStep,
    String? startTimeIso,
    required String endTimeIso,
    required String type,
    required num minBidValue,
    required bool isAutoApproval,
    required String itemsJson,
    File? thumbnail,
    List<File> images = const [],
    List<File> pdfs = const [],
  }) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      // ignore: avoid_print
      print('SUBMIT itemsJson: $itemsJson');

      final resp = await repo.start(
        title: title,
        description: description,
        startPrice: startPrice,
        hiddenLimit: hiddenLimit,
        bidStep: bidStep,
        startTimeIso: (startTimeIso?.trim().isEmpty ?? true) ? null : startTimeIso!.trim(),
        endTimeIso: endTimeIso,
        type: type,
        minBidValue: minBidValue,
        isAutoApproval: isAutoApproval,
        itemsJson: itemsJson,
        thumbnail: thumbnail,
        images: images,
        pdfs: pdfs,
      );

      emit(state.copyWith(
        submitting: false,
        success: true,
        serverMessage: resp['message']?.toString(),
      ));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }
}