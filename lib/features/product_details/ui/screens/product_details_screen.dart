import 'package:flutter/material.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart' hide AuctionsModel;
import 'package:mushtary/features/product_details/ui/widgets/app_bar.dart';
import 'package:mushtary/features/product_details/ui/widgets/comments_view.dart';
import 'package:mushtary/features/product_details/ui/widgets/current_user_info.dart';
import 'package:mushtary/features/product_details/ui/widgets/details_panel.dart';
import 'package:mushtary/features/product_details/ui/widgets/highest_auction.dart';
import 'package:mushtary/features/product_details/ui/widgets/info_description.dart';
import 'package:mushtary/features/product_details/ui/widgets/product_images.dart';
import 'package:mushtary/features/product_details/ui/widgets/product_info_grid_view.dart';
import 'package:mushtary/features/product_details/ui/widgets/promo_button.dart';
import 'package:mushtary/core/widgets/reminder.dart';
import 'package:mushtary/features/product_details/ui/widgets/similar_ads.dart';
import 'package:mushtary/features/product_details/ui/widgets/story_and_title.dart';
import 'package:mushtary/features/product_details/ui/widgets/tag_list_panel.dart';
import 'package:mushtary/features/product_details/ui/widgets/navigation_bar.dart' as widget;
import 'package:mushtary/features/home/data/models/auctions/auctions_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final AuctionsModel auctionsModel;
  const ProductDetailsScreen({super.key, required this.auctionsModel});

  @override
  Widget build(BuildContext context) {
    final List<HomeAdModel> mockSimilarAds = List.generate(
      4,
          (index) => HomeAdModel.fromJson({
        "id": index,
        "title": "إعلان مشابه ${index + 1}",
        "price": "150,000",
        "name_ar": "الرياض",
        "created_at": DateTime.now().toIso8601String(),
        "username": "مستخدم",
        "image_urls": ["https://via.placeholder.com/150"],
        "condition": "جديد"
      }),
    );

    // بيانات المالك لعرض CurrentUserInfo
    String ownerName = '';
    String? ownerPicture;
    bool isVerified = false;
    double rating = 0;
    int reviewsCount = 0;

    try {
      final dyn = auctionsModel as dynamic;
      ownerName = dyn.username?.toString() ??
          dyn.user?.username?.toString() ??
          dyn.user?.name?.toString() ??
          '';

      final u = dyn.user;
      if (u != null) {
        ownerPicture = (u.profilePicture ??
            u.profile_photo_url ??
            u.avatar ??
            u.picture ??
            u.imageUrl ??
            u.photo)
            ?.toString();

        isVerified = (u.isVerified == true) ||
            (u.verified == true) ||
            (u.is_verified == true);

        final r = u.rating ?? u.avg_rating ?? u.average_rating;
        if (r != null) {
          rating = (r is num) ? r.toDouble() : (double.tryParse(r.toString()) ?? 0);
        }

        final rc = u.reviewsCount ?? u.reviews_count ?? u.ratings_count;
        if (rc != null) {
          reviewsCount = (rc is num) ? rc.toInt() : int.tryParse(rc.toString()) ?? 0;
        }
      }
    } catch (_) {}

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const ProductScreenAppBar(),
              ProductImages(
                images: auctionsModel.car?.images ?? [],
                status: auctionsModel.car?.status ?? '',
                auctionsModel: auctionsModel,
              ),
              StoryAndTitleWidget(title: auctionsModel.title ?? ''),
              DetailsPanel(
                location: auctionsModel.location ?? '',
                time: auctionsModel.createdAt ?? DateTime.now(),
                price: auctionsModel.price ?? '',
              ),

              // معلومات المالك - ربط CurrentUserInfo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CurrentUserInfo(
                  ownerName: (ownerName.isEmpty ? '—' : ownerName),
                  ownerPicture: ownerPicture,
                  isVerified: isVerified,
                  rating: rating,
                  reviewsCount: reviewsCount,
                  onFollow: () {}, // اختياري
                ),
              ),
              const MyDivider(),

              ProductInfoGridView(car: auctionsModel.car!),
              InfoDescription(description: auctionsModel.description ?? ''),
              const MyDivider(),
              const Reminder(),
              const MyDivider(),
              HighestAuction(highestAuction: auctionsModel.bargain?.first.price?.toString() ?? ''),
              CommentsView(bargains: auctionsModel.bargain ?? []),
              const MyDivider(),
              const PromoButton(),
              const TagListPanel(),
              SimilarAds(similarAds: mockSimilarAds),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const widget.NavigationBar(),
    );
  }
}