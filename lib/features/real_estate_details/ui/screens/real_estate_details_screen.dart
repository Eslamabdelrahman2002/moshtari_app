import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/features/product_details/ui/widgets/car_details/widgets/car_bottom_actions.dart';
import 'package:mushtary/features/product_details/ui/widgets/marketing_request_sheet.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_more_details.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_state_details_app_bar.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_details_panel.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_price.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_info_description.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_details_product_images.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_product_info_grid_view.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_promo_button.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_reminder.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_story_and_title.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/helpers/launcher.dart';
import '../../../create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_cubit.dart';
import '../../../create_ad/ui/screens/real_estate/real_estate_create_ad_flow.dart';
import '../../../messages/data/models/chat_model.dart';
import '../../../messages/data/repo/messages_repo.dart';
import '../../../messages/ui/widgets/chats/chat_initiation_sheet.dart';
import '../../../product_details/ui/widgets/offer_sheet.dart';
import '../../../user_profile/logic/cubit/profile_state.dart';
import '../../../user_profile_id/ui/cubit/user_ads_cubit.dart';
import '../../date/model/real_estate_details_model.dart' as re;
import '../widgets/real_estate_comments_view.dart';
import '../widgets/real_estate_comment_composer.dart';
import '../../logic/cubit/real_estate_details_cubit.dart';
import '../../logic/cubit/real_estate_details_state.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../widgets/real_estate_current_user_info.dart';
import '../widgets/real_estate_similar_ads.dart';
import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

class RealEstateDetailsScreen extends StatelessWidget {
  final int id;
  const RealEstateDetailsScreen({super.key, required this.id});

