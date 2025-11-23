import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import '../../data/model/dinat_trip.dart';

class DynaTripDetailsSheet extends StatelessWidget {
  final DynaTrip trip;
  final VoidCallback? onJoin;      // استدعِ الأكشن المطلوب للانضمام
  final VoidCallback? onChat;      // افتح شاشة محادثة مثلاً

  const DynaTripDetailsSheet({
    super.key,
    required this.trip,
    this.onJoin,
    this.onChat,
  });

  static Future<void> show(
      BuildContext context, {
        required DynaTrip trip,
        VoidCallback? onJoin,
        VoidCallback? onChat,
      }) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DynaTripDetailsSheet(trip: trip, onJoin: onJoin, onChat: onChat),
        ),
      ),
    );
  }

  String _fmtRange(DateTime a, DateTime b) {
    String two(int v) => v.toString().padLeft(2, '0');
    final ad = '${two(a.day)}/${two(a.month)}/${a.year}  ${two(a.hour)}:${two(a.minute)}';
    final bd = '${two(b.day)}/${two(b.month)}/${b.year}  ${two(b.hour)}:${two(b.minute)}';
    return '$ad → $bd';
  }

  String _capacityLabel(String cap) {
    // خرّج label بسيط حسب السعة
    final n = int.tryParse(cap) ?? 0;
    if (n >= 20) return 'كبيرة';
    if (n >= 10) return 'متوسطة';
    if (n > 0) return 'صغيرة';
    return cap;
    // أو بدّلها بـ trip.vehicleSize إذا صار متاح في الموديل لديك
  }

  String _title() {
    // ابني عنوان قريب من المثال
    final from = trip.fromCityNameAr.isNotEmpty ? trip.fromCityNameAr : '—';
    final to = trip.toCityNameAr.isNotEmpty ? trip.toCityNameAr : '—';
    final cargo = trip.pickUpAddress ?? 'طلب نقل';
    return '$cargo - من $from إلى $to';
  }

  Future<void> _openTel() async {
    final raw = (trip.providerPhone).replaceAll(' ', '').replaceAll('–', '').replaceAll('-', '');
    final uri = Uri.parse('tel:$raw');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp() async {
    // حوّل الرقم لـ 966..
    final digits = trip.providerPhone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent('مرحباً، بخصوص رحلة الديّنا #${trip.id}')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMap() async {
    // إن لم تكن تملك إحداثيات استخدم أسماء المدن
    final from = trip.routeStart?.isNotEmpty == true ? trip.routeStart! : trip.fromCityNameAr;
    final to   = trip.routeEnd?.isNotEmpty == true ? trip.routeEnd! : trip.toCityNameAr;
    final q = Uri.encodeComponent('$from to $to');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final dep = DateTime.tryParse(trip.departureDateIso);
    final arr = DateTime.tryParse(trip.arrivalDateIso);
    final rangeTxt = (dep != null && arr != null) ? _fmtRange(dep, arr) : 'غير محدّد';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // هيدر
          Row(
            children: [
              Expanded(child: Center(child: Text('تفاصيل الرحلة', style: TextStyles.font18Black500Weight))),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                splashRadius: 22,
              ),
            ],
          ),
          verticalSpace(8),

          // خريطة Placeholder
          _MapPreviewBox(),

          verticalSpace(12),

          // العنوان
          Align(
            alignment: Alignment.centerRight,
            child: Text(_title(), style: TextStyles.font16Black500Weight, textAlign: TextAlign.right),
          ),
          verticalSpace(10),

          // سطور المعلومات
          _InfoRow(icon: Icons.location_on_outlined, text: '${trip.fromCityNameAr}  →  ${trip.toCityNameAr}'),
          verticalSpace(6),
          _InfoRow(icon: Icons.timer_outlined, text: rangeTxt),
          verticalSpace(6),
          _InfoRow(icon: Icons.local_shipping_outlined, text: 'سعة الديّنا: ${_capacityLabel(trip.dynaCapacity)} (${trip.dynaCapacity})'),
          if ((trip.routeStart ?? '').isNotEmpty) ...[
            verticalSpace(6),
            _InfoRow(icon: Icons.flag_outlined, text: 'نقطة البداية: ${trip.routeStart}'),
          ],
          if ((trip.routeEnd ?? '').isNotEmpty) ...[
            verticalSpace(6),
            _InfoRow(icon: Icons.outlined_flag, text: 'نقطة النهاية: ${trip.routeEnd}'),
          ],
          verticalSpace(6),
          GestureDetector(
            onTap: _openMap,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('عرض الموقع على الخريطة', style: TextStyles.font14Primary500Weight),
            ),
          ),
          verticalSpace(12),

          // مزود الخدمة
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: ColorsManager.grey200,
                backgroundImage: (trip.providerImage.isNotEmpty)
                    ? NetworkImage(trip.providerImage)
                    : null,
                child: (trip.providerImage.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              horizontalSpace(8),
              Expanded(
                child: Text(trip.providerName, style: TextStyles.font14Black500Weight, textAlign: TextAlign.right),
              ),
            ],
          ),

          verticalSpace(14),

          // أزرار تواصل + CTA
          Row(
            children: [
              // واتساب
              _RoundIconButton(
                icon: '',
                color: Colors.green.shade600,
                onTap: _openWhatsApp,
                tooltip: 'واتساب',
              ),
              horizontalSpace(8),
              // اتصال
              _RoundIconButton(
                icon: '',
                color: ColorsManager.primaryColor,
                onTap: _openTel,
                tooltip: 'اتصال',
              ),
              horizontalSpace(8),
              // دردشة
              _RoundIconButton(
                icon: '',
                color: Colors.blueGrey,
                onTap: onChat,
                tooltip: 'محادثة',
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  text: 'الانضمام إلى الرحلة',
                  onPressed: onJoin ?? () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPreviewBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // خط بسيط كـ route
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePainter(),
            ),
          ),
          // نقاط
          Positioned(top: 20, left: 20, child: _pin(Colors.red)),
          Positioned(bottom: 20, right: 20, child: _pin(Colors.green)),
        ],
      ),
    );
  }

  Widget _pin(Color c) => Icon(Icons.location_pin, color: c, size: 28);
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black12
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * .2, size.height * .2)
      ..quadraticBezierTo(size.width * .5, size.height * .5, size.width * .8, size.height * .8);
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        horizontalSpace(6),
        Expanded(child: Text(text, style: TextStyles.font14DarkGray400Weight, textAlign: TextAlign.right)),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback? onTap;
  final String? tooltip;
  const _RoundIconButton({required this.icon, required this.color, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: color.withOpacity(.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: MySvg(image:icon,),
          ),
        ),
      ),
    );
  }
}