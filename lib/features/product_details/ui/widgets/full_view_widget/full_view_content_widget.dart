import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_bottom_sheet.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_cubit.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_state.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/advertising_market_dialog.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/comments_bottom_sheet.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/user_info_widget.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/view_side_button.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import '../../../../home/data/models/auctions/bargains_model.dart';

class FullViewContentWidget extends StatelessWidget {
  final HomeAdModel adModel;
  const FullViewContentWidget({super.key, required this.adModel});

  String _formatCreatedAt(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "منذ ${diff.inMinutes} دقيقة";
      if (diff.inHours < 24) return "منذ ${diff.inHours} ساعة";
      return "منذ ${diff.inDays} يوم";
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuction = adModel.auctionDisplayType != null;
    final favoriteType = isAuction ? 'auction' : 'ad';
    final favId = isAuction ? (adModel.auctionId ?? adModel.id) : adModel.id;

    final String? ownerProfilePicture = null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.blackBackground,
            ColorsManager.blackBackground.withOpacity(0.65),
            ColorsManager.blackBackground.withOpacity(0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (adModel.price != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ColorsManager.blueGradient1, ColorsManager.blueGradient2],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: Row(
                            children: [
                              Text('السعر', style: TextStyles.font12Primary100400Weight),
                              SizedBox(width: 4.w),
                              const MySvg(image: 'send'),
                              SizedBox(width: 8.w),
                              Text(adModel.price ?? '---', style: TextStyles.font16White500Weight),
                              SizedBox(width: 4.w),
                              MySvg(image: 'saudi_riyal', width: 16.w, height: 16.h),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        adModel.title,
                        style: TextStyles.font20White500Weight,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(_formatCreatedAt(adModel.createdAt), style: TextStyles.font12White400Weight),
                    SizedBox(height: 16.h),
                    UserInfoWidget(username: adModel.username, profilePicture: ownerProfilePicture),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        ListViewItemDataWidget(
                          text: adModel.location,
                          image: 'location-yellow',
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 100.w),
                        ListViewItemDataWidget(
                          text: adModel.price ?? '---',
                          image: 'saudi_riyal',
                          width: 20.w,
                          height: 20.h,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  BlocSelector<FavoritesCubit, FavoritesState, bool>(
                    selector: (state) {
                      if (state is FavoritesLoaded) return state.favoriteIds.contains(favId);
                      return false;
                    },
                    builder: (context, isFav) => ViewSideButton(
                      onTap: () => context.read<FavoritesCubit>().toggleFavorite(type: favoriteType, id: favId),
                      image: 'favourite',
                      iconColor: isFav ? ColorsManager.redButton : Colors.white,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ViewSideButton(
                    onTap: () {
                      showPrimaryBottomSheet(
                        context: context,
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider<CommentSendCubit>(create: (_) => getIt<CommentSendCubit>()),
                            BlocProvider<ProfileCubit>.value(value: context.read<ProfileCubit>()),
                          ],
                          child: CommentsBottomSheet(
                            adId: adModel.id,
                            bargains: const <BargainModel>[],
                          ),
                        ),
                      );
                    },
                    image: 'comment',
                  ),
                  SizedBox(height: 24.h),
                  ViewSideButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          final size = MediaQuery.of(context).size;
                          return Dialog(
                            backgroundColor: ColorsManager.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                            insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 380.w, maxHeight: size.height * 0.85),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                child: AdvertisingMarketDialog(adModel: adModel),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    image: 'share_icon',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 11.h),
        ],
      ),
    );
  }
}