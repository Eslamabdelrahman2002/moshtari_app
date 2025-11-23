// lib/features/services/ui/widgets/dinat_trip_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:url_launcher/url_launcher.dart';

// NEW: إضافات الشات
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/features/messages/data/models/chat_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';

import '../../data/model/dinat_trip.dart'; // DynaTrip
import 'join_request_sent_dialog.dart';

class DinatTripDetailsDialog extends StatelessWidget {
  final DynaTrip trip;
  final VoidCallback? onJoin; // أكشن الانضمام (اختياري)
  final VoidCallback? onChat; // أكشن مخصص للمحادثة (اختياري)

  const DinatTripDetailsDialog({
    super.key,
    required this.trip,
    this.onJoin,
    this.onChat,
  });

  // طريقة عرض سريعة
  static Future<void> show(
      BuildContext context, {
        required DynaTrip trip,
        VoidCallback? onJoin,
        VoidCallback? onChat,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DinatTripDetailsDialog(trip: trip, onJoin: onJoin, onChat: onChat),
    );
  }

  // عنوان مناسب
  String _buildTitle(DynaTrip t) {
    final cargo = (t.cargoType?.trim().isNotEmpty ?? false) ? t.cargoType!.trim() : 'نقل حمولة';
    return '$cargo - من ${t.fromCityNameAr} إلى ${t.toCityNameAr}';
  }

  // تحويل نوع الجدولة لليبل
  String _scheduleLabel(String? scheduleType) {
    switch ((scheduleType ?? '').toLowerCase()) {
      case 'once':
        return 'حالاً';
      case 'scheduled':
      case 'later':
        return 'بموعد';
      default:
        return '—';
    }
  }

  // تحويل السعة إلى ليبل، أو استخدام vehicle_size لو موجود
  String _sizeLabel(DynaTrip t) {
    if ((t.vehicleSize?.trim().isNotEmpty ?? false)) return t.vehicleSize!.trim();
    final n = int.tryParse(t.dynaCapacity) ?? 0;
    if (n >= 20) return 'كبيرة';
    if (n >= 10) return 'متوسطة';
    if (n > 0) return 'صغيرة';
    return '—';
  }

  String get _pickup => (trip.routeStart?.trim().isNotEmpty ?? false) ? trip.routeStart!.trim() : trip.fromCityNameAr;
  String get _dropoff => (trip.routeEnd?.trim().isNotEmpty ?? false) ? trip.routeEnd!.trim() : trip.toCityNameAr;

