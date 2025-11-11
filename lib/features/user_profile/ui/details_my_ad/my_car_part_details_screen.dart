import 'package:dotted_border/dotted_border.dart'; // 👈 إضافة للحدود المنقطة
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/reminder.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/launcher.dart';

import 'package:mushtary/features/product_details/ui/widgets/app_bar.dart';
import 'package:mushtary/features/product_details/ui/widgets/car_details/widgets/car_bottom_actions.dart';
import 'package:mushtary/features/product_details/ui/widgets/current_user_info.dart';
import 'package:mushtary/features/product_details/ui/widgets/details_panel.dart';
import 'package:mushtary/features/product_details/ui/widgets/info_description.dart';
import 'package:mushtary/features/product_details/ui/widgets/marketing_request_sheet.dart';
import 'package:mushtary/features/product_details/ui/widgets/story_and_title.dart';
import 'package:mushtary/features/product_details/ui/widgets/similar_ads.dart';

// Comments + Profile
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

import '../../../../core/router/routes.dart';

// Chat
import 'package:mushtary/features/messages/data/models/chat_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';

// Favorites
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';

// Home model (Similar ads)
import '../../../home/data/models/home_data_model.dart';

// Promo
import '../../../messages/ui/screens/chat_screen.dart';
import '../../../product_details/ui/logic/cubit/car_parts_details_cubit.dart';
import '../../../product_details/ui/logic/cubit/car_parts_details_state.dart';
import '../../../product_details/ui/widgets/car_details/widgets/car_details_panel.dart';
import '../../../product_details/ui/widgets/car_details/widgets/car_part_add_comment_field.dart';
import '../../../product_details/ui/widgets/car_details/widgets/car_part_comments_view.dart';
import '../../../product_details/ui/widgets/car_part_details_images.dart';
import '../../../product_details/ui/widgets/car_part_price.dart';
import '../../../product_details/ui/widgets/car_part_specs_card.dart';
import '../../../product_details/ui/widgets/offer_sheet.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';



import 'package:skeletonizer/skeletonizer.dart';

// Owner Ads (UserAdsCubit)
import 'package:mushtary/features/user_profile_id/ui/cubit/user_ads_cubit.dart';
import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

// سعر القطعة (نفس ستايل السيارة)

class MyCarPartDetailsScreen extends StatelessWidget {
  final int id;
  const MyCarPartDetailsScreen({super.key, required this.id});

  void _startChat(BuildContext context, int receiverId, String receiverName, dynamic partDetails) {
    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (_) async {
        final repo = getIt<MessagesRepo>();
        final conversationId = await repo.initiateChat(receiverId);

        if (conversationId != null) {
          final chatModel = MessagesModel(
            conversationId: conversationId,
            partnerUser: UserModel(id: receiverId, name: receiverName),
          );

          final adInfo = AdInfo(
            id: partDetails.id,
            title: partDetails.title,
            imageUrl: (partDetails.imageUrls is List && partDetails.imageUrls.isNotEmpty)
                ? partDetails.imageUrls.first
                : '',
            price: partDetails.price.toString(),
          );

          NavX(context).pushNamed(
            Routes.chatScreen,
            arguments: ChatScreenArgs(chatModel: chatModel, adInfo: adInfo),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر بدء المحادثة الآن.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()..fetchFavorites()),
        BlocProvider<CarPartsDetailsCubit>(
          create: (_) => getIt<CarPartsDetailsCubit>()..fetchCarPartDetails(id),
        ),
        BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()..loadProfile()),
        BlocProvider<UserAdsCubit>(create: (_) => getIt<UserAdsCubit>()), // Owner ads للـ Story
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<CarPartsDetailsCubit, CarPartsDetailsState>(
            listener: (context, state) {
              if (state is CarPartsDetailsSuccess) {
                final ownerId = state.details.user.id;
                if (ownerId != null) {
                  context.read<UserAdsCubit>().fetchUserAds(ownerId);
                }
              }
            },
            child: BlocBuilder<CarPartsDetailsCubit, CarPartsDetailsState>(
              builder: (context, state) {
                if (state is CarPartsDetailsLoading) {
                  return _buildLoadingSkeleton(context);
                }
                if (state is CarPartsDetailsFailure) {
                  return Center(child: Text(state.message));
                }
                if (state is CarPartsDetailsSuccess) {
                  final part = state.details;

                  // Similar Ads (HomeAdModel)
                  final List<HomeAdModel> similarHomeAds = part.similarAds.map((s) {
                    return HomeAdModel.fromJson({
                      "id": s.id,
                      "title": s.title,
                      "price": s.price,
                      "name_ar": s.brandName,
                      "created_at": DateTime.now().toIso8601String(),
                      "username": "",
                      "image_urls": s.imageUrls,
                      "condition": "",
                      "category_id": 2,
                    });
                  }).toList();

                  // معلومات المالك
                  final ownerId = part.user.id;
                  final ownerName = (part.user.username?.toString() ?? '—').trim();

                  String? ownerPicture;
                  bool isVerified = false;
                  double rating = 0;
                  int reviewsCount = 0;

                  try {
                    final u = part.user as dynamic;
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
                  } catch (_) {}

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const ProductScreenAppBar(),

                        // الصور
                        CarPartDetailsImages(
                          images: part.imageUrls,
                          adId: id,
                          favoriteType: 'ad',
                        ),

                        // Story: Owner Ads (تحويل إلى HomeAdModel)
                        BlocBuilder<UserAdsCubit, UserAdsState>(
                          builder: (context, adsState) {
                            List<HomeAdModel> ownerHomeAds = [];
                            if (adsState is UserAdsSuccess) {
                              final List<PublisherProductModel> publisherProducts =
                              adsState.ads.map((ad) => ad.toPublisherProduct()).toList();

                              ownerHomeAds = publisherProducts
                                  .where((p) => p.categoryId == 2) // قطع غيار فقط (اختياري)
                                  .map((p) => HomeAdModel.fromJson({
                                "id": p.id,
                                "title": p.title,
                                "price": p.priceText ?? '',
                                "name_ar": p.categoryLabel,
                                "created_at": p.createdAt ?? DateTime.now().toIso8601String(),
                                "username": "",
                                "image_urls": p.imageUrl != null ? [p.imageUrl] : <String>[],
                                "condition": "",
                              }))
                                  .toList();
                            }

                            return StoryAndTitleWidget(
                              title: part.title,
                              similarAds: ownerHomeAds,
                            );
                          },
                        ),


                        CarDetailsPanel(
                          city: part.city,
                          region: part.region,
                          createdAt:part.createdAt,
                        ),
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: CarPartPrice(priceText: part.price),
                        ),
                        const MyDivider(),

                        // معلومات المالك
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CurrentUserInfo(
                            ownerName: ownerName,
                            ownerPicture: ownerPicture,
                            isVerified: isVerified,
                            rating: rating,
                            reviewsCount: reviewsCount,
                            onTap: () {
                              if (ownerId != null) {
                                NavX(context).pushNamed(Routes.userProfileScreenId, arguments: ownerId);
                              }
                            },
                            onFollow: () {},
                          ),
                        ),
                        const MyDivider(),

                        // مواصفات إضافية
                        CarPartSpecsCardElevated(
                          condition: part.carPartDetail.condition,
                          brand: part.carPartDetail.brandName,
                          supportedModels: part.carPartDetail.supportedModels,
                          elevation: 5,
                        ),

                        InfoDescription(description: part.description),
                        const MyDivider(),

                        const Reminder(),
                        const MyDivider(),

                        // التعليقات
                        CarPartCommentsView(comments: part.comments, offers:part.offers,),

                        const SizedBox(height: 12),

                        // محرر التعليق
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CarPartAddCommentField(
                            adId: id,
                            onSuccessRefresh: () {
                              context.read<CarPartsDetailsCubit>().fetchCarPartDetails(id);
                            },
                          ),
                        ),

                        const MyDivider(),

                        // سوق للإعلان
                        PromoButton(
                          onPressed: () async {
                            final myId = context.read<ProfileCubit>().user?.userId;
                            final isOwner = (myId != null && part.user.id == myId);
                            if (isOwner) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('لا يمكنك طلب تسويق لإعلانك.')),
                              );
                              return;
                            }
                            await showMarketingRequestSheet(context, adId: id);
                          },
                        ),

