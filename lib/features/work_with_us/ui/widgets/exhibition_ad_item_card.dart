// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:mushtary/core/theme/colors.dart';
// import 'package:mushtary/core/theme/text_styles.dart';
// import 'package:mushtary/core/widgets/primary/my_svg.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:skeletonizer/skeletonizer.dart';
//
// import '../../../../core/router/routes.dart'; // ✅ NEW: للـ navigation constants
// import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
// import '../../../favorites/ui/logic/cubit/favorites_state.dart';
// import '../../../../core/utils/helpers/spacing.dart';
// import '../../data/model/exhibition_details_models.dart'; // للـ ExhibitionAd model
//
// class ExhibitionAdItemCard extends StatelessWidget {
//   final ExhibitionAd ad; // ✅ NEW: استخدم ExhibitionAd model
//   final bool isFavorited;
//   final VoidCallback? onFavoriteTap;
//
//   const ExhibitionAdItemCard({
//     super.key,
//     required this.ad,
//     this.isFavorited = false,
//     this.onFavoriteTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     timeago.setLocaleMessages('ar', timeago.ArMessages());
//
//     final hasImage = ad.imageUrls.isNotEmpty;
//     final imageUrl = hasImage ? ad.imageUrls.first : '';
//     final favoriteType = 'ad'; // افتراضي للـ exhibition ads
//     final favId = ad.id; // ID الإعلان
//
//     final nf = NumberFormat.decimalPattern('ar');
//     final priceText = ad.price > 0 ? nf.format(ad.price) : '—';
//     final created = DateTime.tryParse(ad.adDate ?? ''); // استخدم adDate من ExhibitionAd
//     final createdAgo = created != null ? timeago.format(created, locale: 'ar') : '';
//
//     return InkWell(
//       onTap: () {
//         // ✅ NEW: Navigation مشابه للـ HomeListViewItem، بناءً على ad type (افترض field categoryType في ExhibitionAd)
//         // غير حسب احتياجك (مثل car_ads, real_estate_ads)
//         switch (ad.categoryType ?? 'other') { // افترض field categoryType في ExhibitionAd
//           case 'car_ads':
//             Navigator.of(context).pushNamed(Routes.carDetailsScreen, arguments: ad.id);
//             break;
//           case 'real_estate_ads':
//             Navigator.of(context).pushNamed(Routes.realEstateDetailsScreen, arguments: ad.id);
//             break;
//           case 'car_parts_ads':
//             Navigator.of(context).pushNamed(Routes.carPartDetailsScreen, arguments: ad.id);
//             break;
//           default:
//             Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: ad.id);
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.all(10.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
//         ),
//         child: Row(
//           children: [
//             // الصورة
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12.r),
//               child: hasImage
//                   ? CachedNetworkImage(
//                 imageUrl: imageUrl,
//                 httpHeaders: const { // ✅ NEW: Headers للـ connection issues
//                   'Connection': 'close',
//                   'User-Agent': 'Flutter/3.0 (Dart)',
//                 },
//                 width: 88.w,
//                 height: 72.h,
//                 fit: BoxFit.cover,
//                 filterQuality: FilterQuality.low,
//                 placeholder: (_, __) => Skeletonizer(
//                   enabled: true,
//                   child: Container(color: ColorsManager.grey200),
//                 ),
//                 errorWidget: (_, __, ___) => Container(
//                   width: 88.w,
//                   height: 72.h,
//                   color: ColorsManager.grey200,
//                   child: const Icon(Icons.broken_image, color: Colors.grey[500]),
//                 ),
//               )
//                   : Container(
//                 width: 88.w,
//                 height: 72.h,
//                 color: ColorsManager.grey200,
//                 child: Icon(Icons.image, color: Colors.grey[500], size: 32),
//               ),
//             ),
//             SizedBox(width: 12.w),
//             // النصوص + Favorites
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                       ad.adTitle,
//                       style: TextStyles.font14Black500Weight,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                       '$priceText رس',
//                       style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)
//                   ),
//                   SizedBox(height: 6.h),
//                   Row(
//                     children: [
//                       Icon(Icons.place, size: 14.r, color: ColorsManager.darkGray),
//                       SizedBox(width: 4.w),
//                       Text('—', style: TextStyles.font12DarkGray400Weight), // لا يوجد اسم مدينة في الاستجابة
//                       SizedBox(width: 8.w),
//                       Icon(Icons.access_time, size: 14.r, color: ColorsManager.darkGray),
//                       SizedBox(width: 4.w),
//                       Text(createdAgo, style: TextStyles.font12DarkGray400Weight),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Favorites Toggle (مشابه للـ HomeListViewItem)
//             BlocBuilder<FavoritesCubit, FavoritesState>(
//               builder: (context, state) {
//                 bool isFav = isFavorited;
//                 if (state is FavoritesLoaded) {
//                   isFav = state.favoriteIds.contains(favId);
//                 }
//                 return GestureDetector(
//                   onTap: onFavoriteTap ?? () => context.read<FavoritesCubit>().toggleFavorite(type: favoriteType, id: favId),
//                   child: Container(
//                     padding: const EdgeInsets.all(2.0),
//                     child: MySvg(
//                       image: "favourite",
//                       width: 20,
//                       height: 20,
//                       color: isFav ? ColorsManager.redButton : Colors.grey[500],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }