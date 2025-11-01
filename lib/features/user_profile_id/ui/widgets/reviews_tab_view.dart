import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/user_profile_id/ui/cubit/user_reviews_cubit.dart';
import 'package:mushtary/features/user_profile_id/data/model/review_model.dart';

class ReviewsTabView extends StatelessWidget {
  const ReviewsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserReviewsCubit, UserReviewsState>(
      builder: (context, state) {
        if (state is UserReviewsLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (state is UserReviewsFailure) {
          return Center(
            child: Text(
              'فشل تحميل التقييمات: ${state.error}',
              style: TextStyles.font14Red500Weight,
              textAlign: TextAlign.center,
            ),
          );
        } else if (state is UserReviewsSuccess) {
          if (state.reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border,
                      size: 64.r, color: ColorsManager.lightGrey),
                  verticalSpace(16),
                  Text(
                    'لا توجد تقييمات حاليًا.',
                    style: TextStyles.font16Dark300Grey400Weight,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            itemCount: state.reviews.length,
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              return ReviewItem(
                reviewerName: review.reviewerName ?? 'مستخدم مجهول',
                reviewText: review.comment ?? '',
                rating: review.rating,
                reviewerImage: review.reviewerImage,
                createdAt: review.createdAt,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String reviewerName;
  final String reviewText;
  final double? rating;
  final String? reviewerImage;
  final String createdAt;

  const ReviewItem({
    super.key,
    required this.reviewerName,
    required this.reviewText,
    required this.rating,
    this.reviewerImage,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = rating ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: ColorsManager.primary500,
                backgroundImage: reviewerImage != null && reviewerImage!.isNotEmpty
                    ? CachedNetworkImageProvider(reviewerImage!)
                    : null,
                child: reviewerImage == null || reviewerImage!.isEmpty
                    ? Text(
                  reviewerName.isNotEmpty
                      ? reviewerName[0].toUpperCase()
                      : '؟',
                  style: TextStyles.font14Black500Weight
                      .copyWith(color: Colors.white),
                )
                    : null,
              ),
              horizontalSpace(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: TextStyles.font14Black500Weight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyles.font12DarkGray400Weight,
                    ),
                    if (rating != null && rating! > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          children: [
                            ...List.generate(
                              5,
                                  (i) => Icon(
                                i < displayRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: ColorsManager.secondary500,
                                size: 14.r,
                              ),
                            ),
                            horizontalSpace(4),
                            Text(
                              displayRating.toStringAsFixed(1),
                              style: TextStyles.font10Yellow500Weight,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(8),
          Text(
            reviewText,
            style: TextStyles.font12Dark500400Weight,
          ),
          verticalSpace(8),
          Divider(color: ColorsManager.lightGrey, height: 1.h),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      return dateString.split('T')[0];
    } catch (e) {
      return dateString;
    }
  }
}