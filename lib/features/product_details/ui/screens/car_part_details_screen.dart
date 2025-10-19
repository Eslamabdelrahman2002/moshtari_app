import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/reminder.dart';
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
import '../../../../core/utils/helpers/launcher.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';

// موديلات الشات
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';

import '../../../home/data/models/home_data_model.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';
import '../logic/cubit/car_parts_details_cubit.dart';
import '../logic/cubit/car_parts_details_state.dart';

// التعليقات + المؤلف
import '../widgets/car_details/widgets/car_part_add_comment_field.dart';
import '../widgets/car_details/widgets/car_part_comments_view.dart';
import '../widgets/offer_sheet.dart';

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

          // معلومات الإعلان أعلى شاشة الشات
          final adInfo = AdInfo(
            id: partDetails.id,
            title: partDetails.title,
            imageUrl: (partDetails.imageUrls is List && partDetails.imageUrls.isNotEmpty)
                ? partDetails.imageUrls.first
                : '',
            price: partDetails.price.toString(),
          );

          // الانتقال للشات فقط (بدون إرسال أول رسالة)
          // لا نرسل أي رسالة هنا
          // await Future.delayed(const Duration(milliseconds: 500)); // لو تحب تبقي التأخير احذفه أو اتركه
          context.pushNamed(
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
        BlocProvider<CarPartsDetailsCubit>(
          create: (_) => getIt<CarPartsDetailsCubit>()..fetchCarPartDetails(id),
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
          child: BlocBuilder<CarPartsDetailsCubit, CarPartsDetailsState>(
            builder: (context, state) {
              if (state is CarPartsDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CarPartsDetailsFailure) {
                return Center(child: Text(state.message));
              }
              if (state is CarPartsDetailsSuccess) {
                final part = state.details;

                // بيانات المالك
                final ownerId = part.user.id as int;
                final ownerName = (part.user.username?.toString() ?? part.user.username?.toString() ?? '—').trim();

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
                      SizedBox(
                        height: 250,
                        child: PageView(
                          children: part.imageUrls.map((url) {
                            return Image.network(url, fit: BoxFit.cover);
                          }).toList(),
                        ),
                      ),

                      // العنوان
                      StoryAndTitleWidget(title: part.title),

                      // البانيل: مدينة + تاريخ + سعر
                      DetailsPanel(
                        location: "${part.city} - ${part.region}",
                        time: part.createdAt,
                        price: part.price,
                      ),

                      // معلومات المالك (مرتبطة بالبيانات)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CurrentUserInfo(
                          ownerName: ownerName,
                          ownerPicture: ownerPicture,
                          isVerified: isVerified,
                          rating: rating,
                          reviewsCount: reviewsCount,
                          onFollow: () {
                            // إن أردت ربط زر المتابعة أو فتح البروفايل لاحقًا
                          },
                        ),
                      ),
                      const MyDivider(),

                      // معلومات إضافية
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("حالة القطعة: ${part.carPartDetail.condition}"),
                            Text("البراند: ${part.carPartDetail.brandName}"),
                            Text("الموديلات المدعومة: ${part.carPartDetail.supportedModels.join(", ")}"),
                          ],
                        ),
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

                      // إعلانات مشابهة
                      SimilarAds(
                        similarAds: part.similarAds.map((s) {
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
                        }).toList(),
                      ),
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
            final ownerName = part.user.username?.toString() ?? part.user.username?.toString() ?? '—';

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
}