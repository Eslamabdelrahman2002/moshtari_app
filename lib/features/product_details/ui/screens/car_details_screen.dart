// lib/features/product_details/ui/screens/car_details_screen.dart

import 'package:dotted_border/dotted_border.dart'; // 👈 أضف هذا الـ import (package: dotted_border)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/screens/product_details_screen.dart';
import 'package:mushtary/features/product_details/ui/widgets/marketing_request_sheet.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import 'package:mushtary/core/utils/helpers/launcher.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/features/messages/data/models/chat_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import '../../../../core/theme/colors.dart';
import '../../../create_ad/ui/screens/cars/create_car_ad_flow.dart';
import '../../../create_ad/ui/screens/cars/logic/cubit/car_ads_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';
import '../../../user_profile/logic/cubit/profile_state.dart';
import '../../../user_profile_id/ui/cubit/user_ads_cubit.dart';
import '../../data/model/car_details_model.dart';
import '../logic/cubit/car_details_cubit.dart';
import '../widgets/car_details/widgets/car_add_comment_field.dart';
import '../widgets/car_details/widgets/car_comments_view.dart';
import '../widgets/car_details/widgets/car_details_app_bar.dart';
import '../widgets/car_details/widgets/car_details_images.dart';
import '../widgets/car_details/widgets/car_details_panel.dart';
import '../widgets/car_details/widgets/car_info_description.dart';
import '../widgets/car_details/widgets/car_info_grid_view.dart';
import '../widgets/car_details/widgets/car_owner_info.dart';
import '../widgets/car_details/widgets/car_price.dart';
import '../widgets/car_details/widgets/car_similar_ads.dart';
import '../widgets/car_details/widgets/car_story_and_title.dart';
import '../widgets/car_details/widgets/car_bottom_actions.dart';
import '../widgets/offer_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

class CarDetailsScreen extends StatelessWidget {
  final int id;

