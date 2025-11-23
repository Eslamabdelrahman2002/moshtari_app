// lib/features/product_details/ui/screens/real_estate_auction_details_screen.dart

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
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/helpers/launcher.dart';
import '../../../../core/utils/helpers/navigation.dart';
import '../../../../core/widgets/reminder.dart';

import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

import '../logic/cubit/real_estate_auction_details_cubit.dart';
import '../logic/cubit/real_estate_auction_details_state.dart';

// WS Bidding Logic
import 'package:mushtary/features/product_details/data/repo/auction_bid_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/auction_bid_cubit.dart';

// مشاركة/مفضلة
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/advertising_market_dialog.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_cubit.dart';

// Chat models
import 'package:mushtary/features/messages/data/models/chat_model.dart';
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
  final int? initialItemId; // ✅ عنصر افتراضي مفعّل (للمزاد المتعدد)

  const RealEstateAuctionDetailsScreen({
    super.key,
    required this.id,
    this.initialItemId, // ✅ اختياري
  });

  @override
  State<RealEstateAuctionDetailsScreen> createState() => _RealEstateAuctionDetailsScreenState();
}

class _RealEstateAuctionDetailsScreenState extends State<RealEstateAuctionDetailsScreen> {
  final NumberFormat _nf = NumberFormat.decimalPattern('ar');
  String _fmt(num? v) => v == null ? '0' : _nf.format(v);

  // Helpers
  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  T? _safe<T>(T Function() f) {
    try { return f(); } catch (_) { return null; }
  }

  int? _resolveReceiverId(dynamic details) {
    final cands = <dynamic>[
      _safe(() => details.ownerId),
      _safe(() => details.userId),
      _safe(() => details.user_id),
      _safe(() => details.owner_id),
      _safe(() => details.user?.id),
      _safe(() => details.owner?.id),
      _safe(() => details.publisher?.id),
      _safe(() => details.activeItem?.userId),
      _safe(() => details.activeItem?.user_id),
      _safe(() => details.activeItem?.user?.id),
    ];
    for (final c in cands) {
      final id = _asInt(c);
      if (id != null && id > 0) return id;
    }
    return null;
  }

  String? _extractOwnerPhone(dynamic d) {
    final candidates = <dynamic>[
      _safe(() => d.ownerPhone), _safe(() => d.phone),
      _safe(() => d.user?.phone_number),
      _safe(() => d.owner?.phone), _safe(() => d.publisher?.phone),
      _safe(() => d.advertiser?.phone), _safe(() => d.seller?.phone),
      _safe(() => d.activeItem?.phone), _safe(() => d.activeItem?.ownerPhone),
    ];
    for (final c in candidates) {
      final s = c?.toString();
      if (s != null && s.trim().isNotEmpty) return s;
    }
    return null;
  }

