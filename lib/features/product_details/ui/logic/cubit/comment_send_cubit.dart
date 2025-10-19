import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/product_details/data/repo/ad_reviews_repo.dart';
import 'comment_send_state.dart';

class CommentSendCubit extends Cubit<CommentSendState> {
  final AdReviewsRepo _repo;
  CommentSendCubit(this._repo) : super(const CommentSendState());

  Future<void> submit({
    required int adId,
    required String comment,
    int? rating,
    Map<String, dynamic>? extraRatings,
  }) async {
    if (comment.trim().isEmpty) {
      emit(state.copyWith(error: 'اكتب تعليقاً أولاً'));
      emit(state.copyWith(error: null));
      return;
    }
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      await _repo.postComment(
        adId: adId,
        comment: comment.trim(),
        rating: rating,
        extraRatings: extraRatings,
      );
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(error: null));
    }
  }
}