// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mushtary/core/theme/colors.dart';
// import 'package:mushtary/core/theme/text_styles.dart';
// import 'package:mushtary/core/utils/helpers/spacing.dart';
// import 'package:mushtary/core/utils/helpers/time_from_now.dart';
// import 'package:mushtary/core/widgets/primary/my_svg.dart';
// import 'package:mushtary/features/real_estate/data/model/real_estate_listing_item.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//
// class RealEstateCard extends StatefulWidget {
//   final RealEstateListingItem item;
//   const RealEstateCard({super.key, required this.item});
//
//   @override
//   State<RealEstateCard> createState() => _RealEstateCardState();
// }
//
// class _RealEstateCardState extends State<RealEstateCard> {
//   final PageController _pc = PageController();
//
//   @override
//   void dispose() {
//     _pc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final i = widget.item;
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(8.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.07),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // صور
//           SizedBox(
//             height: 150.h,
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.r),
//                   child: PageView.builder(
//                     controller: _pc,
//                     itemCount: (i.imageUrls?.isNotEmpty ?? false) ? i.imageUrls!.length : 1,
//                     itemBuilder: (context, idx) {
//                       final url = (i.imageUrls?.isNotEmpty ?? false)
//                           ? i.imageUrls![idx]
//                           : 'https://via.placeholder.com/600x400?text=No+Image';
//                       return CachedNetworkImage(
//                         imageUrl: url,
//                         fit: BoxFit.cover,
//                         errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded),
//                       );
//                     },
//                   ),
//                 ),
//                 if ((i.imageUrls?.length ?? 0) > 1)
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 6.h),
//                     child: SmoothPageIndicator(
//                       controller: _pc,
//                       count: i.imageUrls!.length,
//                       effect: ExpandingDotsEffect(
//                         dotWidth: 6.w,
//                         dotHeight: 6.w,
//                         radius: 16,
//                         spacing: 4.w,
//                         expansionFactor: 2,
//                         activeDotColor: ColorsManager.white,
//                         dotColor: ColorsManager.dark200,
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: InkWell(
//                     onTap: () {},
//                     child: const MySvg(image: 'favorites'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           verticalSpace(8),
//
//           // السعر + العنوان + معلومات
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 4.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(i.title ?? 'بدون عنوان', style: TextStyles.font14Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
//                 verticalSpace(4),
//                 Row(
//                   children: [
//                     Text(i.price ?? '-', style: TextStyles.font14Blue500Weight),
//                     const Spacer(),
//                     const Icon(Icons.place_rounded, size: 14, color: ColorsManager.darkGray),
//                     SizedBox(width: 4.w),
//                     Text(i.cityName ?? '-', style: TextStyles.font12DarkGray400Weight),
//                   ],
//                 ),
//                 verticalSpace(4),
//                 Row(
//                   children: [
//                     const MySvg(image: 'clock', width: 12, height: 12),
//                     SizedBox(width: 4.w),
//                     Text(i.createdAt?.timeSinceNow() ?? '-', style: TextStyles.font12DarkGray400Weight),
//                     const Spacer(),
//                     const MySvg(image: 'user', width: 12, height: 12),
//                     SizedBox(width: 4.w),
//                     Text(i.username ?? '-', style: TextStyles.font12DarkGray400Weight),
//                   ],
//                 ),
//                 verticalSpace(8),
//                 Row(
//                   children: [
//                     const MySvg(image: 'ruler'),
//                     SizedBox(width: 4.w),
//                     Text(i.regionName ?? '-', style: TextStyles.font10Dark400Grey400Weight),
//                     horizontalSpace(10),
//                     const MySvg(image: 'bed'),
//                     SizedBox(width: 4.w),
//                     Text('${i.roomCount ?? 0} غرف', style: TextStyles.font10Dark400Grey400Weight),
//                     horizontalSpace(10),
//                     const MySvg(image: 'panio'),
//                     SizedBox(width: 4.w),
//                     Text('${i.bathroomCount ?? 0} حمام', style: TextStyles.font10Dark400Grey400Weight),
//                   ],
//                 ),
//                 verticalSpace(4),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }