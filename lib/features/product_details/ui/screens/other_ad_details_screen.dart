import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
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
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import '../../../home/data/models/home_data_model.dart';
import '../../../real_estate_details/ui/widgets/real_estate_promo_button.dart';
import '../logic/cubit/other_ad_details_cubit.dart';
import '../logic/cubit/other_ad_details_state.dart';
import '../widgets/car_details/widgets/other_ad_add_comment_field.dart';
import '../widgets/car_details/widgets/other_ad_comments_view.dart';
import '../widgets/offer_sheet.dart';

class OtherAdDetailsScreen extends StatefulWidget {
  final int id;
  const OtherAdDetailsScreen({super.key, required this.id});

  @override
  State<OtherAdDetailsScreen> createState() => _OtherAdDetailsScreenState();
}

class _OtherAdDetailsScreenState extends State<OtherAdDetailsScreen> {
  final PageController _pageCtrl = PageController();
  int _index = 0;

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
            listingId: widget.id,
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
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _statusLabel(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v == 'used' || v == 'مستخدم' || v == 'مستعملة') return 'مستعملة';
    if (v == 'new' || v == 'جديد' || v == 'جديدة') return 'جديدة';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OtherAdDetailsCubit>(
          create: (_) => getIt<OtherAdDetailsCubit>()..fetchOtherAdDetails(widget.id),
        ),
        BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()..loadProfile()),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OtherAdDetailsCubit, OtherAdDetailsState>(
            builder: (context, state) {
              if (state is OtherAdDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is OtherAdDetailsFailure) {
                return Center(child: Text(state.message));
              }
              if (state is OtherAdDetailsSuccess) {
                final ad = state.details;
                final images = ad.imageUrls.isEmpty ? <String>[''] : ad.imageUrls;
                final status = _statusLabel(ad.conditionType);

                // بيانات المالك لربط CurrentUserInfo
                String ownerName = ad.username?.toString() ?? '';
                String? ownerPicture;
                bool isVerified = false;
                double rating = 0;
                int reviewsCount = 0;

                try {
                  final dyn = ad as dynamic;
                  final u = dyn.user;
                  if (u != null) {
                    ownerName = ownerName.isNotEmpty
                        ? ownerName
                        : (u.username?.toString() ?? u.name?.toString() ?? '—');

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

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const ProductScreenAppBar(),

                      // الصور + عداد + شارة الحالة
                      SizedBox(
                        height: 285,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageCtrl,
                              itemCount: images.length,
                              onPageChanged: (i) => setState(() => _index = i),
                              itemBuilder: (_, i) {
                                final url = images[i];
                                if (url.isEmpty) {
                                  return const Center(child: Icon(Icons.image_not_supported_outlined));
                                }
                                return Image.network(url, fit: BoxFit.cover, width: double.infinity);
                              },
                            ),
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_index + 1}/${images.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            if (status.isNotEmpty)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // العنوان
                      StoryAndTitleWidget(title: ad.title),

                      // البانيل
                      DetailsPanel(
                        location: "${ad.cityName} - ${ad.regionName}",
                        time: ad.postedAt,
                        price: ad.price ?? 'غير محدد',
                      ),

                      // معلومات المالك - ربط CurrentUserInfo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CurrentUserInfo(
                          ownerName: ownerName.isEmpty ? '—' : ownerName,
                          ownerPicture: ownerPicture,
                          isVerified: isVerified,
                          rating: rating,
                          reviewsCount: reviewsCount,
                          onFollow: () {}, // اختياري
                        ),
                      ),
                      const MyDivider(),

                      // معلومات إضافية
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9FE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE6ECFA)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.category_rounded, color: Color(0xFF1E6AE1)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "التصنيف: ${ad.categoryNameAr.isEmpty ? 'غير محدد' : ad.categoryNameAr}",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "الحالة: ${ad.conditionType?.isNotEmpty == true ? ad.conditionType : 'غير محدد'}",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // الوصف
                      InfoDescription(description: ad.description.isEmpty ? 'لا يوجد' : ad.description),

                      const MyDivider(),
                      const Reminder(),
                      const MyDivider(),

                      // التعليقات
                      OtherAdCommentsView(comments: ad.comments),

                      const SizedBox(height: 12),

                      // محرر إضافة تعليق
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
                      // سوق للإعلان (Marketing)
                      PromoButton(
                        onPressed: () async {
                          final myId = context.read<ProfileCubit>().user?.userId;
                          final isOwner = (myId != null && ad.userId == myId);
                          if (isOwner) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا يمكنك طلب تسويق لإعلانك.')),
                            );
                            return;
                          }
                          await showMarketingRequestSheet(context, adId: widget.id);
                        },
                      ),

                      // إعلانات مشابهة
                      SimilarAds(
                        similarAds: ad.similarAds.map((s) {
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

        bottomNavigationBar: BlocBuilder<OtherAdDetailsCubit, OtherAdDetailsState>(
          builder: (context, state) {
            if (state is! OtherAdDetailsSuccess) return const SizedBox.shrink();
            final ad = state.details;

            final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
            final ownerId = ad.userId;
            final isOwner = (myId != null && ownerId != null && myId == ownerId);

            final phone = ad.userPhone;
            final ownerName = ad.username;

            return CarBottomActions(
              onWhatsapp: () => launchWhatsApp(
                context,
                phone,
                message: 'مرحباً 👋 بخصوص إعلان: ${ad.title}',
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

              // أضف سومتك => offers
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
          },
        ),
      ),
    );
  }
}