  void _startChat(BuildContext context, int receiverId, String receiverName) {
    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (initialMessage) async {
        final repo = getIt<MessagesRepo>();
        final conversationId = await repo.initiateChat(receiverId);

        if (conversationId != null) {
          final chatModel = MessagesModel(
            conversationId: conversationId,
            partnerUser:
            UserModel(id: receiverId, name: receiverName),
            lastMessage: initialMessage,
          );
          NavX(context)
              .pushNamed(Routes.chatScreen, arguments: chatModel);

          await Future.delayed(const Duration(milliseconds: 500));

          final body = SendMessageRequestBody(
            receiverId: receiverId,
            messageContent: initialMessage,
            listingId: id,
          );
          await repo.sendMessage(body, conversationId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تعذر بدء المحادثة الآن.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RealEstateDetailsCubit>(
          create: (_) =>
          getIt<RealEstateDetailsCubit>()..getRealEstateDetails(id),
        ),
        BlocProvider<CommentSendCubit>(
          create: (_) => getIt<CommentSendCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) =>
          getIt<FavoritesCubit>()..fetchFavorites(),
        ),
        BlocProvider<UserAdsCubit>(
          create: (_) => getIt<UserAdsCubit>(),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<RealEstateDetailsCubit,
              RealEstateDetailsState>(
            listener: (context, state) {
              if (state is RealEstateDetailsSuccess) {
                final ownerId = state.details.user?.id;
                if (ownerId != null) {
                  context
                      .read<UserAdsCubit>()
                      .fetchUserAds(ownerId);
                }
              }
            },
            child: BlocBuilder<RealEstateDetailsCubit,
                RealEstateDetailsState>(
              builder: (context, state) {
                if (state is RealEstateDetailsLoading) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (state is RealEstateDetailsFailure) {
                  return Center(child: Text(state.message));
                }
                if (state is RealEstateDetailsSuccess) {
                  final property = state.details;
                  final comments = property.comments;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 72.h),
                    child: Column(
                      children: [
                        const RealStateDetailsAppBar(),
                        RealEstateDetailsProductImages(
                          images: property.imageUrls,
                          adId: id,
                          favoriteType: 'ad',
                        ),
                        BlocBuilder<UserAdsCubit, UserAdsState>(
                          builder: (context, adsState) {
                            List<PublisherProductModel> storyItems =
                            [];
                            if (adsState is UserAdsSuccess) {
                              storyItems = adsState.ads
                                  .map((ad) => ad.toPublisherProduct())
                                  .toList();
                            }
                            return RealEstateStoryAndTitleWidget(
                              title: property.title,
                              similarAds: storyItems,
                            );
                          },
                        ),
                        DetailsPanel(
                          cityName: property.city,
                          areaName: property.region,
                          createdAt: property.createdAt,
                        ),
                        verticalSpace(16),
                        RealEstatePrice(price: property.price),
                        const MyDivider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          child: RealEstateCurrentUserInfo(
                            ownerName: property.user?.username ?? 'N/A',
                            ownerPicture:
                            property.user?.profilePictureUrl,
                            userTitle:
                            property.user?.username ?? 'وسيط عقاري',
                            onTap: () {
                              final ownerIdRaw = property.user?.id;
                              final ownerId = int.tryParse(
                                  ownerIdRaw.toString());
                              if (ownerId != null) {
                                NavX(context).pushNamed(
                                  Routes.userProfileScreenId,
                                  arguments: ownerId,
                                );
                              }
                            },
                          ),
                        ),
                        verticalSpace(8),
                        const MyDivider(),
                        RealEstateProductInfoGridView(
                          area: property.realEstateDetails?.areaM2,
                          bathrooms:
                          property.realEstateDetails?.bathroomCount,
                          numberOfStreetFrontages:
                          property.realEstateDetails?.streetCount,
                          rooms: property.realEstateDetails?.roomCount,
                          streetWidth:
                          property.realEstateDetails?.streetWidth,
                          windDirection:
                          property.realEstateDetails?.facade,
                        ),
                        RealEstateInfoDescription(
                            description: property.description),
                        verticalSpace(20),
                        RealEstateMoreDetails(
                          details: property.realEstateDetails,
                          city: property.city,
                          region: property.region,
                        ),
                        verticalSpace(20),
                        const Reminder(),
                        const MyDivider(),
                        RealEstateCommentsView(comments: comments, offers: property.offers,),
                        verticalSpace(12),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 16.w),
                          child: RealEstateCommentComposer(
                            adId: id,
                            onSuccessRefresh: () {
                              context
                                  .read<RealEstateDetailsCubit>()
                                  .getRealEstateDetails(id);
                            },
                          ),
                        ),
                        const MyDivider(),
                        PromoButton(
                          onPressed: () async {
                            final myId = context
                                .read<ProfileCubit>()
                                .user
                                ?.userId;
                            final isOwner = (myId != null &&
                                property.user?.id == myId);
                            if (isOwner) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('لا يمكنك طلب تسويق لإعلانك.')),
                              );
                              return;
                            }
                            await showMarketingRequestSheet(
                                context,
                                adId: id);
                          },
                        ),
                        if (property.similarAds.isNotEmpty) ...[
                          RealEstateSimilarAds(
                            items: property.similarAds,
                            onTapAd: (ad) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RealEstateDetailsScreen(id: ad.id),
                                ),
                              );
                            },
                          ),
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

        // ✅ bottomNavigationBar بدون فلاش بين حالتين
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<RealEstateDetailsCubit,
                RealEstateDetailsState>(
              builder: (context, state) {
                if (state is! RealEstateDetailsSuccess)
                  return const SizedBox.shrink();

                final property = state.details;
                final myId =
                    context.read<ProfileCubit>().user?.userId;
                final ownerId = property.user?.id;
                final isOwner = (myId != null &&
                    ownerId != null &&
                    myId == ownerId);

                final phone = property.user?.phoneNumber;

                // ✅ للمالك مباشرة بعد تحميل الملف الشخصي
                if (isOwner) {
                  return Padding(
                  padding: EdgeInsets.all(16.h),
                  child: ElevatedButton(
                    onPressed: () {
                      final st = context.read<RealEstateDetailsCubit>().state;
                      if (st is! RealEstateDetailsSuccess) return;
                      final details = st.details;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider<RealEstateAdsCubit>(
                            create: (_) => getIt<RealEstateAdsCubit>()..startEditingFromDetails(details),
                            child: const RealEstateCreateAdFlow(isEditing: true),
                          ),
                        ),
                      );
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
                    message:
                    'مرحباً 👋 بخصوص إعلان: ${property.title}',
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
                            content:
                            Text('لا يمكنك المحادثة مع نفسك.')),
                      );
                      return;
                    }
                    if (ownerId != null) {
                      _startChat(context, ownerId,
                          property.user?.username ?? 'البائع');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text('لا يمكن تحديد هوية البائع.')),
                      );
                    }
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
}