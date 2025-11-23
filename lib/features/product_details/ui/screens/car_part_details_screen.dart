import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/reminder.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/launcher.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/car_auction_details_cubit.dart';

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

import 'package:mushtary/features/messages/data/models/chat_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';

import '../../../../core/theme/colors.dart';
import '../../../create_ad/ui/screens/car_parts/car_part_create_ad_step2_screen.dart';
import '../../../create_ad/ui/screens/car_parts/logic/cubit/car_part_ads_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../home/data/models/home_data_model.dart';
import '../../../messages/ui/screens/chat_screen.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';

import '../../../user_profile/logic/cubit/profile_state.dart';
import '../logic/cubit/car_parts_details_cubit.dart';
import '../logic/cubit/car_parts_details_state.dart';
import '../widgets/car_details/widgets/car_details_panel.dart';
import '../widgets/car_details/widgets/car_part_add_comment_field.dart';
import '../widgets/car_details/widgets/car_part_comments_view.dart';
import '../widgets/car_part_details_images.dart';
import '../widgets/car_part_price.dart';
import '../widgets/car_part_specs_card.dart';
import '../widgets/offer_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mushtary/features/user_profile_id/ui/cubit/user_ads_cubit.dart';
import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

class CarPartDetailsScreen extends StatelessWidget {
  final int id;
  const CarPartDetailsScreen({super.key, required this.id});

