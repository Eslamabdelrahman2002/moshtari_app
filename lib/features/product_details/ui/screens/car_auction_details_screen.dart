import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/helpers/launcher.dart';
import '../../../../core/utils/helpers/navigation.dart';

import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../messages/data/models/chat_model.dart';
import '../../data/model/car_auction_details_model.dart';
import '../logic/cubit/car_auction_details_cubit.dart';
import '../logic/cubit/car_auction_details_state.dart';

// WS bidding
import 'package:mushtary/features/product_details/data/repo/auction_bid_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/auction_bid_cubit.dart';

// Widgets
import '../widgets/auction_car_info_grid_view.dart';
import '../widgets/car_details/widgets/car_details_images.dart';
import '../widgets/car_details/widgets/car_details_panel.dart';
import '../widgets/car_details/widgets/car_info_description.dart';
import '../widgets/car_details/widgets/car_story_and_title.dart';

// Chat
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';

// Owner info (reused)
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_current_user_info.dart';

// Profile + comments
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// Skeleton
import 'package:skeletonizer/skeletonizer.dart';


class CarAuctionDetailsScreen extends StatefulWidget {
  final int id;
  final int? initialItemId; // ✅ عنصر مبدئي مفعّل (للمزاد المتعدد)

  const CarAuctionDetailsScreen({
    super.key,
    required this.id,
    this.initialItemId,
  });

  @override
  State<CarAuctionDetailsScreen> createState() => _CarAuctionDetailsScreenState();
}

