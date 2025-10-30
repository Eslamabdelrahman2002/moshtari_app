import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/helpers/launcher.dart';
import '../../../../core/utils/helpers/navigation.dart';
import '../../../../core/widgets/reminder.dart';

import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

import 'package:mushtary/features/product_details/ui/widgets/auction_comments_view.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/auction_add_comment_field.dart';
import 'package:mushtary/features/product_details/ui/widgets/marketing_request_sheet.dart';

import '../logic/cubit/real_estate_auction_details_cubit.dart';
import '../logic/cubit/real_estate_auction_details_state.dart';

// WS Bidding Logic
import 'package:mushtary/features/product_details/data/repo/auction_bid_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/auction_bid_cubit.dart';

// مشاركة/مفضلة
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/advertising_market_dialog.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_cubit.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_state.dart';

// Chat models
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';

// Widgets
import 'package:mushtary/features/product_details/ui/widgets/app_bar.dart' as product_appbar;
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_details_product_images.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_item_datails.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_info_description.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_product_info_grid_view.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_current_user_info.dart';

class RealEstateAuctionDetailsScreen extends StatefulWidget {
  final int id;
  const RealEstateAuctionDetailsScreen({super.key, required this.id});

  @override
  State<RealEstateAuctionDetailsScreen> createState() => _RealEstateAuctionDetailsScreenState();
}

class _RealEstateAuctionDetailsScreenState extends State<RealEstateAuctionDetailsScreen> {
  final NumberFormat _nf = NumberFormat.decimalPattern('ar');
  String _fmt(num? v) => v == null ? '0' : _nf.format(v);