                        // Similar Ads أسفل كما هو
                        if (similarHomeAds.isNotEmpty) ...[
                          SimilarAds(similarAds: similarHomeAds),
                          const MyDivider(),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),

        bottomNavigationBar: BlocBuilder<CarPartsDetailsCubit, CarPartsDetailsState>(
          builder: (context, state) {
            if (state is! CarPartsDetailsSuccess) return const SizedBox.shrink();
            final part = state.details;

            final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
            final ownerId = part.user.id;
            final isOwner = (myId != null && ownerId == myId);

            if (isOwner) {
              // 👈 زر التعديل محاط بحدود منقطة (استخدام ألوان ونصوص التطبيق)
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: DottedBorder(
                  color: Theme.of(context).primaryColor, // لون التطبيق الرئيسي
                  strokeWidth: 1,
                  dashPattern: const [6, 3],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text('تعديل الإعلان', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                      onPressed: () {
                        // // 👈 تنقل إلى شاشة تعديل قطع الغيار (اسم شاشة أخرى)
                        // NavX(context).pushNamed(Routes.carPartEditScreen, arguments: id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor, // لون التطبيق
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // 👈 الإجراءات الأصلية للمستخدمين غير المالكين
              final phone = part.phoneNumber;
              final ownerName = part.user.username?.toString() ?? '—';

              return CarBottomActions(
                onWhatsapp: () => launchWhatsApp(context, phone, message: 'مرحباً 👋 بخصوص إعلان: ${part.title}'),
                onCall: () => launchCaller(context, phone),
                onChat: () {
                  if (myId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يجب تسجيل الدخول أولاً لبدء المحادثة.')),
                    );
                    return;
                  }
                  if (isOwner) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكنك المحادثة مع نفسك.')),
                    );
                    return;
                  }
                  _startChat(context, ownerId, ownerName, part);
                },
                onAddBid: () async {
                  if (isOwner) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكنك تقديم سومة على إعلانك.')),
                    );
                    return;
                  }
                  await showOfferSheet(context, adId: id);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 56, width: double.infinity, color: Colors.white),
            Container(height: 250, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, width: 220, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 160, color: Colors.white),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(height: 72, width: double.infinity, color: Colors.white),
            ),
            const MyDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 12, child: ColoredBox(color: Colors.white)),
                        SizedBox(height: 6),
                        SizedBox(height: 12, child: ColoredBox(color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(width: 90, height: 28, color: Colors.white),
                ],
              ),
            ),
            const MyDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
            const MyDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  2,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              Container(height: 12, width: double.infinity, color: Colors.white),
                              const SizedBox(height: 6),
                              Container(height: 12, width: double.infinity, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(height: 48, width: double.infinity, color: Colors.white),
            ),
            const MyDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    2,
                        (i) => Padding(
                      padding: EdgeInsets.only(right: i == 1 ? 0 : 12, bottom: 16),
                      child: Container(width: 260, height: 140, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}