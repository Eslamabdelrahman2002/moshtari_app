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
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../home/data/models/home_data_model.dart';
import '../../../messages/data/models/chat_model.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';
import '../../../user_profile/logic/cubit/profile_state.dart';
import '../../../user_profile_id/ui/cubit/user_ads_cubit.dart';
import '../logic/cubit/other_ad_details_cubit.dart';
import '../logic/cubit/other_ad_details_state.dart';
import '../widgets/OtherAdDetailsImages.dart';
import '../widgets/car_details/widgets/car_details_panel.dart';
import '../widgets/car_details/widgets/other_ad_add_comment_field.dart';
import '../widgets/car_details/widgets/other_ad_comments_view.dart';
import '../widgets/car_part_price.dart';
import '../widgets/offer_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

// ✅ إضافات شاشة التعديل
import '../../../create_ad/ui/screens/other/other_ad_view_screen.dart';
import '../../../create_ad/ui/screens/other/logic/cubit/other_ads_cubit.dart';
import '../../../../core/theme/colors.dart';

class OtherAdDetailsScreen extends StatefulWidget {
  final int id;
  const OtherAdDetailsScreen({super.key, required this.id});

  @override
  State<OtherAdDetailsScreen> createState() => _OtherAdDetailsScreenState();
}

class _OtherAdDetailsScreenState extends State<OtherAdDetailsScreen> {
  String _statusLabel(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v == 'used' || v == 'مستخدم' || v == 'مستعملة') return 'مستعملة';
    if (v == 'new' || v == 'جديد' || v == 'جديدة') return 'جديدة';
    return '';
  }

  void _startChat(BuildContext context, int receiverId, String receiverName,) {
    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (initialMessage) async {
        final repo = getIt<MessagesRepo>();
        final conversationId = await repo.initiateChat(receiverId);
        if (conversationId != null) {
          final chatModel = MessagesModel(
            conversationId: conversationId,
            partnerUser: UserModel(id: receiverId, name: receiverName),
            lastMessage: initialMessage,
          );
          NavX(context).pushNamed(Routes.chatScreen, arguments: chatModel);
          await Future.delayed(const Duration(milliseconds: 500));
          final body = SendMessageRequestBody(
            receiverId: receiverId,
            messageContent: initialMessage,
            listingId: widget.id,
          );
          await repo.sendMessage(body, conversationId);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('تعذر بدء المحادثة الآن.')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()..fetchFavorites()),
        BlocProvider<OtherAdDetailsCubit>(
          create: (_) => getIt<OtherAdDetailsCubit>()..fetchOtherAdDetails(widget.id),
        ),
        BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()..loadProfile()),
        BlocProvider<UserAdsCubit>(create: (_) => getIt<UserAdsCubit>()),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OtherAdDetailsCubit, OtherAdDetailsState>(
            builder: (context, state) {
              if (state is OtherAdDetailsLoading) {
                return _buildLoadingSkeleton(context);
              }
              if (state is OtherAdDetailsFailure) {
                return Center(child: Text(state.message));
              }
              if (state is OtherAdDetailsSuccess) {
                final ad = state.details;
                final images = ad.imageUrls;
                final status = _statusLabel(ad.conditionType);

                final similarHomeAds = ad.similarAds.map((s) {
                  return HomeAdModel.fromJson({
                    "id": s.id,
                    "title": s.title,
                    "price": s.price,
                    "name_ar": ad.categoryNameAr,
                    "created_at": DateTime.now().toIso8601String(),
                    "username": ad.username,
                    "image_urls": s.imageUrls,
                    "condition": ad.conditionType ?? '',
                  });
                }).toList();

                String ownerName = ad.username?.toString() ?? '';
                String? ownerPicture;
                bool isVerified = false;
                double rating = 0;
                int reviewsCount = 0;

                try {
                  final dyn = ad as dynamic;
                  final u = dyn.user;
                  if (u != null) {
                    ownerName = ownerName.isNotEmpty ? ownerName : (u.username?.toString() ?? u.name?.toString() ?? '—');
                    ownerPicture = (u.profilePicture ?? u.profile_photo_url ?? u.avatar ?? u.picture ?? u.imageUrl ?? u.photo)?.toString();
                    isVerified = (u.isVerified == true) || (u.verified == true) || (u.is_verified == true);
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

                return RefreshIndicator.adaptive(
                  onRefresh: ()async{
                    await context.read<OtherAdDetailsCubit>().fetchOtherAdDetails(widget.id);
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(children: [
                      const ProductScreenAppBar(),
                      OtherAdDetailsImages(
                        images: images,
                        adId: widget.id,
                        favoriteType: 'ad',
                        status: status,
                      ),
                      BlocBuilder<UserAdsCubit, UserAdsState>(
                        builder: (context, adsState) {
                          List<HomeAdModel> ownerHomeAds = [];
                          if (adsState is UserAdsSuccess) {
                            final List<PublisherProductModel> publisherProducts = adsState.ads.map((a) => a.toPublisherProduct()).toList();
                            ownerHomeAds = publisherProducts
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
                            title: ad.title,
                            similarAds: ownerHomeAds,
                          );
                        },
                      ),
                      CarDetailsPanel(
                        city: ad.cityName,
                        region: ad.regionName,
                        createdAt: ad.postedAt,
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: CarPartPrice(priceText: ad.price),
                      ),
                      const MyDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CurrentUserInfo(
                          ownerName: ownerName.isEmpty ? '—' : ownerName,
                          ownerPicture: ownerPicture,
                          isVerified: isVerified,
                          rating: rating,
                          reviewsCount: reviewsCount,
                          onTap: () {
                            final ownerId = ad.userId;
                            if (ownerId != null) {
                              NavX(context).pushNamed(Routes.userProfileScreenId, arguments: ownerId);
                            }
                          },
                          onFollow: () {},
                        ),
                      ),
                      const MyDivider(),
                      InfoDescription(description: ad.description.isNotEmpty ? ad.description : 'لا يوجد'),
                      const MyDivider(),
                      const Reminder(),
                      const MyDivider(),
                      OtherAdCommentsView(comments: ad.comments,offers: ad.offers,),
                      verticalSpace(12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OtherAdAddCommentField(
                          adId: widget.id,
                          onSuccessRefresh: () {
                            context.read<OtherAdDetailsCubit>().fetchOtherAdDetails(widget.id);
                          },
                        ),
                      ),
                      const MyDivider(),
                      PromoButton(onPressed: () async {
                        final myId = context.read<ProfileCubit>().user?.userId;
                        final isOwner = (myId != null && ad.userId == myId);
                        if (isOwner) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('لا يمكنك طلب تسويق لإعلانك.')),
                          );
                          return;
                        }
                        await showMarketingRequestSheet(context, adId: widget.id);
                      }),
                      if (similarHomeAds.isNotEmpty)
                        ...[
                          SimilarAds(similarAds: similarHomeAds),
                          const MyDivider(),
                        ],
                    ]),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading || profileState is ProfileInitial) {
              return const SizedBox.shrink();
            }
            return BlocBuilder<OtherAdDetailsCubit, OtherAdDetailsState>(
              builder: (context, state) {
                if (state is! OtherAdDetailsSuccess) return const SizedBox.shrink();
                final ad = state.details;
                final myId = context.read<ProfileCubit>().user?.userId;
                final ownerId = ad.userId;
                final isOwner = (myId != null && ownerId != null && myId == ownerId);
                final phone = ad.userPhone ?? ad.userPhone;
                final ownerName = ad.username ?? '';

                if (isOwner) {
                  return Padding(
                    padding: EdgeInsets.all(16.h),
                    child: ElevatedButton(
                        onPressed: () async {
                          final dyn = ad as dynamic;

                          // دالة آمنة ترجع nullable
                          T? _tryGet<T>(T? Function() f) {
                            try {
                              return f();
                            } catch (_) {
                              return null;
                            }
                          }

                          int? _int(dynamic v) {
                            if (v == null) return null;
                            if (v is int) return v;
                            if (v is num) return v.toInt();
                            return int.tryParse(v.toString());
                          }

                          num? _num(dynamic v) {
                            if (v == null) return null;
                            if (v is num) return v;
                            return num.tryParse(v.toString().replaceAll(',', '').trim());
                          }

                          double? _dbl(dynamic v) {
                            if (v == null) return null;
                            if (v is double) return v;
                            if (v is num) return v.toDouble();
                            return double.tryParse(v.toString());
                          }

                          final id = _tryGet(() => dyn.id) ?? widget.id;

                          final title = _tryGet<String>(() => dyn.title?.toString()) ?? '';
                          final description = _tryGet<String>(() => dyn.description?.toString()) ?? '';

                          final priceType = _tryGet<String>(() => dyn.priceType?.toString())
                              ?? _tryGet<String>(() => dyn.price_type?.toString())
                              ?? 'fixed';
                          final price = _num(_tryGet(() => dyn.price));

                          final cityId = _int(_tryGet(() => dyn.cityId) ?? _tryGet(() => dyn.city_id));
                          final regionId = _int(_tryGet(() => dyn.regionId) ?? _tryGet(() => dyn.region_id));

                          final latitude = _dbl(_tryGet(() => dyn.latitude));
                          final longitude = _dbl(_tryGet(() => dyn.longitude));

                          final allowComments = (_tryGet(() => dyn.allowComments) == true) || (_tryGet(() => dyn.allow_comments) == true);
                          final allowMarketingOffers = (_tryGet(() => dyn.allowMarketingOffers) == true) ||
                              (_tryGet(() => dyn.allow_marketing_offers) == true);

                          final phoneNumber = _tryGet<String>(() => dyn.userPhone?.toString())
                              ?? _tryGet<String>(() => dyn.phoneNumber?.toString())
                              ?? '';

                          final List<String> comms = (() {
                            final c1 = _tryGet(() => dyn.communicationMethods);
                            final c2 = _tryGet(() => dyn.communication_methods);
                            final src = (c1 is List ? c1 : (c2 is List ? c2 : const []));
                            return List<String>.from(src.map((e) => e.toString()));
                          })();

                          final List<String> imageUrls = (() {
                            final i1 = _tryGet(() => dyn.imageUrls);
                            final i2 = _tryGet(() => dyn.image_urls);
                            final src = (i1 is List ? i1 : (i2 is List ? i2 : const []));
                            return List<String>.from(src.map((e) => e.toString()));
                          })();

                          final c = getIt<OtherAdsCubit>()
                            ..enterEditMode(id as int)
                            ..setTitle(title)
                            ..setDescription(description)
                            ..setPriceType(priceType)
                            ..setPrice(price)
                            ..setRegionId(regionId)
                            ..setCityId(cityId)
                            ..setPhone(phoneNumber)
                            ..setAllowComments(allowComments)
                            ..setAllowMarketing(allowMarketingOffers)
                            ..setCommunicationMethods(comms)
                            ..setExistingImageUrls(imageUrls);

                          final updated = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider<OtherAdsCubit>(
                                create: (_) => c,
                                child: const OtherAdViewScreen(),
                              ),
                            ),
                          );

                          if (updated == true) {
                            if (!mounted) return;
                            context.read<OtherAdDetailsCubit>().fetchOtherAdDetails(widget.id);
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
                } else {
                  return CarBottomActions(
                    onWhatsapp: () => launchWhatsApp(context, phone, message: 'مرحباً 👋 بخصوص إعلان: ${ad.title}'),
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
                      if (ownerId != null) {
                        _startChat(context, ownerId, ownerName.isEmpty ? 'البائع' : ownerName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('لا يمكن تحديد هوية البائع.')),
                        );
                      }
                    },
                    onAddBid: () async {
                      if (isOwner) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('لا يمكنك تقديم سومة على إعلانك.')),
                        );
                        return;
                      }
                      await showOfferSheet(context, adId: widget.id);
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString().replaceAll(',', '').trim());
  }

  Widget _buildLoadingSkeleton(BuildContext context) => Skeletonizer(
    enabled: true,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Container(height: 56, color: Colors.white),
          Container(height: 285, color: Colors.white),
        ],
      ),
    ),
  );
}