  void _startChat(
      BuildContext context, int receiverId, String receiverName, dynamic partDetails) {
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
        BlocProvider<FavoritesCubit>(
            create: (_) => getIt<FavoritesCubit>()..fetchFavorites()),
        BlocProvider<CarPartsDetailsCubit>(
          create: (_) => getIt<CarPartsDetailsCubit>()..fetchCarPartDetails(id),
        ),
        BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<UserAdsCubit>(create: (_) => getIt<UserAdsCubit>()),
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

                  // تحويل الإعلانات المشابهة
                  final similarHomeAds = part.similarAds.map((s) {
                    return HomeAdModel.fromJson({
                      "id": s.id,
                      "title": s.title,
                      "price": s.price,
                      "name_ar": s.brandName,
                      "created_at": DateTime.now().toIso8601String(),
                      "username": "",
                      "image_urls": s.imageUrls,
                      "category_id": 2,
                    });
                  }).toList();

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
                      rating = (r is num)
                          ? r.toDouble()
                          : (double.tryParse(r.toString()) ?? 0);
                    }
                    final rc =
                        u.reviewsCount ?? u.reviews_count ?? u.ratings_count;
                    if (rc != null) {
                      reviewsCount =
                      (rc is num) ? rc.toInt() : int.tryParse(rc.toString()) ?? 0;
                    }
                  } catch (_) {}

                  return RefreshIndicator.adaptive(
                    onRefresh: ()async{
                      await context.read<CarPartsDetailsCubit>().fetchCarPartDetails(id);
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const ProductScreenAppBar(),
                          CarPartDetailsImages(
                            images: part.imageUrls,
                            adId: id,
                            favoriteType: 'ad',
                          ),
                          BlocBuilder<UserAdsCubit, UserAdsState>(
                            builder: (context, adsState) {
                              List<HomeAdModel> ownerHomeAds = [];
                              if (adsState is UserAdsSuccess) {
                                final publisherProducts =
                                adsState.ads.map((ad) => ad.toPublisherProduct()).toList();
                                ownerHomeAds = publisherProducts
                                    .where((p) => p.categoryId == 2)
                                    .map((p) => HomeAdModel.fromJson({
                                  "id": p.id,
                                  "title": p.title,
                                  "price": p.priceText ?? '',
                                  "name_ar": p.categoryLabel,
                                  "created_at": p.createdAt ??
                                      DateTime.now().toIso8601String(),
                                  "username": "",
                                  "image_urls": p.imageUrl != null
                                      ? [p.imageUrl]
                                      : <String>[],
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
                            createdAt: part.createdAt,
                          ),
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: CarPartPrice(priceText: part.price),
                          ),
                          const MyDivider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CurrentUserInfo(
                              ownerName: ownerName,
                              ownerPicture: ownerPicture,
                              isVerified: isVerified,
                              rating: rating,
                              reviewsCount: reviewsCount,
                              onTap: () {
                                NavX(context)
                                    .pushNamed(Routes.userProfileScreenId, arguments: ownerId);
                              },
                              onFollow: () {},
                            ),
                          ),
                          const MyDivider(),
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
                          CarPartCommentsView(comments: part.comments, offers:part.offers,),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CarPartAddCommentField(
                              adId: id,
                              onSuccessRefresh: () {
                                context
                                    .read<CarPartsDetailsCubit>()
                                    .fetchCarPartDetails(id);
                              },
                            ),
                          ),
                          const MyDivider(),
                          PromoButton(
                            onPressed: () async {
                              final myId =
                                  context.read<ProfileCubit>().user?.userId;
                              final isOwner =
                              (myId != null && part.user.id == myId);
                              if (isOwner) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text('لا يمكنك طلب تسويق لإعلانك.')),
                                );
                                return;
                              }
                              await showMarketingRequestSheet(context, adId: id);
                            },
                          ),
                          if (similarHomeAds.isNotEmpty) ...[
                            SimilarAds(similarAds: similarHomeAds),
                            const MyDivider(),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),

        // ✅ bottomNavigationBar مضبوط بدون فلاش
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileInitial ||
                profileState is ProfileLoading) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<CarPartsDetailsCubit, CarPartsDetailsState>(
              builder: (context, state) {
                if (state is! CarPartsDetailsSuccess)
                  return const SizedBox.shrink();

                final part = state.details;
                final myId = context.read<ProfileCubit>().user?.userId;
                final ownerId = part.user.id;
                final isOwner =
                (myId != null && ownerId != null && myId == ownerId);
                final phone = part.phoneNumber;
                final ownerName = part.user.username?.toString() ?? '—';

                if (isOwner) {
                  return Padding(
                    padding: EdgeInsets.all(16.h),
                    child: ElevatedButton(
                      onPressed: () async {
                        // استخدم القيم الموجودة فعلاً في الموديل فقط
                        // بدون الوصول لأي حقول غير مؤكدة لتفادي NoSuchMethodError
                        final detailsMap = <String, dynamic>{
                          'id': part.id,
                          'title': part.title ?? '',
                          // لو ما عندك part_name، نرسل العنوان كبديل
                          'part_name': (part.carPartDetail?.partName?.toString() ?? part.title ?? ''),
                          'description': part.description ?? '',
                          'price': part.price, // غالباً String، والكيوبت يحوّل لرقم
                          // نعيّن price_type افتراضياً 'fixed' (تقدر تغيّره داخل الشاشة)
                          'price_type': 'fixed',

                          // الصور القديمة (شبكة)
                          'image_urls': (part.imageUrls is List)
                              ? List<String>.from(part.imageUrls.map((e) => e.toString()))
                              : const <String>[],

                          // رقم الهاتف وطرق التواصل (لو غير موجودين يمشوا فاضيين)
                          'phone_number': part.phoneNumber?.toString(),
                          'communication_methods': (part.communicationMethods is List)
                              ? List<String>.from(part.communicationMethods.map((e) => e.toString()))
                              : const <String>[],

                          // قيم اختيارية ما نرسلها عشان ما نكسر التحديث
                          // city_id / region_id / latitude / longitude / allow_comments / allow_marketing_offers
                          // هتتاخد افتراضي من Cubit أو تقدر يحددها المستخدم في الخطوات
                        };

                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider<CarPartAdsCubit>(
                              create: (_) {
                                final c = getIt<CarPartAdsCubit>();
                                c.enterEditMode(part.id);
                                c.prefillFromDetails(detailsMap); // تعبئة آمنة
                                return c;
                              },
                              child: const CarPartCreateAdStep2Screen(),
                            ),
                          ),
                        );

                        // Refresh لو رجع true
                        if (updated == true) {
                          context.read<CarPartsDetailsCubit>().fetchCarPartDetails(id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'تحديث الإعلان',
                        style: TextStyle(
                          color: ColorsManager.primaryColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                // ✅ للمستخدم العادي
                return CarBottomActions(
                  onWhatsapp: () => launchWhatsApp(
                    context,
                    phone,
                    message: 'مرحباً 👋 بخصوص إعلان: ${part.title}',
                  ),
                  onCall: () => launchCaller(context, phone),
                  onChat: () {
                    if (myId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text('يجب تسجيل الدخول أولاً لبدء المحادثة.')),
                      );
                      return;
                    }
                    if (isOwner) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('لا يمكنك المحادثة مع نفسك.')),
                      );
                      return;
                    }
                    _startChat(context, ownerId, ownerName, part);
                  },
                  onAddBid: () async {
                    if (isOwner) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text('لا يمكنك تقديم سومة على إعلانك.')),
                      );
                      return;
                    }
                    await showOfferSheet(context, adId: id);
                  },
                );
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
          children: [
            Container(height: 56, color: Colors.white),
            Container(height: 250, color: Colors.white),
          ],
        ),
      ),
    );
  }
}