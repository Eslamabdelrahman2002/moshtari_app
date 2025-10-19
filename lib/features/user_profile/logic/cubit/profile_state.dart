import 'package:equatable/equatable.dart';
import '../../data/model/my_ads_model.dart';
import '../../data/model/my_auctions_model.dart';
import '../../data/model/user_profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String error;
  const ProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ProfileSuccess extends ProfileState {
  final UserProfileModel user;
  final List<MyAdsModel> myAds;
  final List<MyAuctionModel> myAuctions;

  const ProfileSuccess({
    required this.user,
    required this.myAds,
    required this.myAuctions,
  });

  @override
  List<Object?> get props => [user, myAds, myAuctions];
}

// حالات التحديث
class ProfileUpdateInProgress extends ProfileState {}
class ProfileUpdateSuccess extends ProfileState {}
class ProfileUpdateFailure extends ProfileState {
  final String error;
  const ProfileUpdateFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// حالة لتغيير الصورة فقط
class ProfileImageChanged extends ProfileState {}