  const CarDetailsScreen({super.key, required this.id});

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
            partnerUser: UserModel(id: receiverId, name: receiverName),
            lastMessage: initialMessage,
          );
          NavX(context).pushNamed(Routes.chatScreen, arguments: chatModel);

          await Future.delayed(const Duration(milliseconds: 500));

          final body = SendMessageRequestBody(
            receiverId: receiverId,
            messageContent: initialMessage,
            listingId: id, // استخدام Listing ID من الشاشة
          );
          await repo.sendMessage(body, conversationId);
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
        BlocProvider<CarDetailsCubit>(
          create: (_) => getIt<CarDetailsCubit>()..fetchCarDetails(id),
        ),
        BlocProvider<CommentSendCubit>(
          create: (_) => getIt<CommentSendCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()..fetchFavorites()),
        // 👈 إضافة Cubit لإعلانات الـ owner فقط (للـ story)
        BlocProvider<UserAdsCubit>(
          create: (_) => getIt<UserAdsCubit>(),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<CarDetailsCubit, CarDetailsState>(
            // 👈 BlocListener لاستدعاء fetch عند الوصول إلى success (مرة واحدة فقط)
            listener: (context, state) {
              if (state is CarDetailsSuccess) {
                final ownerId = state.details.userId;
                if (ownerId != null) {
                  context.read<UserAdsCubit>().fetchUserAds(ownerId); // 👈 جلب إعلانات الـ owner فقط للـ story
                }
              }
            },
            child: BlocBuilder<CarDetailsCubit, CarDetailsState>(
              builder: (context, state) {
                if (state is CarDetailsLoading) {
                  return _buildLoadingSkeleton(context);
                } else if (state is CarDetailsFailure) {
                  return Center(child: Text(state.error, textAlign: TextAlign.center));
                } else if (state is CarDetailsSuccess) {
                  final car = state.details;
                  final List<SimilarCarAdModel> similar = car.similarAds ?? [];

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 72.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CarDetailsAppBar(),
                        CarDetailsImages( images: car.imageUrls,

                          adId: id,
                          favoriteType: 'ad', // مثل العقار
                        ),

                        // 👈 عرض إعلانات الـ owner فقط في الـ story (تجاهل المزادات)
                        BlocBuilder<UserAdsCubit, UserAdsState>(
                          builder: (context, adsState) {
                            List<PublisherProductModel> storyItems = [];
                            if (adsState is UserAdsSuccess) {
                              storyItems = adsState.ads.map((ad) => ad.toPublisherProduct()).toList();
                            }
                            // 👈 تجاهل المزادات تمامًا هنا
                            return CarStoryAndTitle(
                              title: car.title ?? '',
                              similarAds: storyItems, // 👈 إعلانات الـ owner فقط
                              onOpenDetails: (product) {
                                // 👈 تنقل ذكي بناءً على نوع المنتج (للإعلانات فقط)
                                if (product.categoryId == 1 || product.categoryId == 5) { // سيارة
                                  Navigator.of(context).pushNamed(
                                    Routes.carDetailsScreen,
                                    arguments: product.id,
                                  );
                                }

                              },
                            );
                          },
                        ),

                        CarDetailsPanel(
                          city: car.city,
                          region: car.region,
                          createdAt: DateTime.tryParse(car.createdAt) ?? DateTime.now(),
                        ),
                        verticalSpace(16),
                        Center(child: CarPrice(price: double.tryParse(car.price ?? '0'))),
                        const MyDivider(),
                        Center(
                          child: CarInfoGridView(
                            transmission: car.transmissionType,
                            mileage: car.mileage,
                            cylinder: car.cylinderCount,
                            driveType: car.driveType,
                            horsepower: car.horsepower,
                            fuelType: car.fuelType,
                            vehicleType: car.vehicleType,
                          ),
                        ),
                        CarInfoDescription(
                          description: car.description.isEmpty ? 'لا يوجد' : car.description,
                        ),
                        verticalSpace(16),
                        CarOwnerInfo(
                          username: car.username.isEmpty ? 'مستخدم' : car.username,
                          phone: car.userPhoneNumber,
                          onTap: () {
                            final ownerId = car.userId;
                            if (ownerId != null) {
                              NavX(context).pushNamed( // ✅ استخدام NavX
                                Routes.userProfileScreenId,
                                arguments: ownerId,
                              );
                            }
                          },
                        ),
                        const MyDivider(),
                        CarCommentsView(comments: car.comments, offers:car.offers,),
                        verticalSpace(12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: CarAddCommentField(
                            adId: id,
                            onSuccessRefresh: () {
                              context.read<CarDetailsCubit>().fetchCarDetails(id);
                            },
                          ),
                        ),
                        const MyDivider(),

                        // سوق للإعلان (Marketing)
                        Center(
                          child: PromoButton(
                            onPressed: () async {
                              final myId = context.read<ProfileCubit>().user?.userId;
                              final isOwner = (myId != null && car.userId != null && myId == car.userId);
                              if (isOwner) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('لا يمكنك طلب تسويق لإعلانك.')),
                                );
                                return;
                              }
                              await showMarketingRequestSheet(context, adId: id);
                            },
                          ),
                        ),

                        // 👈 عرض similarAds كما هو (أسفل الشاشة)
                        if (similar.isNotEmpty) ...[
                          CarSimilarAds(
                            similarAds: similar, // 👈 كما هو
                            onTapAd: (ad) {
                              NavX(context).pushNamed(Routes.carDetailsScreen, arguments: ad.id);
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
        bottomNavigationBar: BlocBuilder<CarDetailsCubit, CarDetailsState>(
          builder: (context, carState) {
            if (carState is! CarDetailsSuccess) return const SizedBox.shrink();
            final car = carState.details;
            return BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                if (profileState is ProfileLoading) {
                  return const SizedBox.shrink();
                }

                final profileCubit = context.watch<ProfileCubit>();
                final myId = profileCubit.user?.userId;
                final ownerId = car.userId;
                final isOwner = (myId != null && ownerId != null && myId == ownerId);

                final phone = car.userPhoneNumber;
                final ownerName = car.username;

                if (isOwner) {
                  // عرض كونتينر التعديل للمالك فقط (بدون تكرار)
                  return  Padding(
                    padding: EdgeInsets.all(16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider<CarAdsCubit>(
                                  create: (_) {
                                    final c = getIt<CarAdsCubit>();
                                    c.enterEditMode(id);
                                    // car هو تفاصيل الإعلان الموجودة لديك في هذه الشاشة
                                    c.prefillFromDetails(car); // ✅ تعبئة القيم القديمة
                                    return c;
                                  },
                                  child: const CreateCarAdFlow(isEditing: true),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.white, // لون زر التطبيق
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'تحديث الاعلان', // نص التطبيق
                            style: TextStyle(color: ColorsManager.primaryColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        ),

                      ],
                    ),
                  );
                } else {
                  // عرض CarBottomActions للعميل العادي فقط
                  return CarBottomActions(
                    onWhatsapp: () => launchWhatsApp(
                      context,
                      phone,
                      message: 'مرحباً 👋 بخصوص إعلان: ${car.title}',
                    ),
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
                      await showOfferSheet(context, adId: id);
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

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 72.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar placeholder
            Container(height: 56.h, width: double.infinity, color: Colors.white),
            // Images placeholder
            Container(height: 285.h, width: double.infinity, color: Colors.white),
            verticalSpace(12),

            // Title placeholders
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18.h, width: 220.w, color: Colors.white),
                  verticalSpace(8),
                  Container(height: 12.h, width: 160.w, color: Colors.white),
                ],
              ),
            ),
            verticalSpace(12),

            // Panel placeholders
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(child: Container(height: 60.h, color: Colors.white)),
                  horizontalSpace(8),
                  Expanded(child: Container(height: 60.h, color: Colors.white)),
                  horizontalSpace(8),
                  Expanded(child: Container(height: 60.h, color: Colors.white)),
                ],
              ),
            ),
            verticalSpace(12),

            // Price placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(height: 52.h, width: double.infinity, color: Colors.white),
            ),
            verticalSpace(12),
            const MyDivider(),

            // Info grid placeholders (6 items)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: List.generate(
                  6,
                      (i) => Container(
                    width: (MediaQuery.of(context).size.width - 16.w * 2 - 12.w) / 2,
                    height: 78.h,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            verticalSpace(12),

            // Description placeholders
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Container(height: 12.h, width: double.infinity, color: Colors.white),
                  verticalSpace(6),
                  Container(height: 12.h, width: double.infinity, color: Colors.white),
                  verticalSpace(6),
                  Container(height: 12.h, width: 200.w, color: Colors.white),
                ],
              ),
            ),
            verticalSpace(12),

            // Owner info placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12.h, width: 160.w, color: Colors.white),
                        verticalSpace(6),
                        Container(height: 12.h, width: 120.w, color: Colors.white),
                      ],
                    ),
                  ),
                  Container(width: 90.w, height: 28.h, color: Colors.white),
                ],
              ),
            ),
            verticalSpace(12),
            const MyDivider(),

            // Comments placeholder (2 items)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: List.generate(
                  2,
                      (i) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        horizontalSpace(8),
                        Expanded(
                          child: Column(
                            children: [
                              Container(height: 12.h, width: double.infinity, color: Colors.white),
                              verticalSpace(6),
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
            verticalSpace(12),

            // Add comment field placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(height: 48.h, width: double.infinity, color: Colors.white),
            ),
            verticalSpace(12),
            const MyDivider(),

            // Promo button placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(height: 48.h, width: double.infinity, color: Colors.white),
            ),
            verticalSpace(12),
          ],
        ),
      ),
    );
  }
}