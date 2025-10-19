// lib/features/real_estate_details/ui/screens/real_estate_details_screen.dart

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
import '../../../../core/utils/helpers/launcher.dart';
import '../../../messages/data/models/messages_model.dart';
import '../../../messages/data/repo/messages_repo.dart';
import '../../../messages/ui/widgets/chats/chat_initiation_sheet.dart';
import '../../../product_details/ui/widgets/offer_sheet.dart';
import '../widgets/real_estate_comments_view.dart';
import '../widgets/real_estate_comment_composer.dart';
import '../../logic/cubit/real_estate_details_cubit.dart';
import '../../logic/cubit/real_estate_details_state.dart';

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
            partnerUser: UserModel(id: receiverId, name: receiverName),
            lastMessage: initialMessage,
          );
          context.pushNamed(Routes.chatScreen, arguments: chatModel);

          await Future.delayed(const Duration(milliseconds: 500));

          final body = SendMessageRequestBody(
            receiverId: receiverId,
            messageContent: initialMessage,
            listingId: id,
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
        BlocProvider<RealEstateDetailsCubit>(
          create: (_) => getIt<RealEstateDetailsCubit>()..getRealEstateDetails(id),
        ),
        BlocProvider<CommentSendCubit>(
          create: (_) => getIt<CommentSendCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<RealEstateDetailsCubit, RealEstateDetailsState>(
            builder: (context, state) {
              if (state is RealEstateDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RealEstateDetailsFailure) {
                return Center(child: Text(state.message));
              } else if (state is RealEstateDetailsSuccess) {
                final property = state.details;

                // comments من الـ model بالفعل List<dynamic> في الغالب
                final List<dynamic> comments = property.comments;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 72.h),
                  child: Column(
                    children: [
                      const RealStateDetailsAppBar(),
                      RealEstateDetailsProductImages(images: property.imageUrls),
                      RealEstateStoryAndTitleWidget(title: property.title),
                      DetailsPanel(
                        cityName: property.city,
                        areaName: property.region,
                        createdAt: property.createdAt,
                      ),
                      verticalSpace(16),
                      RealEstatePrice(price: property.price),
                      const MyDivider(),
                      RealEstateProductInfoGridView(
                        area: property.realEstateDetails?.areaM2,
                        bathrooms: property.realEstateDetails?.bathroomCount,
                        numberOfStreetFrontages: property.realEstateDetails?.streetCount,
                        rooms: property.realEstateDetails?.roomCount,
                        streetWidth: property.realEstateDetails?.streetWidth,
                        windDirection: property.realEstateDetails?.facade,
                      ),
                      RealEstateInfoDescription(description: property.description),
                      verticalSpace(20),
                      RealEstateMoreDetails(
                        details: property.realEstateDetails,
                        city: property.city,
                        region: property.region,
                      ),
                      verticalSpace(20),
                      const Reminder(),
                      const MyDivider(),

                      // التعليقات + المؤلف
                      RealEstateCommentsView(comments: comments),
                      verticalSpace(12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: RealEstateCommentComposer(
                          adId: id,
                          onSuccessRefresh: () {
                            context.read<RealEstateDetailsCubit>().getRealEstateDetails(id);
                          },
                        ),
                      ),
                      const MyDivider(),
                      PromoButton(
                        onPressed: () async {
                          final myId = context.read<ProfileCubit>().user?.userId;
                          final isOwner = (myId != null && property.user?.id == myId);
                          if (isOwner) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا يمكنك طلب تسويق لإعلانك.')),
                            );
                            return;
                          }
                          await showMarketingRequestSheet(context, adId: id);
                        },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),

        bottomNavigationBar: BlocBuilder<RealEstateDetailsCubit, RealEstateDetailsState>(
          builder: (context, state) {
            if (state is! RealEstateDetailsSuccess) return const SizedBox.shrink();
            final property = state.details;

            final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
            final ownerId = property.user?.id;
            final isOwner = (myId != null && ownerId != null && myId == ownerId);

            final phone = property.user?.phoneNumber;

            return CarBottomActions(
              onWhatsapp: () => launchWhatsApp(
                context,
                phone,
                message: 'مرحباً 👋 بخصوص إعلان: ${property.title}',
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
                  _startChat(context, ownerId, property.user?.username ?? 'البائع');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لا يمكن تحديد هوية البائع.')),
                  );
                }
              },

              // أضف سومتك => فتح شيت العروض (offers)
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