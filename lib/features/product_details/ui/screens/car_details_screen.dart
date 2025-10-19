// lib/features/product_details/ui/screens/car_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/widgets/marketing_request_sheet.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import 'package:mushtary/core/utils/helpers/launcher.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';
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
          context.pushNamed(Routes.chatScreen, arguments: chatModel);

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
        BlocProvider<CarDetailsCubit>(create: (_) => getIt<CarDetailsCubit>()..fetchCarDetails(id)),
        BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()..loadProfile()),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<CarDetailsCubit, CarDetailsState>(
            builder: (context, state) {
              if (state is CarDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CarDetailsFailure) {
                return Center(child: Text(state.error, textAlign: TextAlign.center));
              } else if (state is CarDetailsSuccess) {
                final car = state.details;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 72.h),
                  child: Column(
                    children: [
                      const CarDetailsAppBar(),
                      CarDetailsImages(images: car.imageUrls, status: car.condition),
                      CarStoryAndTitle(title: car.title),
                      CarDetailsPanel(
                        city: car.city,
                        region: car.region,
                        createdAt: DateTime.tryParse(car.createdAt) ?? DateTime.now(),
                      ),
                      verticalSpace(16),
                      CarPrice(price: double.tryParse(car.price ?? '0')),
                      const MyDivider(),
                      CarInfoGridView(
                        transmission: car.transmissionType,
                        mileage: car.mileage,
                        cylinder: car.cylinderCount,
                        driveType: car.driveType,
                        horsepower: car.horsepower,
                        fuelType: car.fuelType,
                        vehicleType: car.vehicleType,
                      ),
                      CarInfoDescription(
                        description: car.description.isEmpty ? 'لا يوجد' : car.description,
                      ),
                      verticalSpace(16),
                      CarOwnerInfo(
                        username: car.username.isEmpty ? 'مستخدم' : car.username,
                        phone: car.userPhoneNumber,
                      ),
                      const MyDivider(),
                      CarCommentsView(comments: car.comments),
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
                      PromoButton(
                        onPressed: () async {
                          // مهم: لا تستخدم context.select داخل onPressed
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

                      CarSimilarAds(similarAds: car.similarAds),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<CarDetailsCubit, CarDetailsState>(
          builder: (context, state) {
            if (state is! CarDetailsSuccess) return const SizedBox.shrink();
            final car = state.details;
            final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
            final ownerId = car.userId;
            final isOwner = (myId != null && ownerId != null && myId == ownerId);
            final phone = car.userPhoneNumber;
            final ownerName = car.username;

            return CarBottomActions(
              onWhatsapp: () => launchWhatsApp(context, phone, message: 'مرحباً 👋 بخصوص إعلان: ${car.title}'),
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

              // أضف سومتك => شيت العروض (offers) مثل الريال استيت
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
}