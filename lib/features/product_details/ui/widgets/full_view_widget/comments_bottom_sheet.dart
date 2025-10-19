import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

// سومات/مزايدات
import 'package:mushtary/features/home/data/models/auctions/bargains_model.dart';
// تعليقات تفاصيل السيارة (لو تستخدمها)
import 'package:mushtary/features/product_details/data/model/car_details_model.dart';

import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_state.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/comment_widget.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int adId;

  // يمكنك تمرير أي منهما أو كليهما
  final List<BargainModel>? bargains;
  final List<CommentModel>? comments;

  const CommentsBottomSheet({
    super.key,
    required this.adId,
    this.bargains,
    this.comments,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final ScrollController _listCtrl = ScrollController();

  bool isCommentEmpty = true;
  String? _lastSentText;

  late List<_CommentEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildInitialEntries();
    _commentController.addListener(_updateIsCommentEmpty);
  }

  @override
  void didUpdateWidget(covariant CommentsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الأب جدّد البيانات، أعد البناء
    if ((oldWidget.bargains?.length ?? 0) != (widget.bargains?.length ?? 0) ||
        (oldWidget.comments?.length ?? 0) != (widget.comments?.length ?? 0)) {
      setState(() {
        _entries = _buildInitialEntries();
      });
    }
  }

  void _updateIsCommentEmpty() {
    final empty = _commentController.text.trim().isEmpty;
    if (empty != isCommentEmpty) {
      setState(() => isCommentEmpty = empty);
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateIsCommentEmpty);
    _commentController.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _onAddOfferTap(BuildContext context) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح شاشة إضافة سومة')),
    );
  }

  void _onSendCommentTap(BuildContext context) {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    _lastSentText = commentText;
    FocusScope.of(context).unfocus();
    context.read<CommentSendCubit>().submit(
      adId: widget.adId,
      comment: commentText,
    );
  }

  // بناء أولي للمدخلات من المصادر الممررة
  List<_CommentEntry> _buildInitialEntries() {
    final List<_CommentEntry> entries = [];

    // تعليقات CarDetails (لو متاحة)
    if (widget.comments != null) {
      for (final c in widget.comments!) {
        final userName = c.userName.trim().isNotEmpty ? c.userName.trim() : 'مستخدم';
        final comment = c.text.trim().isNotEmpty ? c.text.trim() : '...';

        entries.add(_CommentEntry(
          userName: userName,
          comment: comment,
          price: null,
          createdAt: null, // CommentModel غالباً بلا تاريخ
        ));
      }
    }

    // السومات/المزايدات
    if (widget.bargains != null) {
      for (final b in widget.bargains!) {
        entries.add(_CommentEntry(
          userName: b.user?.toString() ?? 'مستخدم',
          comment: b.comment?.toString() ?? '',
          price: b.price?.toString(),
          createdAt: b.createdAt, // DateTime? (كما في الموديل)
        ));
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentSendCubit, CommentSendState>(
      listener: (context, state) async {
        if (state.success) {
          // حاول قراءة ProfileCubit إن كان متوفر (إصدارات قديمة تفتقر maybeOf)
          String displayName = 'مستخدم';
          try {
            final username = context.read<ProfileCubit>().user?.username?.trim();
            if (username != null && username.isNotEmpty) {
              displayName = username;
            }
          } catch (_) {
            // ProfileCubit غير متوفر في الشجرة
          }

          // أضف التعليق الجديد محلياً أعلى القائمة (تفاؤلياً)
          setState(() {
            _entries.insert(
              0,
              _CommentEntry(
                userName: displayName,
                comment: _lastSentText ?? '...',
                price: null,
                createdAt: DateTime.now(),
              ),
            );
            _commentController.clear();
            isCommentEmpty = true;
          });

          // تمرير للأعلى لإظهار التعليق الجديد
          await Future.delayed(const Duration(milliseconds: 50));
          if (_listCtrl.hasClients) {
            _listCtrl.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال التعليق بنجاح')),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الإرسال: ${state.error}')),
          );
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Text('التعليقات ', style: TextStyles.font20DarkGray500Weight),
              horizontalSpace(8),
              Text(' (${_entries.length})', style: TextStyles.font16Black500Weight),
            ],
          ),
          verticalSpace(16),
          const Divider(color: ColorsManager.lightGrey),
          verticalSpace(16),

          // القائمة
          _entries.isEmpty
              ? Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "لا توجد تعليقات بعد 👀",
                style: TextStyles.font14DarkGray400Weight,
              ),
            ),
          )
              : SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              controller: _listCtrl,
              itemCount: _entries.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final e = _entries[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: CommentWidget(
                    userName: e.userName,
                    comment: e.comment,
                    price: e.price,
                    createdAt: e.createdAt, // DateTime?
                  ),
                );
              },
            ),
          ),

          // إدخال تعليق جديد
          Container(
            color: ColorsManager.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ColorsManager.dark50,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: TextFormField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorsManager.white,
                          hintText: 'اكتب تعليقك هنا ...........',
                          hintStyle: TextStyles.font12DarkGray400Weight,
                          suffixIcon: isCommentEmpty
                              ? null
                              : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: () => _onAddOfferTap(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: ColorsManager.lightYellow,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '+ اضف سومة',
                                  textAlign: TextAlign.center,
                                  style: TextStyles.font12Blue400Weight
                                      .copyWith(color: ColorsManager.secondary),
                                ),
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace(8),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () => _onSendCommentTap(context),
                    child: isCommentEmpty
                        ? const MySvg(image: 'send_icon')
                        : const MySvg(image: 'send_icon_active'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentEntry {
  final String userName;
  final String comment;
  final String? price;
  final DateTime? createdAt; // ← موحّد

  const _CommentEntry({
    required this.userName,
    required this.comment,
    this.price,
    this.createdAt,
  });
}