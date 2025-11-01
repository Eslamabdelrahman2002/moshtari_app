// lib/features/car_details/ui/widgets/car_details/widgets/car_similar_story.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../../../data/model/car_details_model.dart';

class CarSimilarStory extends StatefulWidget {
  final List<SimilarCarAdModel> items;
  final Duration segmentDuration;
  final int initialAdIndex;
  final bool useAllImagesOfEachAd;
  final void Function(SimilarCarAdModel ad)? onOpenDetails;

  const CarSimilarStory({
    super.key,
    required this.items,
    this.segmentDuration = const Duration(seconds: 4),
    this.initialAdIndex = 0,
    this.useAllImagesOfEachAd = false,
    this.onOpenDetails,
  });

  @override
  State<CarSimilarStory> createState() => _CarSimilarStoryState();
}

class _Frame {
  final SimilarCarAdModel ad;
  final String? url;
  const _Frame({required this.ad, required this.url});
}

class _CarSimilarStoryState extends State<CarSimilarStory> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Frame> _frames;
  late int _index;
  bool _paused = false;
  double _dragDy = 0;

  @override
  void initState() {
    super.initState();
    _frames = _buildFrames(widget.items, widget.useAllImagesOfEachAd);
    _index = _initialFrameIndex();
    _controller = AnimationController(vsync: this, duration: widget.segmentDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      });
    _controller.forward();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<_Frame> _buildFrames(List<SimilarCarAdModel> items, bool useAll) {
    final frames = <_Frame>[];
    for (final ad in items) {
      // لو عندك قائمة صور للسيارة عدّل هذا الجزء لاستخدامها
      final urls = <String?>[ad.image];
      if (useAll) {
        for (final u in urls) {
          frames.add(_Frame(ad: ad, url: u));
        }
      } else {
        frames.add(_Frame(ad: ad, url: urls.first));
      }
    }
    return frames;
  }

  int _initialFrameIndex() {
    // بما أن default صورة واحدة لكل إعلان، نكتفي بهذه
    return widget.initialAdIndex.clamp(0, _frames.length - 1);
  }

  void _pause() {
    if (_paused) return;
    setState(() => _paused = true);
    _controller.stop();
  }

  void _resume() {
    if (!_paused) return;
    setState(() => _paused = false);
    _controller.forward();
  }

  void _prev() {
    if (_index <= 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index--);
    _restart();
  }

  void _next() {
    if (_index >= _frames.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
    _restart();
  }

  void _restart() {
    _controller
      ..duration = widget.segmentDuration
      ..value = 0
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frames[_index];
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTapDown: (d) {
        final dx = d.localPosition.dx;
        if (dx < size.width * 0.33) {
          _prev();
        } else {
          _next();
        }
      },
      onLongPressStart: (_) => _pause(),
      onLongPressEnd: (_) => _resume(),
      onVerticalDragUpdate: (d) {
        _dragDy += d.delta.dy;
        if (!_paused) _pause();
      },
      onVerticalDragEnd: (_) {
        if (_dragDy > 80) {
          Navigator.of(context).pop();
        } else {
          _dragDy = 0;
          _resume();
        }
      },
      child: Scaffold(
        backgroundColor: ColorsManager.blackBackground,
        body: Stack(
          children: [
            // الصورة فول سكرين
            Positioned.fill(
              child: frame.url != null && frame.url!.isNotEmpty
                  ? Image.network(
                frame.url!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return  Center(
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white70)),
                  );
                },
              )
                  : _placeholder(),
            ),

            // تدرّجات للقراءة
            Positioned(
              top: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [ColorsManager.black.withOpacity(0.75), ColorsManager.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [ColorsManager.black.withOpacity(0.75), ColorsManager.transparent],
                    ),
                  ),
                ),
              ),
            ),

            // أعلى: شريط التقدم + إغلاق + عنوان
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _progressBars(count: _frames.length, current: _index, animation: _controller),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _closeBtn(onTap: () => Navigator.of(context).pop()),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            frame.ad.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.font12White500Weight,
                          ),
                        ),
                        if (_paused)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: ColorsManager.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text('موقوف', style: TextStyles.font12White400Weight),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // أسفل: سنة/سعر + زر التفاصيل
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 28.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _chip(text: 'السنة: ${frame.ad.year ?? '-'}'),
                      _chip(text: 'السعر: ${frame.ad.price ?? '—'}'),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryColor,
                      foregroundColor: ColorsManager.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: () => widget.onOpenDetails?.call(frame.ad),
                    child: const Text('عرض التفاصيل'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBars({
    required int count,
    required int current,
    required Animation<double> animation,
  }) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(height: 4.h, color: ColorsManager.white.withOpacity(0.25)),
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) {
                      double value;
                      if (i < current) value = 1;
                      else if (i == current) value = animation.value;
                      else value = 0;

                      return FractionallySizedBox(
                        widthFactor: value,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 4.h,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [ColorsManager.primary500, ColorsManager.secondary500],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _chip({required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: ColorsManager.white.withOpacity(0.2)),
      ),
      child: Text(text, style: TextStyles.font12White500Weight),
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Colors.black,
    child: Center(child: Icon(Icons.image_outlined, color: Colors.white30, size: 80)),
  );

  Widget _closeBtn({required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 28.r,
      child: SizedBox(width: 40.w, height: 40.w, child: const MySvg(image: 'close_circle')),
    );
  }
}