  // بدء محادثة (مع إدخال أول رسالة)
  void _startChat(BuildContext context, int receiverId, String receiverName, dynamic auctionDetails) {
    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (initialMessage) async {
        try {
          final repo = getIt<MessagesRepo>();
          final conversationId = await repo.initiateChat(receiverId);
          debugPrint('[REALESTATE CHAT] conversationId=$conversationId');

          if (conversationId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تعذر بدء المحادثة الآن.')),
            );
            return;
          }

          final adInfo = AdInfo(
            id: auctionDetails.id,
            title: auctionDetails.title,
            imageUrl: (auctionDetails.activeItem?.images is List && auctionDetails.activeItem.images.isNotEmpty)
                ? auctionDetails.activeItem.images.first
                : (auctionDetails.thumbnail ?? ''),
            price: (auctionDetails.maxBid ?? num.tryParse(auctionDetails.startPrice ?? '') ?? 0).toString(),
          );

          final chatModel = MessagesModel(
            conversationId: conversationId,
            partnerUser: UserModel(id: receiverId, name: receiverName),
            lastMessage: initialMessage,
          );

          NavX(context).pushNamed(
            Routes.chatScreen,
            arguments: ChatScreenArgs(chatModel: chatModel, adInfo: adInfo),
          );

          // أرسل الرسالة الأولى
          await Future.delayed(const Duration(milliseconds: 400));
          final body = SendMessageRequestBody(
            receiverId: receiverId,
            messageContent: initialMessage,
            listingId: auctionDetails.id,
          );
          await repo.sendMessage(body, conversationId);
        } catch (e, st) {
          debugPrint('[REALESTATE CHAT] error: $e\n$st');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر بدء المحادثة: $e')),
          );
        }
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
                        if (Navigator.of(listenerCtx).canPop()) Navigator.pop(listenerCtx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال المزايدة بنجاح')));
                        if (mounted) {
                          // ✅ أعد الجلب مع نفس العنصر النشط
                          context.read<RealEstateAuctionDetailsCubit>().fetch(widget.id, activeItemId: itemId);
                        }
                      }
                    },
                    builder: (consumerCtx, bidState) {
                      final currentMaxBid = bidState.currentMaxBid;
                      final isLoading = bidState is AuctionBidLoading;

                      void addInc(int inc) {
                        final curText = controller.text.trim();
                        final base = num.tryParse(curText.isEmpty ? currentMaxBid.toString() : curText) ?? currentMaxBid;
                        controller.text = (base + inc).toString();
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
                                  ? const Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(Colors.white)))
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
          create: (_) => getIt<RealEstateAuctionDetailsCubit>()
            ..fetch(widget.id, activeItemId: widget.initialItemId), // ✅ تمرير العنصر الافتراضي إن وجد
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
                return const Center(child: CircularProgressIndicator.adaptive());
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

                final receiverId = _resolveReceiverId(d) ?? _resolveReceiverId(d as dynamic);
                final ownerName = d.ownerName;
                final ownerPicture = d.ownerPicture;

                final dyn = d as dynamic;
                final bidsCount = _asInt(_safe(() => dyn.bidsCount) ?? _safe(() => dyn.bids_count) ?? _safe(() => dyn.bids?.length)) ?? 0;
                final participants = _asInt(_safe(() => dyn.participantsCount) ?? _safe(() => dyn.participants_count) ?? _safe(() => dyn.participants)) ?? 0;

                final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
                final myUsername = context.select<ProfileCubit, String?>((c) => c.user?.username);
                final isOwner = (myId != null && receiverId != null && myId == receiverId) ||
                    ((myUsername?.trim().isNotEmpty ?? false) && (ownerName.trim() == myUsername?.trim()));

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

                final location = '${item?.cityNameAr ?? '-'} - ${item?.district ?? '-'}';

                return MultiBlocProvider(
                  providers: [BlocProvider<AuctionBidCubit>.value(value: auctionBidCubit)],
                  child: RefreshIndicator.adaptive(
                    onRefresh: () async => context.read<RealEstateAuctionDetailsCubit>().fetch(
                      widget.id,
                      activeItemId: itemId > 0 ? itemId : null, // ✅ حدّث مع العنصر الحالي
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 90.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          product_appbar.ProductScreenAppBar(),

                          RealEstateDetailsProductImages(
                            images: images,
                            adId: auctionId,
                            favoriteType: 'auction',
                          ),

                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(d.title, style: TextStyles.font20Black500Weight),
                          ),

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

                          RealEstateInfoDescription(description: d.description),

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

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: RealEstateCurrentUserInfo(
                              ownerName: ownerName,
                              ownerPicture: ownerPicture,
                              userTitle: 'وسيط عقاري',
                              onTap: () {
                                if (receiverId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تعذر تحديد معرف الناشر')),
                                  );
                                  return;
                                }
                                NavX(context).pushNamed(
                                  Routes.userProfileScreenId,
                                  arguments: receiverId,
                                );
                              },
                            ),
                          ),
                          verticalSpace(8),
                          const MyDivider(),

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
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),

        bottomNavigationBar: BlocBuilder<RealEstateAuctionDetailsCubit, RealEstateAuctionDetailsState>(
          builder: (context, state) {
            if (state is RealEstateAuctionDetailsSuccess) {
              final d = state.details;
              final highest = d.maxBid ?? num.tryParse(d.startPrice) ?? 0;
              final minBid  = num.tryParse(d.minBidValue) ?? 0;
              final step    = num.tryParse(d.bidStep) ?? 1;
              final ended   = DateTime.now().isAfter(d.endTime);
              final itemId = d.activeItem?.id ?? 0;

              final receiverId = _resolveReceiverId(d) ?? _resolveReceiverId(d as dynamic);
              final ownerName = d.ownerName;
              final phone   = _extractOwnerPhone(d as dynamic);

              final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
              final myUsername = context.select<ProfileCubit, String?>((c) => c.user?.username);
              final isOwner = (myId != null && receiverId != null && myId == receiverId) ||
                  ((myUsername?.trim().isNotEmpty ?? false) && (ownerName.trim() == myUsername?.trim()));

              return Container(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h, top: 12.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: ended ? null : () => _showBidDialog(
                            currentHighest: highest, minBid: minBid, step: step,
                            end: d.endTime, auctionId: d.id, itemId: itemId,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: const Text('قم بالمزايدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    horizontalSpace(12),

                    // الشات: متاح دائمًا (حتى بعد انتهاء المزاد)
                    _squareIconBtn(
                      icon: MySvg(image: 'message_icon'),
                      bg: ColorsManager.primary50,
                      borderColor: const Color(0xFFEAEAEA),
                      onTap: () {
                        final myId = context.read<ProfileCubit>().user?.userId;
                        if (myId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً لبدء المحادثة.')));
                          return;
                        }
                        if (receiverId == null || ownerName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تحديد هوية الطرف الآخر.')));
                          debugPrint('[REALESTATE CHAT] receiverId resolve failed. myId=$myId ownerName="$ownerName"');
                          return;
                        }
                        if (isOwner) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكنك المحادثة مع نفسك.')));
                          return;
                        }
                        _startChat(context, receiverId, ownerName, d);
                      },
                    ),
                    horizontalSpace(8),

                    // الاتصال: متاح دائمًا، يعرض SnackBar إذا لا يوجد رقم
                    _squareIconBtn(
                      icon: MySvg(image: 'callCalling'),
                      bg: ColorsManager.primary50,
                      borderColor: const Color(0xFFEAEAEA),
                      onTap: () {
                        final p = phone;
                        if (p?.isNotEmpty ?? false) {
                          launchCaller(context, p!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('لا يتوفر رقم هاتف للناشر.')),
                          );
                        }
                      },
                    ),
                    horizontalSpace(8),

                    // واتساب: متاح دائمًا، يعرض SnackBar إذا لا يوجد رقم
                    _squareIconBtn(
                      icon: MySvg(image: 'logos_whatsapp'),
                      bg: ColorsManager.success200,
                      onTap: () {
                        final p = phone;
                        if (p?.isNotEmpty ?? false) {
                          launchWhatsApp(context, p!, message: 'مرحباً 👋 بخصوص مزاد: ${d.title}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('لا يتوفر رقم واتساب للناشر.')),
                          );
                        }
                      },
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
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calcRemaining();
    _startTimer(); // ← بدأ العداد على الفور
  }

  @override
  void didUpdateWidget(covariant _AuctionStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _calcRemaining();
      _restartTimer();
    }
  }

  void _calcRemaining() {
    final d = widget.endTime.difference(DateTime.now());
    setState(() => _left = d.isNegative ? Duration.zero : d);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = widget.endTime.difference(DateTime.now());
      if (!mounted) return;
      setState(() {
        _left = diff.isNegative ? Duration.zero : diff;
      });
      if (diff.isNegative) _timer?.cancel();
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt2(int v) => v.toString().padLeft(2, '0');
  String _fmt(num? v) =>
      v == null ? '0' : v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _fmtEnd(DateTime dt) {
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final m = months[dt.month - 1];
    final hh = _fmt2(dt.hour);
    final mm = _fmt2(dt.minute);
    return '${dt.day} $m $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final days  = _left.inDays;
    final hours = _left.inHours % 24;
    final mins  = _left.inMinutes % 60;
    final secs  = _left.inSeconds % 60;
    final highestTextDisplay = _fmt(num.tryParse(widget.highest));

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
              Text('${widget.participants}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
              horizontalSpace(4),
              Text('عدد المشاركين',
                  style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('أعلى مزايدة',
                        style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp)),
                    horizontalSpace(6),
                    Text(highestTextDisplay,
                        style: TextStyle(color: const Color(0xFF14457F),
                            fontSize: 16.sp, fontWeight: FontWeight.w700)),
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
              _timeBox('يوم', _fmt2(days)),
              horizontalSpace(8),
              _timeBox('ساعة', _fmt2(hours)),
              horizontalSpace(8),
              _timeBox('دقيقة', _fmt2(mins)),
              horizontalSpace(8),
              _timeBox('ثانية', _fmt2(secs)),
            ],
          ),
          verticalSpace(10),
          Row(
            children: [
              Expanded(
                child: Text('مزايدة ${widget.bidsCount}',
                    style: TextStyle(color: ColorsManager.darkGray, fontSize: 12.sp)),
              ),
              Row(
                children: [
                  const Icon(Icons.hourglass_bottom_rounded, size: 16, color: ColorsManager.darkGray),
                  horizontalSpace(6),
                  Text('تاريخ الإنتهاء: ${_fmtEnd(widget.endTime)}',
                      style: TextStyles.font12Dark500400Weight),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFF7F7F7)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(color: const Color(0xFF14457F),
                    fontSize: 14.sp, fontWeight: FontWeight.w700)),
            verticalSpace(2),
            Text(label,
                style: TextStyle(color: ColorsManager.darkGray,
                    fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}