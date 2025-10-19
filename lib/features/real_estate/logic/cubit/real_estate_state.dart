import '../../../real_estate_details/date/model/real_estate_details_model.dart';
import '../../data/model/real_estate_ad_model.dart';


abstract class RealEstateState {}

class RealEstateInitial extends RealEstateState {}

class RealEstateLoading extends RealEstateState {}

class RealEstateLoaded extends RealEstateState {
  final List<RealEstateListModel> ads;
  RealEstateLoaded(this.ads);
}

class RealEstateDetailsLoaded extends RealEstateState {
  final RealEstateDetailsModel details;
  RealEstateDetailsLoaded(this.details);
}

class RealEstateError extends RealEstateState {
  final String message;
  RealEstateError(this.message);
}
