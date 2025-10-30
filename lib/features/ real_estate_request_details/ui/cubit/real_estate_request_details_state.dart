// file: features/real_estate_requests/logic/cubit/real_estate_request_details_state.dart

import '../../data/model/real_estate_request_details_model.dart';

abstract class RealEstateRequestDetailsState {
  const RealEstateRequestDetailsState();
}

class RequestDetailsInitial extends RealEstateRequestDetailsState {
  const RequestDetailsInitial();
}

class RequestDetailsLoading extends RealEstateRequestDetailsState {
  const RequestDetailsLoading();
}

class RequestDetailsSuccess extends RealEstateRequestDetailsState {
  final RealEstateRequestDetailsModel details;
  const RequestDetailsSuccess(this.details);
}

class RequestDetailsFailure extends RealEstateRequestDetailsState {
  final String message;
  const RequestDetailsFailure(this.message);
}