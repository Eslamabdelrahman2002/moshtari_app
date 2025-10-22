import 'dart:io';
import 'package:dio/dio.dart';
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
    required num bidStep,
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
        bidStep: bidStep,
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
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      emit(state.copyWith(submitting: false, error: msg));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }

  String _extractDioError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        final errors = data['errors'];
        String details = '';
        if (errors is Map) {
          details = errors.entries
              .map((kv) => '${kv.key}: ${(kv.value is List) ? (kv.value as List).join(", ") : kv.value}')
              .join('\n- ');
        }
        return [
          if (message != null && message.trim().isNotEmpty) message,
          if (details.trim().isNotEmpty) 'التفاصيل:\n- $details',
        ].where((s) => s != null && s.toString().trim().isNotEmpty).join('\n\n');
      }
    } catch (_) {}
    return e.message ?? e.toString();
  }
}