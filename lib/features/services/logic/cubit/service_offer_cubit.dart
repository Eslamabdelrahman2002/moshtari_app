// lib/features/services/logic/cubit/service_offer_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/service_offers_repo.dart';
import 'service_offer_state.dart';

class ServiceOfferCubit extends Cubit<ServiceOfferState> {
  final ServiceOffersRepo _repo;
  ServiceOfferCubit(this._repo) : super(const ServiceOfferInitial());

  Future<void> send({
    required int requestId,
    required num price,
    String? message,
  }) async {
    emit(const ServiceOfferSubmitting());
    try {
      final res = await _repo.sendOffer(requestId: requestId, price: price, message: message);
      final msg = (res['message']?.toString().trim().isNotEmpty ?? false)
          ? res['message'].toString()
          : 'تم إرسال العرض بنجاح';
      emit(ServiceOfferSuccess(msg));
    } catch (e) {
      emit(ServiceOfferFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}