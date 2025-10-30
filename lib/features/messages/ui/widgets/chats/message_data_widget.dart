import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class MessageDataWidget extends StatefulWidget {
  final String message; // ممكن يكون نص أو رابط أو path
  final bool isSended;
  final String? messageType; // text, image, voice, file

  const MessageDataWidget({
    super.key,
    required this.message,
    this.isSended = true,
    this.messageType = 'text',
  });

  @override
  State<MessageDataWidget> createState() => _MessageDataWidgetState();
}

class _MessageDataWidgetState extends State<MessageDataWidget> {
  final ap.AudioPlayer _player = ap.AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get _isImage {
    final m = widget.message.toLowerCase();
    return widget.messageType == 'image' ||
        m.endsWith('.jpg') ||
        m.endsWith('.jpeg') ||
        m.endsWith('.png') ||
        m.endsWith('.webp');
  }

  bool get _isVoice =>
      widget.messageType == 'voice' ||
          widget.message.toLowerCase().endsWith('.m4a') ||
          widget.message.toLowerCase().endsWith('.aac');

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    try {
      setState(() => _isLoading = true);
      if (_isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        final source = widget.message.startsWith('http')
            ? ap.UrlSource(widget.message)
            : ap.DeviceFileSource(widget.message);
        await _player.play(source);
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSender = widget.isSended;
    final bubbleColor =
    isSender ? ColorsManager.primary400 : ColorsManager.dark100;

    if (_isImage) {
      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: widget.message.startsWith('http')
                ? Image.network(widget.message,
                width: 200.w, height: 200.w, fit: BoxFit.cover)
                : Image.file(File(widget.message),
                width: 200.w, height: 200.w, fit: BoxFit.cover),
          ),
        ),
      );
    }

    if (_isVoice) {
      // 🎧 واجهة الرسائل الصوتية
      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          width: 230.w,
          decoration: BoxDecoration(
            color: isSender ? ColorsManager.primary400 : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // زر تشغيل
              GestureDetector(
                onTap: _isLoading ? null : _playPause,
                child: _isLoading
                    ? SpinKitThreeBounce(
                  size: 16.sp,
                  color: isSender ? Colors.white : ColorsManager.primary400,
                )
                    : Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: isSender ? Colors.white : ColorsManager.primary400,
                  size: 32.sp,
                ),
              ),
              SizedBox(width: 10.w),
              // شريط الصوت
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: _position.inSeconds.toDouble(),
                      min: 0,
                      max: _duration.inSeconds.toDouble() == 0
                          ? 1
                          : _duration.inSeconds.toDouble(),
                      onChanged: (v) async {
                        final newPos = Duration(seconds: v.toInt());
                        await _player.seek(newPos);
                      },
                      activeColor:
                      isSender ? Colors.white : ColorsManager.primary400,
                      inactiveColor: Colors.grey.shade300,
                    ),
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        color: isSender ? Colors.white70 : Colors.black54,
                        fontSize: 11.sp,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 📝 نصوص عادية
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSender ? ColorsManager.primary400 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        child: Text(
          widget.message,
          style: isSender
              ? TextStyles.font14Black400Weight.copyWith(color: Colors.white)
              : TextStyles.font14Black400Weight,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}