// lib/features/other_ads/ui/logic/cubit/other_ad_details_state.dart
import '../../../data/model/other_ad_details_model.dart';

abstract class OtherAdDetailsState {}

class OtherAdDetailsInitial extends OtherAdDetailsState {}

class OtherAdDetailsLoading extends OtherAdDetailsState {}

class OtherAdDetailsSuccess extends OtherAdDetailsState {
  final OtherAdDetailsModel details;
  OtherAdDetailsSuccess(this.details);
}

class OtherAdDetailsFailure extends OtherAdDetailsState {
  final String message;
  OtherAdDetailsFailure(this.message);
}