  // بدء محادثة
  void _startChat(BuildContext context, int receiverId, String receiverName, dynamic auctionDetails) {
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

          final adInfo = AdInfo(
            id: auctionDetails.id,
            title: auctionDetails.title,
            imageUrl: (auctionDetails.activeItem?.images is List && auctionDetails.activeItem.images.isNotEmpty)
                ? auctionDetails.activeItem.images.first
                : (auctionDetails.thumbnail ?? ''),
            price: (auctionDetails.maxBid ?? num.tryParse(auctionDetails.startPrice ?? '') ?? 0).toString(),
          );

          NavX(context).pushNamed(
            Routes.chatScreen,
            arguments: ChatScreenArgs(chatModel: chatModel, adInfo: adInfo),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          final body = SendMessageRequestBody(
            receiverId: receiverId,
            messageContent: initialMessage,
            listingId: auctionDetails.id,
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

  // نافذة المشاركة (تُستخدم إذا رغبت باستبدال ShareDialog لاحقًا)
  void _showShareDialog(BuildContext context, dynamic auctionDetails, String location, String? phone) {
    final int auctionId = auctionDetails.id;
    final String auctionTitle = auctionDetails.title;
    final String price = _fmt(auctionDetails.maxBid ?? num.tryParse(auctionDetails.startPrice ?? '') ?? 0);
    final List<String> images = (auctionDetails.activeItem?.images is List && auctionDetails.activeItem.images.isNotEmpty)
        ? auctionDetails.activeItem.images.cast<String>()
        : (auctionDetails.thumbnail != null ? [auctionDetails.thumbnail] : []);

    final adModelForDialog = HomeAdModel(
      id: auctionId,
      title: auctionTitle,
      price: price,
      location: location,
      imageUrls: images,
      createdAt: auctionDetails.createdAt?.toIso8601String() ?? '',
      username: '',
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: ColorsManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 24.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 380.w,
              maxHeight: size.height * 0.85,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              child: AdvertisingMarketDialog(
                adModel: adModelForDialog,
                phone: phone,
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialog "قم بالمزايدة"
  Future<void> _showBidDialog({
    required num currentHighest,
    required num minBid,
    required num step,
    required DateTime end,
    required int auctionId,
    required int itemId,
  }) async {
    final ended = DateTime.now().isAfter(end);
    final controller = TextEditingController(text: '');
    final incs = <int>[500, 1000, 1500];

    final key = 'real_estate-$auctionId';
    AuctionBidCubit bidCubit;
    if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
      bidCubit = getIt<AuctionBidCubit>(instanceName: key);
    } else {
      bidCubit = AuctionBidCubit(
        getIt<AuctionBidRepo>(),
        auctionId: auctionId,
        auctionType: 'real_estate',
        itemId: itemId,
        currentMaxBid: currentHighest,
      );
      getIt.registerSingleton<AuctionBidCubit>(bidCubit, instanceName: key);
      bidCubit.joinAuction();
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return BlocProvider<AuctionBidCubit>.value(
          value: bidCubit,
          child: Builder(
            builder: (bidContext) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: BlocConsumer<AuctionBidCubit, AuctionBidState>(
                    listener: (listenerCtx, bidState) async {
                      if (bidState is AuctionBidFailure) {
                        ScaffoldMessenger.of(listenerCtx).showSnackBar(SnackBar(content: Text(bidState.message)));
                      }
                      if (bidState is AuctionBidSuccess) {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (Navigator.of(listenerCtx).canPop()) {
                          Navigator.pop(listenerCtx);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إرسال المزايدة بنجاح')),
                        );
                        if (mounted) {
                          context.read<RealEstateAuctionDetailsCubit>().fetch(widget.id);
                        }
                      }
                    },
                    builder: (consumerCtx, bidState) {
                      final currentMaxBid = bidState.currentMaxBid;
                      final isLoading = bidState is AuctionBidLoading;

                      void addInc(int inc) {
                        final curText = controller.text.trim();
                        final base = num.tryParse(curText.isEmpty ? currentMaxBid.toString() : curText) ?? currentMaxBid;
                        final next = base + inc;
                        controller.text = next.toString();
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('قم بالمزايدة', style: TextStyles.font18Black500Weight),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(consumerCtx),
                                icon: const Icon(Icons.close, color: Colors.black87),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          verticalSpace(8),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: ColorsManager.primary400,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.currency_exchange_rounded, color: Colors.white),
                                horizontalSpace(8),
                                const Text('أعلى مزايدة', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(_fmt(currentMaxBid), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          verticalSpace(12),

                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'أدخل مزايدتك',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: ColorsManager.dark200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: ColorsManager.primary300),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              prefixIcon: const Icon(Icons.edit_rounded),
                            ),
                          ),
                          verticalSpace(12),

                          Wrap(
                            spacing: 8.w,
                            children: incs.map((e) {
                              return OutlinedButton(
                                onPressed: (ended || isLoading) ? null : () => addInc(e),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: ColorsManager.primary400),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                  foregroundColor: ColorsManager.primary400,
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                  textStyle: TextStyles.font14Blue500Weight,
                                ),
                                child: Text('+${_fmt(e)}'),
                              );
                            }).toList(),
                          ),
                          verticalSpace(16),

                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: (ended || isLoading)
                                  ? null
                                  : () {
                                final v = num.tryParse(controller.text.trim());
                                if (v == null || v < minBid) {
                                  ScaffoldMessenger.of(consumerCtx).showSnackBar(SnackBar(content: Text('أقل قيمة للسوم ${_fmt(minBid)}')));
                                  return;
                                }
                                if (v <= currentMaxBid) {
                                  ScaffoldMessenger.of(consumerCtx).showSnackBar(const SnackBar(content: Text('لابد أن تزيد على أعلى مزايدة')));
                                  return;
                                }
                                final diff = v - currentMaxBid;
                                final steps = diff / step;
                                const eps = 1e-9;
                                if ((steps - steps.round()).abs() > eps) {
                                  ScaffoldMessenger.of(consumerCtx).showSnackBar(SnackBar(content: Text('يجب الالتزام بخطوة السوم (${_fmt(step)})')));
                                  return;
                                }
                                bidCubit.placeBid(bidAmount: v);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.primary400,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : const Text('تأكيد'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    final key = 'real_estate-${widget.id}';
    if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
      final c = getIt<AuctionBidCubit>(instanceName: key);
      c.leaveAuction();
      getIt.unregister<AuctionBidCubit>(instanceName: key);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RealEstateAuctionDetailsCubit>(
          create: (_) => getIt<RealEstateAuctionDetailsCubit>()..fetch(widget.id),
        ),
        BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()..loadProfile()),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()..fetchFavorites()),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<RealEstateAuctionDetailsCubit, RealEstateAuctionDetailsState>(
            builder: (context, state) {
              if (state is RealEstateAuctionDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is RealEstateAuctionDetailsFailure) {
                return Center(child: Text(state.message));
              }
              if (state is RealEstateAuctionDetailsSuccess) {
                final d = state.details;
                final item = d.activeItem;
                final auctionId = widget.id;

                final images = (item?.images.isNotEmpty ?? false)
                    ? item!.images
                    : (d.thumbnail != null ? [d.thumbnail!] : <String>[]);
                final highest = d.maxBid ?? num.tryParse(d.startPrice) ?? 0;
                final minBid  = num.tryParse(d.minBidValue) ?? 0;
                final step    = num.tryParse(d.bidStep) ?? 1;
                final itemId = item?.id ?? 0;

                // معلومات المالك
                String? phone;
                int? ownerId;
                String ownerName = d.ownerName;
                String? ownerPicture = d.ownerPicture;
                String location = '${item?.cityNameAr ?? '-'} - ${item?.district ?? '-'}';
                List<dynamic> comments = const [];
                int bidsCount = 0;
                int participants = 0;

                try {
                  final dyn = d as dynamic;
                  ownerId = dyn.ownerId as int? ?? dyn.user_id as int? ?? dyn.user?.id as int?;
                  phone = (dyn.ownerPhone ?? dyn.phone ?? dyn.user?.phone_number)?.toString();

                  final list = dyn.comments;
                  if (list is List) comments = list;
                  bidsCount = (dyn.bidsCount ?? dyn.bids_count ?? dyn.bids?.length ?? 0) as int;
                  participants = (dyn.participantsCount ?? dyn.participants_count ?? dyn.participants ?? 0) as int;
                } catch (_) {}

                final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
                final myUsername = context.select<ProfileCubit, String?>((c) => c.user?.username);
                final isOwner = (myId != null && ownerId != null && myId == ownerId) ||
                    ((myUsername?.trim().isNotEmpty ?? false) && (ownerName.trim() == myUsername?.trim()));

                // إنشاء/جلب الكيوبت المشترك للمزايدة
                final key = 'real_estate-$auctionId';
                AuctionBidCubit auctionBidCubit;
                if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
                  auctionBidCubit = getIt<AuctionBidCubit>(instanceName: key);
                } else {
                  auctionBidCubit = AuctionBidCubit(
                    getIt<AuctionBidRepo>(),
                    auctionId: auctionId,
                    auctionType: 'real_estate',
                    itemId: itemId,
                    currentMaxBid: highest,
                  );
                  getIt.registerSingleton<AuctionBidCubit>(auctionBidCubit, instanceName: key);
                  auctionBidCubit.joinAuction();
                }

                return MultiBlocProvider(
                  providers: [
                    BlocProvider<AuctionBidCubit>.value(value: auctionBidCubit),
                  ],
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 90.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        product_appbar.ProductScreenAppBar(),

                        // الصور بنفس نمط بقية الشاشات (المشاركة + المفضلة داخل الودجت)
                        RealEstateDetailsProductImages(
                          images: images,
                          adId: auctionId,
                          favoriteType: 'auction',
                        ),

                        // العنوان
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(d.title, style: TextStyles.font20Black500Weight),
                        ),

                        // الموقع + التاريخ
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              RealEstateItemDatails(
                                text: location,
                                image: 'location-yellow', width: 20.w, height: 20.h,
                              ),
                              const Spacer(),
                              RealEstateItemDatails(
                                text: '${d.createdAt.year}-${d.createdAt.month}-${d.createdAt.day}',
                                image: 'clock-yellow', width: 20.w, height: 20.h,
                              ),
                            ],
                          ),
                        ),
                        verticalSpace(12),
                        const MyDivider(),

                        // وصف
                        RealEstateInfoDescription(description: d.description),

                        // شبكة معلومات العقار
                        if (item != null)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: RealEstateProductInfoGridView(
                              area: int.tryParse(item.area ?? ''),
                              rooms: item.numRooms,
                              bathrooms: item.numBathrooms,
                              windDirection: item.facade,
                              numberOfStreetFrontages: item.numStreets,
                              streetWidth: item.streetWidth,
                            ),
                          ),

                        // صاحب الإعلان
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: RealEstateCurrentUserInfo(
                            ownerName: ownerName,
                            ownerPicture: ownerPicture,
                            userTitle: 'وسيط عقاري',
                            onTap: () { // ✅ تم إضافة onTap
                              // ✅ ownerId مستخلص في بداية حالة النجاح
                              if (ownerId != null) {
                                NavX(context).pushNamed( // ✅ استخدام NavX
                                  Routes.userProfileScreenId,
                                  arguments: ownerId,
                                );
                              }
                            },
                          ),
                        ),
                        verticalSpace(8),
                        const MyDivider(),

                        // كرت حالة المزاد
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: BlocBuilder<AuctionBidCubit, AuctionBidState>(
                            builder: (context, bidState) {
                              return _AuctionStatusCard(
                                highest: _fmt(bidState.currentMaxBid),
                                bidsCount: bidsCount,
                                participants: participants,
                                endTime: d.endTime,
                              );
                            },
                          ),
                        ),

                        const MyDivider(),
                        verticalSpace(12),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: const Reminder(),
                        ),
                        verticalSpace(12),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),

        // الشريط السفلي
        bottomNavigationBar: BlocBuilder<RealEstateAuctionDetailsCubit, RealEstateAuctionDetailsState>(
          builder: (context, state) {
            if (state is RealEstateAuctionDetailsSuccess) {
              final d = state.details;
              final highest = d.maxBid ?? num.tryParse(d.startPrice) ?? 0;
              final minBid  = num.tryParse(d.minBidValue) ?? 0;
              final step    = num.tryParse(d.bidStep) ?? 1;
              final ended   = DateTime.now().isAfter(d.endTime);
              final itemId = d.activeItem?.id ?? 0;

              String? phone;
              int? ownerId;
              String ownerName = d.ownerName;

              try {
                final dyn = d as dynamic;
                ownerId = dyn.ownerId as int? ?? dyn.user_id as int? ?? dyn.user?.id as int?;
                phone = (dyn.ownerPhone ?? dyn.phone ?? dyn.user?.phone_number)?.toString();
              } catch (_) {}

              final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
              final myUsername = context.select<ProfileCubit, String?>((c) => c.user?.username);
              final isOwner = (myId != null && ownerId != null && myId == ownerId) ||
                  ((myUsername?.trim().isNotEmpty ?? false) && (ownerName.trim() == myUsername?.trim()));

              return Container(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h, top: 12.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // زر قم بالمزايدة
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: ended
                              ? null
                              : () => _showBidDialog(
                            currentHighest: highest,
                            minBid: minBid,
                            step: step,
                            end: d.endTime,
                            auctionId: d.id,
                            itemId: itemId,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14457F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: const Text('قم بالمزايدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    horizontalSpace(12),

                    // أيقونات التواصل
                    _squareIconBtn(
                      icon:  const Icon(Icons.message, color: ColorsManager.primaryColor),
                      bg: ColorsManager.primary50,
                      borderColor: const Color(0xFFEAEAEA),
                      onTap: ended
                          ? null
                          : () {
                        final myId = context.read<ProfileCubit>().user?.userId;
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
                        if (ownerId == null || ownerName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تعذر تحديد معلومات المالك لبدء المحادثة.')),
                          );
                          return;
                        }
                        _startChat(context, ownerId, ownerName, d);
                      },
                    ),

                    horizontalSpace(8),
                    _squareIconBtn(
                      icon:  const Icon(Icons.phone, color: ColorsManager.primaryColor),
                      bg: ColorsManager.primary50,
                      borderColor: const Color(0xFFEAEAEA),
                      onTap: ended ? null : (phone?.isNotEmpty ?? false) ? () => launchCaller(context, phone!) : null,
                    ),
                    horizontalSpace(8),
                    _squareIconBtn(
                      icon: const MyDivider(), // ضع أيقونة واتساب الخاصة بك هنا
                      bg: ColorsManager.success200,
                      onTap: ended ? null : (phone?.isNotEmpty ?? false) ? () => launchWhatsApp(context, phone!, message: 'مرحباً 👋 بخصوص مزاد: ${d.title}') : null,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _squareIconBtn({required Widget icon, required Color bg, Color? borderColor, VoidCallback? onTap}) {
    final bgColor = onTap == null ? Colors.grey.shade300 : bg;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor ?? Colors.transparent, width: 1.w),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

// ============== Widgets مطابقة للواجهة ==============

class _AuctionStatusCard extends StatefulWidget {
  final String highest;
  final int bidsCount;
  final int participants;
  final DateTime endTime;

  const _AuctionStatusCard({
    super.key,
    required this.highest,
    required this.bidsCount,
    required this.participants,
    required this.endTime,
  });

  @override
  State<_AuctionStatusCard> createState() => _AuctionStatusCardState();
}

class _AuctionStatusCardState extends State<_AuctionStatusCard> {
  late Timer _timer;
  late Duration _left;
  late String _lastHighestText;

  @override
  void initState() {
    super.initState();
    _left = widget.endTime.difference(DateTime.now());
    _lastHighestText = widget.highest;
    _start();
  }

  @override
  void didUpdateWidget(covariant _AuctionStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _left = widget.endTime.difference(DateTime.now());
      _timer.cancel();
      _start();
    }
    _lastHighestText = widget.highest;
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final d = widget.endTime.difference(DateTime.now());
      if (!mounted) return;
      setState(() => _left = d.isNegative ? Duration.zero : d);
      if (d.isNegative) _timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _fmt2(int v) => v.toString().padLeft(2, '0');

  String _fmtEnd(DateTime dt) {
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];
    final m = months[dt.month - 1];
    final hh = _fmt2(dt.hour);
    final mm = _fmt2(dt.minute);
    return '${dt.day} $m $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final days = _left.inDays;
    final hours = _left.inHours % 24;
    final mins = _left.inMinutes % 60;
    final secs = _left.inSeconds % 60;

    final highestTextDisplay = widget.highest;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${widget.participants}', style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  horizontalSpace(4),
                  Text('عدد المشاركين', style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp, fontWeight: FontWeight.w400)),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('أعلى مزايدة', style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                    horizontalSpace(6),
                    Text(highestTextDisplay, style: TextStyle(color: const Color(0xFF14457F), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(10),

          const MyDivider(),
          verticalSpace(10),

          Row(
            children: [
              _timeBox(label: 'يوم',   value: _fmt2(days)),
              horizontalSpace(8),
              _timeBox(label: 'ساعة',  value: _fmt2(hours)),
              horizontalSpace(8),
              _timeBox(label: 'دقيقة', value: _fmt2(mins)),
              horizontalSpace(8),
              _timeBox(label: 'ثانية', value: _fmt2(secs)),
            ],
          ),
          verticalSpace(10),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text('مزايدة ${widget.bidsCount}', style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.hourglass_bottom_rounded, size: 16, color: ColorsManager.darkGray),
                  horizontalSpace(6),
                  Text('تاريخ الإنتهاء: ${_fmtEnd(widget.endTime)}', style: TextStyles.font12Dark500400Weight),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFF7F7F7)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: const Color(0xFF14457F), fontSize: 14.sp, fontWeight: FontWeight.w700)),
            verticalSpace(2),
            Text(label, style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}