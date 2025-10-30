import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart'; // ColorsManager
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

// موديل العقارات (انتبه لمسار date أو data عندك)
import 'package:mushtary/features/real_estate_details/date/model/real_estate_details_model.dart' as re;

import '../screens/real_estate_details_screen.dart';

class RealEstateSimilarStory extends StatefulWidget {
  final List<re.SimilarAd> items;
  final Duration segmentDuration;
  final int initialAdIndex;
  final bool useAllImagesOfEachAd;

  const RealEstateSimilarStory({
    super.key,
    required this.items,
    this.segmentDuration = const Duration(seconds: 4),
    this.initialAdIndex = 0,
    this.useAllImagesOfEachAd = true,
  });

  @override
  State<RealEstateSimilarStory> createState() => _RealEstateSimilarStoryState();
}

class _Frame {
  final re.SimilarAd ad;
  final String? url;
  const _Frame({required this.ad, required this.url});
}

class _RealEstateSimilarStoryState extends State<RealEstateSimilarStory>
    with SingleTickerProviderStateMixin {
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
        if (s == AnimationStatus.completed) {
          _next();
        }
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

  List<_Frame> _buildFrames(List<re.SimilarAd> items, bool useAll) {
    final frames = <_Frame>[];
    for (final ad in items) {
      final urls = ad.imageUrls.isEmpty ? <String?>[null] : ad.imageUrls;
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
    if (!widget.useAllImagesOfEachAd) {
      return widget.initialAdIndex.clamp(0, widget.items.length - 1);
    }
    int idx = 0;
    for (int i = 0; i < widget.initialAdIndex && i < widget.items.length; i++) {
      idx += widget.items[i].imageUrls.isEmpty ? 1 : widget.items[i].imageUrls.length;
    }
    return idx.clamp(0, _frames.length - 1);
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
            // الصورة تغطي الشاشة بالكامل
            Positioned.fill(
              child: frame.url != null && frame.url!.isNotEmpty
                  ? AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: 0.98, // ثابت لحدة اللون؛ لو حاب تخليها ديناميكية غيّرها
                    child: Image.network(
                      frame.url!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover, // أهم سطر: تغطية كاملة
                      errorBuilder: (_, __, ___) => _placeholder(),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  );
                },
              )
                  : _placeholder(),
            ),

            // تدرّجات علوية/سفلية لقراءة أوضح
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorsManager.black.withOpacity(0.75),
                        ColorsManager.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        ColorsManager.black.withOpacity(0.75),
                        ColorsManager.transparent,
                      ],
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
                    _progressBars(
                      count: _frames.length,
                      current: _index,
                      animation: _controller,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _circleIcon(
                          onTap: () => Navigator.of(context).pop(),
                        ),
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

            // أسفل: شِبّات معلومات + زر التفاصيل
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
                      _chip(text: frame.ad.realEstateType),
                      _chip(text: frame.ad.price != null ? '${frame.ad.price}' : '—'),
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RealEstateDetailsScreen(id: frame.ad.id),
                        ),
                      );
                    },
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
                  Container(
                    height: 4.h,
                    color: ColorsManager.white.withOpacity(0.25), // المسار الخلفي
                  ),
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) {
                      double value;
                      if (i < current) {
                        value = 1;
                      } else if (i == current) {
                        value = animation.value;
                      } else {
                        value = 0;
                      }
                      return FractionallySizedBox(
                        widthFactor: value,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 4.h,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorsManager.primary500,  // بداية التدرّج
                                ColorsManager.secondary500, // نهاية التدرّج
                              ],
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
      child: Text(
        text,
        style: TextStyles.font12White500Weight,
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Colors.black,
    child: Center(
      child: Icon(Icons.image_outlined, color: Colors.white30, size: 80),
    ),
  );

  Widget _circleIcon({required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 28.r,
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        // أيقونة الإغلاق الخاصة بك
        child: const MySvg(image: 'close_circle'),
      ),
    );
  }
}