import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/user_profile_id/data/model/review_model.dart';
import 'package:mushtary/features/user_profile_id/data/repo/user_reviews_repo.dart';

/// 🧠 States
abstract class UserReviewsState {}

class UserReviewsInitial extends UserReviewsState {}

class UserReviewsLoading extends UserReviewsState {}

class UserReviewsSuccess extends UserReviewsState {
  final List<ReviewModel> reviews;
  final Map<String, dynamic> userData;

  UserReviewsSuccess(this.reviews, this.userData);
}

class UserReviewsFailure extends UserReviewsState {
  final String error;
  UserReviewsFailure(this.error);
}

/// 🧱 Cubit
class UserReviewsCubit extends Cubit<UserReviewsState> {
  final UserReviewsRepo _repo;

  UserReviewsCubit(this._repo) : super(UserReviewsInitial());

  Future<void> fetchUserReviews(int userId) async {
    emit(UserReviewsLoading());
    try {
      debugPrint('🟡 [Cubit] Starting fetchUserReviews for userId=$userId');

      final result = await _repo.getUserReviews(userId);

      debugPrint('🟢 [Cubit] Repo returned result = $result');

      final rawReviews = result['reviews'];
      final rawUser = result['user'];

      debugPrint('🟢 [Cubit] rawReviews type = ${rawReviews.runtimeType}');
      debugPrint('🟢 [Cubit] rawUser type = ${rawUser.runtimeType}');

      final List<ReviewModel> reviews =
      rawReviews is List<ReviewModel> ? rawReviews : <ReviewModel>[];
      final Map<String, dynamic> userData =
      rawUser is Map<String, dynamic> ? rawUser : <String, dynamic>{};

      debugPrint('🟢 [Cubit] Parsed reviews length = ${reviews.length}');
      debugPrint('🟢 [Cubit] Parsed userData keys = ${userData.keys.toList()}');

      emit(UserReviewsSuccess(reviews, userData));
      debugPrint('✅ [Cubit] Emitted UserReviewsSuccess');
    } on AppException catch (e) {
      debugPrint('🔴 [Cubit][AppException] ${e.message}');
      emit(UserReviewsFailure(e.message));
    } catch (e, s) {
      debugPrint('🔴 [Cubit][GeneralError] $e');
      debugPrint('🔴 [STACK] $s');
      emit(UserReviewsFailure('فشل تحميل البيانات: استجابة API غير متوقعة.'));
    }
  }
}