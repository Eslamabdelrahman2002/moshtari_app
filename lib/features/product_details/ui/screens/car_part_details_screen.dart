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

import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

import '../../../../core/router/routes.dart';

// الشات
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';

// Favorites
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';

// موديل الهوم لتمرير الإعلانات المشابهة للقسمين (Story + SimilarAds)
import '../../../home/data/models/home_data_model.dart';

// برومو مثل العقار
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';

// Cubit/details
import '../logic/cubit/car_parts_details_cubit.dart';
import '../logic/cubit/car_parts_details_state.dart';

// التعليقات + المؤلف + الصور
import '../widgets/car_details/widgets/car_part_add_comment_field.dart';
import '../widgets/car_details/widgets/car_part_comments_view.dart';
import '../widgets/car_part_details_images.dart';
import '../widgets/car_part_specs_card.dart';
import '../widgets/offer_sheet.dart';

import 'package:skeletonizer/skeletonizer.dart';

class CarPartDetailsScreen extends StatelessWidget {
  final int id;
  const CarPartDetailsScreen({super.key, required this.id});

  // بدء المحادثة: يبدأ الشات فقط بدون إرسال رسالة تلقائياً
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
      ],
      child: Scaffold(
        body: SafeArea(
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

                // حوّل الإعلانات المشابهة إلى HomeAdModel لاستخدامها في Story + SimilarAds
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

                // بيانات المالك
                final ownerId = part.user.id as int;
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

                      // الصور (نفس العقار)
                      CarPartDetailsImages(
                        images: part.imageUrls,
                        adId: id,
                        favoriteType: 'ad',
                      ),

                      // الستوري + العنوان (نفس العقار/السيارات)
                      StoryAndTitleWidget(
                        title: part.title,
                        similarAds: similarHomeAds,
                      ),

                      // البانيل: موقع + وقت + سعر
                      DetailsPanel(
                        location: "${part.city} - ${part.region}",
                        time: part.createdAt,
                        price: part.price,
                      ),

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
                            final ownerId = part.user.id;
                            if (ownerId != null) {
                              NavX(context).pushNamed( // ✅ استخدام NavX
                                Routes.userProfileScreenId,
                                arguments: ownerId,
                              );
                            }
                          },
                          onFollow: () {},
                        ),
                      ),
                      const MyDivider(),

                      // معلومات إضافية
                      CarPartSpecsCardElevated(
                        condition: part.carPartDetail.condition,
                        brand: part.carPartDetail.brandName,
                        supportedModels: part.carPartDetail.supportedModels,
                        elevation: 5, // لو حاب تكبّر الظل شوي
                      ),

                      InfoDescription(description: part.description),
                      const MyDivider(),

                      const Reminder(),
                      const MyDivider(),

                      // التعليقات
                      CarPartCommentsView(comments: part.comments),

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

                      // سوق للإعلان (Marketing)
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

                      // إعلانات مشابهة (نفس اللي فوق لكن نعيد استخدامها هنا)
                      SimilarAds(similarAds: similarHomeAds),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<CarPartsDetailsCubit, CarPartsDetailsState>(
          builder: (context, state) {
            if (state is! CarPartsDetailsSuccess) return const SizedBox.shrink();
            final part = state.details;

            final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
            final ownerId = part.user.id;
            final isOwner = (myId != null && ownerId == myId);

            final phone = part.phoneNumber;
            final ownerName = part.user.username?.toString() ?? '—';

            return CarBottomActions(
              onWhatsapp: () => launchWhatsApp(
                context,
                phone,
                message: 'مرحباً 👋 بخصوص إعلان: ${part.title}',
              ),
              onCall: () => launchCaller(context, phone),

              // محادثة
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

              // أضف سومتك
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
            Container(height: 56.h, width: double.infinity, color: Colors.white),
            Container(height: 250.h, width: double.infinity, color: Colors.white),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18.h, width: 220.w, color: Colors.white),
                  SizedBox(height: 8.h),
                  Container(height: 12.h, width: 160.w, color: Colors.white),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(height: 72.h, width: double.infinity, color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(width: 44.w, height: 44.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12.h, width: 160.w, color: Colors.white),
                        SizedBox(height: 6.h),
                        Container(height: 12.h, width: 120.w, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(width: 90.w, height: 28.h, color: Colors.white),
                ],
              ),
            ),
            const MyDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Container(height: 12.h, width: double.infinity, color: Colors.white),
                  SizedBox(height: 6.h),
                  Container(height: 12.h, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
            const MyDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: List.generate(
                  2,
                      (i) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Container(width: 36.w, height: 36.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            children: [
                              Container(height: 12.h, width: double.infinity, color: Colors.white),
                              SizedBox(height: 6.h),
                              Container(height: 12.h, width: double.infinity, color: Colors.white),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(height: 48.h, width: double.infinity, color: Colors.white),
            ),
            const MyDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    2,
                        (i) => Padding(
                      padding: EdgeInsets.only(right: i == 1 ? 0 : 12.w, bottom: 16.h),
                      child: Container(width: 260.w, height: 140.h, color: Colors.white),
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