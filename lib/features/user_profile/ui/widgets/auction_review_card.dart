import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AuctionReviewCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final int participantsCount; // من API
  final num highestBid;        // من API
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isLoading;

  final String carTypeDetails; // مشتق من type_auctions + عدد العناصر
  final String location;       // من أول عنصر (مدينة/منطقة إن وجدت)

  final Duration remainingTime; // من API (expires_at)، وإلا Duration.zero

  const AuctionReviewCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.participantsCount,
    required this.highestBid,
    required this.onAccept,
    required this.onReject,
    required this.carTypeDetails,
    required this.location,
    this.isLoading = false,
    this.remainingTime = Duration.zero,
  });

  @override
  State<AuctionReviewCard> createState() => _AuctionReviewCardState();
}

class _AuctionReviewCardState extends State<AuctionReviewCard> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.remainingTime;
    if (_timeRemaining > Duration.zero) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() {
        final d = _timeRemaining - const Duration(seconds: 1);
        _timeRemaining = d.isNegative ? Duration.zero : d;
        if (_timeRemaining == Duration.zero) timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    if (_timeRemaining > Duration.zero) {
      _timer.cancel();
    }
    super.dispose();
  }

  String _fmt(num v) => v.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );

  String _fmt2(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final mins = _timeRemaining.inMinutes % 60;
    final secs = _timeRemaining.inSeconds % 60;

    final canInteract = !widget.isLoading;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تفاصيل المزاد', style: TextStyles.font18Black500Weight),
                    verticalSpace(12),
                    Text(widget.title, style: TextStyles.font16Black500Weight),
                    verticalSpace(4),
                    _InfoRow(
                      icon: const MySvg(image: 'car', width: 16, height: 16, color: ColorsManager.darkGray),
                      text: widget.carTypeDetails,
                      style: TextStyles.font12Dark500500Weight,
                    ),
                    verticalSpace(8),
                    _InfoRow(
                      icon: const MySvg(image: 'users', width: 16, height: 16, color: ColorsManager.darkGray),
                      text: 'عدد العناصر: ${widget.participantsCount}',
                      style: TextStyles.font12DarkGray400Weight,
                    ),
                    verticalSpace(8),
                    _InfoRow(
                      icon: const Icon(Icons.location_on_rounded, size: 16, color: ColorsManager.darkGray),
                      text: widget.location,
                      style: TextStyles.font12DarkGray400Weight,
                    ),
                  ],
                ),
              ),
              horizontalSpace(16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator.adaptive()),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.error, size: 40),
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(16),
          if (_timeRemaining > Duration.zero) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _timerBox(label: 'يوم', value: _fmt2(days)),
                _timerBox(label: 'ساعة', value: _fmt2(hours)),
                _timerBox(label: 'دقيقة', value: _fmt2(mins)),
                _timerBox(label: 'ثانية', value: _fmt2(secs)),
              ],
            ),
            verticalSpace(16),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: ColorsManager.buttonGray,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('أعلى مزايدة', style: TextStyles.font14DarkGray400Weight),
                Text('ريال ${_fmt(widget.highestBid)}', style: TextStyles.font18Black500Weight),
              ],
            ),
          ),
          verticalSpace(16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: canInteract ? widget.onReject : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.white,
                    foregroundColor: ColorsManager.redButton,
                    side: const BorderSide(color: ColorsManager.redButton),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: widget.isLoading
                      ? const Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(ColorsManager.redButton)))
                      : Text('رفض', style: TextStyles.font16Dark300Grey400Weight),
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: canInteract ? widget.onAccept : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.success500,
                    foregroundColor: ColorsManager.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: widget.isLoading
                      ? const Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(ColorsManager.white)))
                      : Text('قبول', style: TextStyles.font16White500Weight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerBox({required String label, required String value}) {
    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorsManager.buttonGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: ColorsManager.primaryColor, fontSize: 18.sp, fontWeight: FontWeight.w700)),
          verticalSpace(2),
          Text(label, style: TextStyles.font10darkGrayWeight400),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final TextStyle style;
  const _InfoRow({required this.icon, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [icon, horizontalSpace(4), Text(text, style: style)],
    );
  }
}