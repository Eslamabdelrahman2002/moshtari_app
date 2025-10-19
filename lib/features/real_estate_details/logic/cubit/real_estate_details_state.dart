import 'package:equatable/equatable.dart';
import '../../date/model/real_estate_details_model.dart';

abstract class RealEstateDetailsState extends Equatable {
  const RealEstateDetailsState();

  @override
  List<Object?> get props => [];
}

class RealEstateDetailsInitial extends RealEstateDetailsState {}

class RealEstateDetailsLoading extends RealEstateDetailsState {}

class RealEstateDetailsSuccess extends RealEstateDetailsState {
  final RealEstateDetailsModel details;

  const RealEstateDetailsSuccess(this.details);

  @override
  List<Object?> get props => [details];
}

class RealEstateDetailsFailure extends RealEstateDetailsState {
  final String message;
  RealEstateDetailsFailure(this.message);
}