  // فتح اتصال
  Future<void> _call() async {
    final raw = trip.providerPhone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$raw');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // فتح واتساب
  Future<void> _whatsapp() async {
    final digits = trip.providerPhone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent('مرحباً، بخصوص رحلة الديّنا #${trip.id}')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // NEW: بدء محادثة مثل شاشة تفاصيل السيارة
  void _startChat(BuildContext context) {
    final receiverId = trip.providerId;
    final receiverName = (trip.providerName.trim().isNotEmpty) ? trip.providerName.trim() : 'المزوّد';

    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (initialMessage) async {
        try {
          final repo = getIt<MessagesRepo>();
          final conversationId = await repo.initiateChat(receiverId);

          if (conversationId != null) {
            final chatModel = MessagesModel(
              conversationId: conversationId,
              partnerUser: UserModel(id: receiverId, name: receiverName),
              lastMessage: initialMessage,
            );

            // افتح شاشة المحادثة
            Navigator.of(context).pushNamed(Routes.chatScreen, arguments: chatModel);

            // أرسل الرسالة الأولى بعد الانتقال
            await Future.delayed(const Duration(milliseconds: 300));

            // ملاحظة: إن كان listingId إلزاميّاً لديك، نمرر trip.id
            final body = SendMessageRequestBody(
              receiverId: receiverId,
              messageContent: initialMessage,
              listingId: trip.id, // استخدم id الرحلة كمرجع؛ عدّله إن كان لديك حقول خاصة بالرحلات
            );
            await repo.sendMessage(body, conversationId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر بدء المحادثة الآن.')));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _buildTitle(trip);
    final schedule = _scheduleLabel(trip.scheduleType);
    final cargo = (trip.cargoType?.trim().isNotEmpty ?? false) ? trip.cargoType!.trim() : '—';
    final size = _sizeLabel(trip);
    final providerImg = trip.providerImage; // قد يكون فارغ ''

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  verticalSpace(14),

                  // عنوان أعلى: تفاصيل الرحلة
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Text('تفاصيل الرحلة', style: TextStyles.font18Black500Weight),
                    ),
                  ),
                  verticalSpace(12),

                  // كارت الخريطة (Asset ثابت كعرض بصري فقط)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Image.asset(
                          'assets/images/map_image.png',
                          height: 160.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  verticalSpace(12),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  verticalSpace(8),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // عنوان الطلب (ديناميكي)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyles.font18Black500Weight,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(14),

                        // ملاحظة (extra_details) إن وجدت
                        if ((trip.extraDetails?.trim().isNotEmpty ?? false))
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: _buildLine(iconName: 'comment', text: trip.extraDetails!.trim()),
                          ),

                        // حالاً | نوع الحمولة  +  الحجم/السعة | نوع الشاحنة (نستخدم vehicle_size)
                        Row(
                          children: [
                            _buildDoubleSpec(
                              leftIcon: 'clock',
                              leftText: schedule,
                              rightIcon: 'archive',
                              rightText: cargo,
                            ),
                            horizontalSpace(16),
                            _buildDoubleSpec(
                              leftIcon: 'maximize-3',
                              leftText: size,
                              rightIcon: 'truck',
                              rightText: (trip.vehicleSize?.trim().isNotEmpty ?? false) ? trip.vehicleSize!.trim() : '—',
                            ),
                          ],
                        ),
                        verticalSpace(8),

                        // المسار التفصيلي (ديناميكي)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.place_outlined, size: 18, color: ColorsManager.primaryColor),
                            horizontalSpace(8),
                            Expanded(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: TextStyles.font14Black500Weight,
                                  children: [
                                    TextSpan(text: _pickup),
                                    TextSpan(
                                      text: ' ---> ',
                                      style: TextStyles.font14Black500Weight.copyWith(color: ColorsManager.primaryColor),
                                    ),
                                    TextSpan(text: _dropoff),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(16),

                        // بيانات المزوّد
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.r,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: (providerImg.isNotEmpty)
                                  ? NetworkImage(providerImg)
                                  : const AssetImage('assets/images/prof.png') as ImageProvider,
                            ),
                            horizontalSpace(8),
                            Expanded(
                              child: Text(
                                trip.providerName,
                                style: TextStyles.font16Black500Weight,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        verticalSpace(20),

                        // أيقونات يسار + زر الانضمام يمين
                        Row(
                          children: [
                            // Expanded(
                            //   flex: 2,
                            //   child: SizedBox(
                            //     height: 52.h,
                            //     child: MyButton(
                            //       label: 'الانضمام إلى الرحلة',
                            //       onPressed: () async {
                            //         if (onJoin != null) {
                            //           onJoin!();
                            //           return;
                            //         }
                            //         // افتراضي: إغلاق ثم إظهار Dialog نجاح
                            //         final rootNav = Navigator.of(context, rootNavigator: true);
                            //         rootNav.pop();
                            //         JoinRequestSentDialog.show(
                            //           rootNav.context,
                            //           successIcon: 'join_success',
                            //           onPrimaryAction: () => rootNav.popUntil((r) => r.isFirst),
                            //         );
                            //       },
                            //       backgroundColor: ColorsManager.primaryColor,
                            //       radius: 12.r,
                            //       labelStyle: TextStyles.font16White500Weight,
                            //     ),
                            //   ),
                            // ),
                            // horizontalSpace(12),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // الآن يطلق المحادثة تماماً كالسيارات
                                    Expanded(child: _buildContactIcon('message_icon', onChat ?? () => _startChat(context))),
                                    horizontalSpace(16),
                                    Expanded(child: _buildContactIcon('callCalling', _call)),
                                    horizontalSpace(16),
                                    Expanded(child: _buildContactIcon('mingcute_whatsapp-line', _whatsapp)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // زر الإغلاق أعلى يمين
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: MySvg(
                  image: 'close_circle',
                  height: 22.w,
                  width: 22.w,
                  color: ColorsManager.darkGray300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر سطر أيقونة + نص
  Widget _buildLine({required String iconName, required String text}) {
    return Row(
      children: [
        MySvg(image: iconName, width: 16.w, height: 16.h, color: ColorsManager.darkGray300),
        horizontalSpace(8),
        Expanded(child: Text(text, style: TextStyles.font14Black400Weight, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  // مواصفات مزدوجة (يسار | يمين)
  Widget _buildDoubleSpec({
    required String leftIcon,
    required String leftText,
    required String rightIcon,
    required String rightText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MySvg(image: leftIcon, width: 16.w, height: 16.h, color: ColorsManager.darkGray300),
        horizontalSpace(8),
        Text(leftText, style: TextStyles.font14Black400Weight),
        horizontalSpace(16),
        MySvg(image: rightIcon, width: 16.w, height: 16.h, color: ColorsManager.darkGray300),
        horizontalSpace(8),
        Text(rightText, style: TextStyles.font14Black400Weight),
      ],
    );
  }

  // أيقونات التواصل
  Widget _buildContactIcon(String iconName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(child: MySvg(image: iconName, width: 24.w, height: 24.w)),
    );
  }
}