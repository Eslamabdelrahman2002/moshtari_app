import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/my_ads_model.dart';
import '../../data/model/my_auctions_model.dart';
import '../../data/model/user_profile_model.dart';
import '../../data/repo/profile_repo.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;

  ProfileCubit(this._profileRepo) : super(ProfileInitial());

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? imageFile; // الصورة الجديدة
  UserProfileModel? user; // بيانات المستخدم
  List<MyAdsModel> myAds = [];
  List<MyAuctionModel> myAuctions = [];

  /// جلب بيانات المستخدم من API
  void loadProfile({int page = 1, int limit = 10}) async {
    emit(ProfileLoading());
    try {
      user = await _profileRepo.getUserProfile();
      myAds = await _profileRepo.getMyAds(page: page, limit: limit);
      myAuctions = await _profileRepo.getMyAuctions(page: page, limit: limit);

      nameController.text = user?.username ?? '';
      emailController.text = user?.email ?? '';
      phoneController.text = user?.phoneNumber ?? '';

      emit(ProfileSuccess(
        user: user!,
        myAds: myAds,
        myAuctions: myAuctions,
      ));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
  int? get providerId => user?.provider?.providerId;

  /// تحديث بيانات المستخدم
  Future<void> updateProfile() async {
    if (formKey.currentState!.validate()) {
      emit(ProfileUpdateInProgress());
      try {
        await _profileRepo.updateUserProfile(
          username: nameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          profilePicture: imageFile,
        );
        emit(ProfileUpdateSuccess());
        loadProfile(); // إعادة تحميل البيانات بعد التحديث
      } catch (e) {
        emit(ProfileUpdateFailure(e.toString()));
      }
    }
  }

  /// تغيير الصورة المختارة
  Future<void> changeImage(File pickedFile) async {
    imageFile = pickedFile;
    emit(ProfileImageChanged());
  }

  /// تحديث بيانات المستخدم محلياً
  void updateUser(UserProfileModel updatedUser) {
    if (state is ProfileSuccess) {
      final currentState = state as ProfileSuccess;
      emit(ProfileSuccess(
        user: updatedUser,
        myAds: currentState.myAds,
        myAuctions: currentState.myAuctions,
      ));
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    return super.close();
  }
}
