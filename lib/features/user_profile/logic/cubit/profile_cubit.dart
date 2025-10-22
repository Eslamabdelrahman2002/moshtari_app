import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/helpers/cache_helper.dart';
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

  File? imageFile;
  UserProfileModel? user;
  List<MyAdsModel> myAds = [];
  List<MyAuctionModel> myAuctions = [];

  void loadProfile({int page = 1, int limit = 10}) async {
    emit(ProfileLoading());
    try {
      user = await _profileRepo.getUserProfile();
      myAds = await _profileRepo.getMyAds(page: page, limit: limit);
      myAuctions = await _profileRepo.getMyAuctions(page: page, limit: limit);

      nameController.text = user?.username ?? '';
      emailController.text = user?.email ?? '';
      phoneController.text = user?.phoneNumber ?? '';

      if (user == null) {
        emit(const ProfileFailure('فشل في جلب بيانات المستخدم'));
        return;
      }

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

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;
    emit(ProfileUpdateInProgress());
    try {
      await _profileRepo.updateUserProfile(
        username: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        profilePicture: imageFile,
      );
      emit(ProfileUpdateSuccess());
      loadProfile();
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
    }
  }

  Future<void> changeImage(File pickedFile) async {
    imageFile = pickedFile;
    emit(ProfileImageChanged());
  }

  void updateUser(UserProfileModel updatedUser) {
    final s = state;
    if (s is ProfileSuccess) {
      emit(ProfileSuccess(
        user: updatedUser,
        myAds: s.myAds,
        myAuctions: s.myAuctions,
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

  Future<bool> deleteAccount() async {
    try {
      await _profileRepo.deleteAccount();
      await CacheHelper.removeData(key: 'token'); // امسح التوكن
      return true;
    } catch (e) {
      // ممكن تسجّل الخطأ أو تعرضه
      return false;
    }
  }
}