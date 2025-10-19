

import '../../../data/model/car_part_details_model.dart';

abstract class CarPartsDetailsState {}
class CarPartsDetailsInitial extends CarPartsDetailsState {}
class CarPartsDetailsLoading extends CarPartsDetailsState {}
class CarPartsDetailsSuccess extends CarPartsDetailsState {
  final CarPartDetailsModel details;
  CarPartsDetailsSuccess(this.details);
}
class CarPartsDetailsFailure extends CarPartsDetailsState {
  final String message;
  CarPartsDetailsFailure(this.message);
}