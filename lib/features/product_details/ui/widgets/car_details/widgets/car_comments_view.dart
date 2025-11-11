// file: features/product_details/ui/views/car_comments_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/data/model/car_details_model.dart';
import 'package:mushtary/features/product_details/data/model/offer_model.dart'; // ✅ استيراد OfferModel
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

class CarCommentsView extends StatelessWidget {
  final List<CommentModel> comments;
  final List<OfferModel> offers; // ✅ الحقل الجديد لاستقبال العروض

  const CarCommentsView({
    super.key,
    required this.comments,
    required this.offers, // ✅ إضافته للـ constructor
  });

  // ✅ دالة لدمج العروض والتعليقات وتحويلها إلى CommentModel موحد
  List<CommentModel> _combineAndSortItems() {
    // تحويل العروض إلى CommentModel
    final offerComments = offers.map((o) {
      return CommentModel(
        userName: o.userName,
        text: o.offerComment ?? 'عرض سعر فقط', // نص افتراضي إذا لم يكن هناك تعليق
        userPicture: o.userPicture,
        offerPrice: o.offerPrice?.toString(), // تمرير السعر كنص
        createdAt: o.createdAt,
      );
    }).toList();

    // دمج التعليقات والعروض
    final allItems = [...comments, ...offerComments];

    // فرز العناصر حسب تاريخ الإنشاء (الأحدث أولاً)
    allItems.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _combineAndSortItems();

    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);

    if (allItems.isEmpty) { // ✅ التحقق من القائمة المدمجة
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          "لا توجد تعليقات أو عروض بعد 👀",
          style: TextStyles.font14DarkGray400Weight,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("التعليقات والعروض", style: TextStyles.font16Dark300Grey400Weight), // ✅ تعديل العنوان
          verticalSpace(8),
          ...allItems.map((c) { // ✅ استخدام القائمة المدمجة
            final cName = (c.userName).trim();
            final userName = cName.isNotEmpty
                ? cName
                : ((currentUsername?.trim().isNotEmpty ?? false)
                ? currentUsername!.trim()
                : 'مستخدم');

            final text = c.text.trim();

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                createdAt: c.createdAt, // ✅ تمرير تاريخ الإنشاء الآن
                userImageUrl: c.userPicture, // ✅ تمرير صورة المستخدم
                offerPrice: c.offerPrice, // ✅ تمرير سعر العرض
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}