class _CarAuctionDetailsScreenState extends State<CarAuctionDetailsScreen> {
  // Format helpers
  String _fmt(num? v) {
    if (v == null) return '0';
    final s = v.toString();
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  // Helpers
  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  T? _safe<T>(T Function() f) { try { return f(); } catch (_) { return null; } }

  // استخراج مرن لمعرف صاحب الإعلان
  int? _resolveReceiverId(dynamic a) {
    final cands = <dynamic>[
      _safe(() => a.ownerId), // من الموديل بعد إضافة ownerId
      _safe(() => a.userId),
      _safe(() => a.user_id),
      _safe(() => a.owner_id),
      _safe(() => a.user?.id),
      _safe(() => a.owner?.id),
      _safe(() => a.publisher?.id),
      _safe(() => a.activeItem?.userId),
      _safe(() => a.activeItem?.user_id),
      _safe(() => a.activeItem?.user?.id),
    ];
    for (final c in cands) {
      final id = _asInt(c);
      if (id != null && id > 0) return id;
    }
    return null;
  }

  String? _extractOwnerPhone(dynamic a) {
    final cands = <dynamic>[
      _safe(() => a.phone),
      _safe(() => a.user?.phone_number),
      _safe(() => a.ownerPhone),
      _safe(() => a.activeItem?.phone),
    ];
    for (final c in cands) {
      final s = c?.toString();
      if (s != null && s.trim().isNotEmpty) return s;
    }
    return null;
  }

  // Chat
  void _startChat(BuildContext context, int receiverId, String receiverName, dynamic auctionDetails) {
    debugPrint('[CAR CHAT] initiate -> receiverId=$receiverId, name=$receiverName, listingId=${auctionDetails.id}');
    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (initialMessage) async {
        final repo = getIt<MessagesRepo>();
        final conversationId = await repo.initiateChat(receiverId);
        debugPrint('[CAR CHAT] conversationId=$conversationId');

        if (conversationId != null) {
          final chatModel = MessagesModel(
            conversationId: conversationId,
            partnerUser: UserModel(id: receiverId, name: receiverName),
            lastMessage: initialMessage,
          );

          final adInfo = AdInfo(
            id: auctionDetails.id,
            title: auctionDetails.title,
            imageUrl: (auctionDetails.activeItem.images is List && auctionDetails.activeItem.images.isNotEmpty)
                ? auctionDetails.activeItem.images.first
                : (auctionDetails.thumbnail ?? ''),
            price: (auctionDetails.maxBid ?? num.tryParse(auctionDetails.minBidValue ?? '') ?? 0).toString(),
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

  // Bid dialog
  Future<void> _showBidDialog({
    required num currentHighest,
    required num minBid,
    required DateTime endDate,
    required int auctionId,
    required int itemId,
  }) async {
    final ended = DateTime.now().isAfter(endDate);
    final controller = TextEditingController();
    final incs = <int>[500, 1000, 1500, 2000];

    final key = 'car-$auctionId';
    AuctionBidCubit bidCubit;
    if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
      bidCubit = getIt<AuctionBidCubit>(instanceName: key);
    } else {
      bidCubit = AuctionBidCubit(
        getIt<AuctionBidRepo>(),
        auctionId: auctionId,
        auctionType: 'car',
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

                      final left = endDate.difference(DateTime.now());
                      final endedNow = left.isNegative;

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
                              gradient: const LinearGradient(
                                colors: [ColorsManager.blueGradient1, ColorsManager.blueGradient2],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined, color: Colors.white),
                                horizontalSpace(8),
                                const Text('أعلى مزايدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                          verticalSpace(8),

                          Text('الحد الأدنى للزيادة ${_fmt(minBid)} ريال', style: TextStyles.font12Dark500400Weight),
                          verticalSpace(12),

                          Wrap(
                            spacing: 8.w,
                            children: incs.map((e) {
                              return OutlinedButton(
                                onPressed: (ended || endedNow || isLoading) ? null : () => addInc(e),
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
                              onPressed: (ended || endedNow || isLoading)
                                  ? null
                                  : () {
                                final v = num.tryParse(controller.text.trim());
                                if (v == null) {
                                  ScaffoldMessenger.of(consumerCtx).showSnackBar(const SnackBar(content: Text('أدخل رقمًا صحيحًا')));
                                  return;
                                }
                                if (v <= currentMaxBid) {
                                  ScaffoldMessenger.of(consumerCtx).showSnackBar(const SnackBar(content: Text('يجب أن تكون المزايدة أعلى من أعلى مزايدة')));
                                  return;
                                }
                                if (v < minBid) {
                                  ScaffoldMessenger.of(consumerCtx).showSnackBar(const SnackBar(content: Text('المزايدة أقل من الحد الأدنى المسموح')));
                                  return;
                                }
                                bidCubit.placeBid(bidAmount: v);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.primary400,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: isLoading
                                  ? Skeletonizer(
                                enabled: true,
                                child: Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                              )
                                  : const Text('قم بالمزايدة'),
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

  // Small square icon button helper
  Widget _squareIconBtn({required Widget icon, required Color bg, Color? borderColor, VoidCallback? onTap}) {
    final disabled = onTap == null;
    return Material(
      color: disabled ? Colors.grey.shade300 : bg,
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

  // Loading skeleton
  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 84.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 280.h, width: double.infinity, color: Colors.white),
            verticalSpace(16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14.h, width: 120.w, color: Colors.white),
                  verticalSpace(8),
                  Container(height: 20.h, width: 220.w, color: Colors.white),
                ],
              ),
            ),
            verticalSpace(12),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: List.generate(
                  4,
                      (i) => Container(
                    width: (MediaQuery.of(context).size.width - 16.w * 2 - 12.w) / 2,
                    height: 80.h,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            verticalSpace(16),
            const MyDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Container(width: 40.w, height: 40.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  horizontalSpace(8),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Container(height: 12.h, width: double.infinity, color: Colors.white),
                  verticalSpace(8),
                  Container(height: 12.h, width: double.infinity, color: Colors.white),
                  verticalSpace(8),
                  Container(height: 12.h, width: 220.w, color: Colors.white),
                ],
              ),
            ),
            verticalSpace(16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            verticalSpace(12),
            const MyDivider(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    final key = 'car-${widget.id}';
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
        BlocProvider<CarAuctionDetailsCubit>(
          create: (context) => getIt<CarAuctionDetailsCubit>()
            ..fetchAuction(widget.id, activeItemId: widget.initialItemId), // ✅ دعم تفعيل عنصر محدد
        ),
        BlocProvider<CommentSendCubit>(create: (context) => getIt<CommentSendCubit>()),
        BlocProvider<ProfileCubit>(create: (context) => getIt<ProfileCubit>()..loadProfile()),
        BlocProvider<FavoritesCubit>(create: (context) => getIt<FavoritesCubit>()..fetchFavorites()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const MySvg(image: 'logo', isImage: false),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CarAuctionDetailsCubit, CarAuctionDetailsState>(
            builder: (context, state) {
              if (state is CarAuctionDetailsLoading) {
                return _buildLoadingSkeleton();
              }
              if (state is CarAuctionDetailsFailure) {
                return Center(child: Text(state.message));
              }
              if (state is CarAuctionDetailsSuccess) {
                final a = state.details;

                final imgs = a.activeItem.images.isNotEmpty
                    ? a.activeItem.images
                    : (a.thumbnail != null ? [a.thumbnail!] : <String>[]);

                final highest = a.maxBid ??
                    num.tryParse(a.activeItem.startingPrice ?? '') ??
                    num.tryParse(a.minBidValue) ??
                    0;
                final minBid = num.tryParse(a.minBidValue) ?? 0;
                final itemId = a.activeItem.id;

                final receiverId = _resolveReceiverId(a) ?? _resolveReceiverId(a as dynamic);
                final ownerName = a.ownerName;
                final ownerPicture = a.ownerPicture;
                final phone = _extractOwnerPhone(a);

                final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
                final myUsername = context.select<ProfileCubit, String?>((c) => c.user?.username);
                final isOwner = (myId != null && receiverId != null && myId == receiverId) ||
                    ((myUsername?.trim().isNotEmpty ?? false) && (ownerName.trim() == myUsername?.trim()));

                // shared WS cubit
                final key = 'car-${a.id}';
                AuctionBidCubit auctionBidCubit;
                if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
                  auctionBidCubit = getIt<AuctionBidCubit>(instanceName: key);
                } else {
                  auctionBidCubit = AuctionBidCubit(
                    getIt<AuctionBidRepo>(),
                    auctionId: a.id,
                    auctionType: 'car',
                    itemId: itemId,
                    currentMaxBid: highest,
                  );
                  getIt.registerSingleton<AuctionBidCubit>(auctionBidCubit, instanceName: key);
                  auctionBidCubit.joinAuction();
                }

                final isMultiple = (a.type.toLowerCase() == 'multiple') || (a.items.length > 1);

                return MultiBlocProvider(
                  providers: [
                    BlocProvider<AuctionBidCubit>.value(value: auctionBidCubit),
                  ],
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 84.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarDetailsImages(
                          images: imgs,
                          adId: a.id,
                          favoriteType: 'auction',
                        ),
                        CarStoryAndTitle(title: a.title),
                        CarDetailsPanel(
                          city: '',
                          region: '',
                          createdAt: a.createdAt,
                        ),
                        verticalSpace(8),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: AuctionCarInfoGridView(item: a.activeItem),
                        ),

                        const MyDivider(),

                        // Owner
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: RealEstateCurrentUserInfo(
                            ownerName: ownerName,
                            onTap: () {
                              final id = receiverId;
                              if (id == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تعذر تحديد معرف الناشر')),
                                );
                                return;
                              }
                              Navigator.of(context).pushNamed(
                                Routes.userProfileScreenId,
                                arguments: id,
                              );
                            },
                            ownerPicture: ownerPicture,
                            userTitle: 'مالك السيارة',
                          ),
                        ),
                        verticalSpace(8),
                        const MyDivider(),

                        CarInfoDescription(description: a.description.isEmpty ? 'لا يوجد' : a.description),
                        verticalSpace(12),

                        // ✅ المزادات القادمة (قائمة العناصر في المزاد المتعدد)
                        if (isMultiple && a.items.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('المزادات القادمة', style: TextStyles.font18Black500Weight),
                                verticalSpace(8),
                                ListView.separated(
                                  itemCount: a.items.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (_, __) => verticalSpace(10),
                                  itemBuilder: (ctx, i) {
                                    final item = a.items[i];
                                    final isActiveItem = item.id == a.activeItem.id;
                                    return _AuctionItemCard(
                                      item: item,
                                      isActive: isActiveItem,
                                      onTap: () {
                                        if (isActiveItem) return;

                                        // اغلاق سوكيت العنصر الحالي قبل الانتقال
                                        final key = 'car-${a.id}';
                                        if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
                                          final c = getIt<AuctionBidCubit>(instanceName: key);
                                          c.leaveAuction();
                                          getIt.unregister<AuctionBidCubit>(instanceName: key);
                                        }

                                        // فتح نفس الشاشة مع العنصر الجديد كمفعّل
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => CarAuctionDetailsScreen(
                                              id: a.id,
                                              initialItemId: item.id,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                verticalSpace(12),
                              ],
                            ),
                          ),
                          const MyDivider(),
                        ],

                        BlocBuilder<AuctionBidCubit, AuctionBidState>(
                          builder: (context, bidState) {
                            final currentMaxBid = bidState.currentMaxBid;
                            return _HighestBidBar(
                              highestText: _fmt(currentMaxBid),
                              endDate: a.endDate,
                            );
                          },
                        ),

                        const MyDivider(),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),

        bottomNavigationBar: BlocBuilder<CarAuctionDetailsCubit, CarAuctionDetailsState>(
          builder: (context, state) {
            if (state is! CarAuctionDetailsSuccess) return const SizedBox.shrink();
            final a = state.details;
            final ended = DateTime.now().isAfter(a.endDate);

            final receiverId = _resolveReceiverId(a) ?? _resolveReceiverId(a as dynamic);
            final ownerName = a.ownerName;
            final phone = _extractOwnerPhone(a);

            final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
            final myUsername = context.select<ProfileCubit, String?>((c) => c.user?.username);
            final isOwner = (myId != null && receiverId != null && myId == receiverId) ||
                ((myUsername?.trim().isNotEmpty ?? false) && (ownerName.trim() == myUsername?.trim()));

            final highest = a.maxBid ??
                num.tryParse(a.activeItem.startingPrice ?? '') ??
                num.tryParse(a.minBidValue) ??
                0;
            final minBid = num.tryParse(a.minBidValue) ?? 0;
            final itemId = a.activeItem.id;

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
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isOwner) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا يمكنك المزايدة على إعلانك.')),
                            );
                            return;
                          }
                          if (ended) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('انتهى وقت المزايدة على هذا الإعلان.')),
                            );
                            return;
                          }
                          await _showBidDialog(
                            currentHighest: highest,
                            minBid: minBid,
                            endDate: a.endDate,
                            auctionId: a.id,
                            itemId: itemId,
                          );
                        },
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
                    icon: const MySvg(image: 'message_icon', color: ColorsManager.primaryColor),
                    bg: ColorsManager.primary50,
                    borderColor: const Color(0xFFEAEAEA),
                    onTap: () {
                      final myId = context.read<ProfileCubit>().user?.userId;
                      if (myId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يجب تسجيل الدخول أولاً لبدء المحادثة.')),
                        );
                        return;
                      }
                      if (receiverId == null || ownerName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر تحديد معلومات المالك لبدء المحادثة.')),
                        );
                        debugPrint('[CAR CHAT] resolve receiverId failed. ownerName="$ownerName"');
                        return;
                      }
                      if (isOwner) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('لا يمكنك المحادثة مع نفسك.')),
                        );
                        return;
                      }
                      _startChat(context, receiverId, ownerName, a);
                    },
                  ),
                  horizontalSpace(8),
                  // الاتصال: متاح دائمًا، يعرض رسالة إذا لا يوجد رقم
                  _squareIconBtn(
                    icon: const MySvg(image: 'callCalling', color: ColorsManager.primaryColor),
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
                  // واتساب: متاح دائمًا، يعرض رسالة إذا لا يوجد رقم
                  _squareIconBtn(
                    icon: const MySvg(image: 'logos_whatsapp'),
                    bg: ColorsManager.success200,
                    onTap: () {
                      final p = phone;
                      if (p?.isNotEmpty ?? false) {
                        launchWhatsApp(context, p!, message: 'مرحباً 👋 بخصوص إعلان المزاد: ${a.title}');
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
          },
        ),
      ),
    );
  }
}

// Standalone widget (outside State)
// ✅ كارد عرض أعلى مزايدة
class _HighestBidBar extends StatefulWidget {
  final String highestText;
  final DateTime endDate;
  const _HighestBidBar({required this.highestText, required this.endDate});

  @override
  State<_HighestBidBar> createState() => _HighestBidBarState();
}

class _HighestBidBarState extends State<_HighestBidBar> {
  late Timer _timer;
  late Duration _left;

  @override
  void initState() {
    super.initState();
    _left = widget.endDate.difference(DateTime.now());
    _start();
  }

  @override
  void didUpdateWidget(covariant _HighestBidBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endDate != widget.endDate) {
      _left = widget.endDate.difference(DateTime.now());
      _timer.cancel();
      _start();
    }
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final d = widget.endDate.difference(DateTime.now());
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

  // ✅ تنسيق المبالغ المالية ووضع الفواصل بين كل 3 أرقام
  String _fmt(num? v) {
    if (v == null) return '0';
    final s = v.toStringAsFixed(0); // نضمن عدم وجود كسور عشرية
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  String _fmt2(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final ended = _left == Duration.zero;
    final days = _left.inDays;
    final hours = _left.inHours % 24;
    final mins = _left.inMinutes % 60;
    final secs = _left.inSeconds % 60;

    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorsManager.blueGradient1, ColorsManager.blueGradient2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          // العداد الزمني
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              ended
                  ? 'انتهى'
                  : (days > 0
                  ? 'باقي $days يوم ${_fmt2(hours)}:${_fmt2(mins)}:${_fmt2(secs)}'
                  : 'باقي ${_fmt2(hours)}:${_fmt2(mins)}:${_fmt2(secs)}'),
              style: TextStyles.font12White400Weight,
            ),
          ),

          horizontalSpace(8),

          const Icon(Icons.monetization_on_outlined, color: Colors.white),
          horizontalSpace(6),
          const Text(
            'أعلى مزايدة',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),

          // ✅ عرض المبلغ بالفواصل
          Row(
            children: [
              const Text('ريال', style: TextStyle(color: Colors.white)),
              horizontalSpace(6),
              Text(
                _fmt(num.tryParse(widget.highestText)), // ✅ تطبيق الدالة الجديدة
                style: TextStyles.font24White500Weight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ كارد عنصر مزاد (لعرض العناصر في المزاد المتعدد)
class _AuctionItemCard extends StatelessWidget {
  final CarAuctionListItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _AuctionItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    this.isActive = false,
  }) : super(key: key);

  String _title() {
    if (item.title.trim().isNotEmpty) return _withYear(item.title, item.year);
    final brand = (item.brandName ?? '').trim();
    final model = (item.modelNameAr ?? item.modelNameEn ?? '').trim();
    final base = [brand, model].where((e) => e.isNotEmpty).join(' ');
    return _withYear(base, item.year);
  }

  String _withYear(String base, int? y) => y != null && y > 0 ? '$base ($y)' : base;

  String _arMonthName(int m) {
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return (m >= 1 && m <= 12) ? months[m] : '';
  }

  @override
  Widget build(BuildContext context) {
    final img = (item.images.isNotEmpty) ? item.images.first : null;
    final day = item.startDate.day;
    final month = _arMonthName(item.startDate.month);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 5)),
            ],
            border: isActive ? Border.all(color: ColorsManager.primary300, width: 1) : null,
          ),
          child: Row(
            children: [
              // الجهة اليسار (جرس + تاريخ + عنوان + وسوم)
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 4.w, end: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // جرس + تاريخ
                      Row(
                        children: [
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none, size: 18, color: Color(0xFF9E9E9E)),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B7280)),
                                SizedBox(width: 4.w),
                                Text('$day $month', style: TextStyles.font12Dark500400Weight),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // العنوان
                      Text(
                        _title(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      SizedBox(height: 6.h),
                      // وسوم صغيرة (اللون - السلندرات - نظام الدفع/المواصفات)
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          if ((item.color ?? '').trim().isNotEmpty) _MiniChip(text: item.color!.trim()),
                          if (item.cylinders != null) _MiniChip(icon: Icons.settings_input_component, text: '${item.cylinders} سلندر'),
                          if ((item.drivetrain ?? '').trim().isNotEmpty) _MiniChip(icon: Icons.directions_car_filled_outlined, text: item.drivetrain!.trim()),
                          if ((item.specs ?? '').trim().isNotEmpty) _MiniChip(icon: Icons.build_outlined, text: item.specs!.trim()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // الجهة اليمين (صورة + بادج رقم)
              SizedBox(
                width: 88.w,
                height: 72.h,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: img != null
                            ? Image.network(img, fit: BoxFit.cover)
                            : Container(
                          color: const Color(0xFFF1F1F1),
                          child: const Icon(Icons.directions_car_filled, color: Color(0xFFBDBDBD)),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 6.h,
                      start: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A5F),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '#${item.id}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData? icon;
  final String text;

  const _MiniChip({Key? key, this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF6B7280)),
            SizedBox(width: 4.w),
          ],
          Text(text, style: TextStyles.font12Dark500400Weight),
        ],
      ),
    );
  }
}