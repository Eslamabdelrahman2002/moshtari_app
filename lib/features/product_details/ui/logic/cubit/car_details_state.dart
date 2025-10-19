// lib/features/car_details/logic/cubit/car_details_state.dart
part of 'car_details_cubit.dart';

abstract class CarDetailsState {}

class CarDetailsInitial extends CarDetailsState {}

class CarDetailsLoading extends CarDetailsState {}

class CarDetailsSuccess extends CarDetailsState {
  final CarDetailsModel details;
  CarDetailsSuccess(this.details);
}

class CarDetailsFailure extends CarDetailsState {
  final String error;
  CarDetailsFailure(this.error);
}