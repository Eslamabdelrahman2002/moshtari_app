import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class MessageDataWidget extends StatefulWidget {
  final String message;
  final bool isSended;
  final String? messageType;

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
  bool _isLoading = false;

  bool get isPossibleBase64 {
    if (widget.message.length < 100) return false;
    if (widget.message.startsWith('http')) return false;
    if (widget.message.startsWith('/data/') ||
        widget.message.endsWith('.m4a') ||
        widget.message.endsWith('.aac')) return false;
    final clean = widget.message.trim().replaceAll(RegExp(r'[\s\n\r]'), '');
    return RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(clean);
  }

  bool get _isImage =>
      widget.messageType == 'image' ||
          widget.message.toLowerCase().endsWith('.jpg') ||
          widget.message.toLowerCase().endsWith('.jpeg') ||
          widget.message.toLowerCase().endsWith('.png') ||
          widget.message.toLowerCase().endsWith('.webp') ||
          (widget.message.startsWith('/9j/') &&
              widget.message.length > 100);

  bool get _isVoice {
    final m = widget.message.trim().toLowerCase();
    final explicitType = widget.messageType == 'voice' ||
        widget.messageType == 'audio';
    final hasExt = m.endsWith('.m4a') || m.endsWith('.aac');
    final looksLikeBase64Voice = isPossibleBase64 &&
        widget.message.length > 200 &&
        !widget.message.startsWith('/9j/') &&
        (widget.messageType == 'voice' ||
            widget.messageType == 'audio' ||
            widget.message
                .startsWith('AAAAGGZ0eXBtcDQyAAAAAGlzb21tcDQyAA') ||
            widget.message.startsWith('RIFF'));
    return looksLikeBase64Voice || hasExt || (explicitType && m.isNotEmpty);
  }

  @override
  void initState() {
    super.initState();
    debugPrint(
        '🔍 type=${widget.messageType}, base64=$isPossibleBase64, preview=${_safePreview(widget.message)}');
  }

  String _safePreview(String text, {int maxLength = 50}) {
    if (text.isEmpty) return '[empty]';
    return text.substring(0, text.length < maxLength ? text.length : maxLength);
  }

  Uint8List? _decodeBase64(String data) {
    try {
      if (data.length > 10 * 1024 * 1024) {
        debugPrint('❌ Base64 too large: ${data.length} chars');
        return null;
      }
      final clean = data.trim().replaceAll(RegExp(r'[\s\n\r]'), '');
      if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(clean)) {
        debugPrint('❌ Invalid base64');
        return null;
      }
      final bytes = base64Decode(clean);
      debugPrint('✅ Decoded base64: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      debugPrint('❌ Base64 decode error: $e');
      return null;
    }
  }

  Future<String?> _writeTempVoice(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/voice_$timestamp.m4a';
      final f = File(path);
      await f.writeAsBytes(bytes);
      if (!await f.exists()) return null;
      debugPrint('✅ Temp voice file written: $path');
      return path;
    } catch (e) {
      debugPrint('❌ Write temp voice error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSender = widget.isSended;
    final type = widget.messageType ?? 'text';

    if (_isImage) {
      if (isPossibleBase64) {
        final bytes = _decodeBase64(widget.message);
        if (bytes != null) {
          return _buildImage(bytes, isSender);
        }
      }
      return _buildImageFromUrlOrFile(isSender);
    }

    if (_isVoice) {
      if (isPossibleBase64) {
        final bytes = _decodeBase64(widget.message);
        if (bytes == null) {
          return _errorBubble(isSender, 'فشل فك تشفير الصوت');
        }
        return FutureBuilder<String?>(
          future: _writeTempVoice(bytes)
              .timeout(const Duration(seconds: 5), onTimeout: () => null),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Align(
                alignment:
                isSender ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SpinKitThreeBounce(
                    size: 16.sp,
                    color: ColorsManager.primary400,
                  ),
                ),
              );
            }
            if (snap.hasError || snap.data == null) {
              return _errorBubble(isSender, 'فشل حفظ الصوت');
            }
            return LocalVoicePlayer(path: snap.data!, isSender: isSender);
          },
        );
      }
      return LocalVoicePlayer(
          path: widget.message.trim(), isSender: isSender);
    }

    if (type == 'text' && !isPossibleBase64) {
      return _buildTextBubble(isSender, widget.message);
    }

    if (isPossibleBase64) {
      return _errorBubble(isSender, 'رسالة غير مدعومة (صورة/صوت فاسد)');
    }

    return _buildTextBubble(isSender, widget.message);
  }

  Widget _errorBubble(bool isSender, String msg) => Align(
    alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(msg, style: const TextStyle(color: Colors.red)),
    ),
  );

  // === 🖼️ الصور ===
  Widget _buildImage(Uint8List bytes, bool isSender) => Align(
    alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: GestureDetector(
        onTap: () => _showFullImageDialog(context, Image.memory(bytes)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.memory(bytes,
              width: 200.w, height: 200.w, fit: BoxFit.cover),
        ),
      ),
    ),
  );

  Widget _buildImageFromUrlOrFile(bool isSender) {
    final imgWidget = widget.message.startsWith('http')
        ? Image.network(
      widget.message,
      width: 200.w,
      height: 200.w,
      fit: BoxFit.cover,
      errorBuilder: (_, e, __) => Container(
        width: 200.w,
        height: 200.w,
        color: Colors.grey.shade300,
        child: const Icon(Icons.error, color: Colors.red),
      ),
    )
        : Image.file(
      File(widget.message),
      width: 200.w,
      height: 200.w,
      fit: BoxFit.cover,
      errorBuilder: (_, e, __) => Container(
        width: 200.w,
        height: 200.w,
        color: Colors.grey.shade300,
        child: const Icon(Icons.error, color: Colors.red),
      ),
    );

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: GestureDetector(
          onTap: () => _showFullImageDialog(context, imgWidget),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: imgWidget,
          ),
        ),
      ),
    );
  }

  // === 🗨️ النصوص ===
  Widget _buildTextBubble(bool isSender, String message) => Align(
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
        message,
        style: isSender
            ? TextStyles.font14Black400Weight
            .copyWith(color: Colors.white)
            : TextStyles.font14Black400Weight,
      ),
    ),
  );

  // === 👁️ عرض الصورة كاملة ===
  void _showFullImageDialog(BuildContext context, Widget image) {
    showDialog(
      context: context,
      barrierDismissible: false, // الاغلاق فقط من الزر
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.95),
          body: SafeArea(
            child: Stack(
              children: [
                // الصورة نفسها
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Hero(
                      tag: image.hashCode,
                      child: image,
                    ),
                  ),
                ),

                // زر الإغلاق أعلى اليسار أو اليمين
                Positioned(
                  top: 12,
                  right: Directionality.of(context) == TextDirection.rtl ?12 : null ,
                  left: Directionality.of(context) == TextDirection.rtl ?   null : 12,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// === 🎧 LocalVoicePlayer ===
class LocalVoicePlayer extends StatefulWidget {
  final String path;
  final bool isSender;
  const LocalVoicePlayer({
    super.key,
    required this.path,
    required this.isSender,
  });

  @override
  State<LocalVoicePlayer> createState() => _LocalVoicePlayerState();
}

class _LocalVoicePlayerState extends State<LocalVoicePlayer> {
  final ap.AudioPlayer _player = ap.AudioPlayer();
  bool _playing = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted)
        setState(() {
          _playing = false;
          _position = Duration.zero;
        });
    });
    Future.delayed(const Duration(milliseconds: 100), _loadDuration);
  }

  Future<void> _loadDuration() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final src = widget.path.trim();
      if (src.isEmpty) throw Exception('Empty audio source');
      final source = src.startsWith('http')
          ? ap.UrlSource(src)
          : ap.DeviceFileSource(src);
      await _player.setSource(source);
      final d = await _player.getDuration();
      if (d != null && mounted) setState(() => _duration = d);
    } catch (e) {
      debugPrint('❌ Load duration error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggle() async {
    if (_isLoading) return;
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        if (_duration == Duration.zero) await _loadDuration();
        await _player.resume();
        setState(() => _playing = true);
      }
    } catch (e) {
      debugPrint('❌ play error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل تشغيل الصوت: $e')));
      }
      setState(() => _playing = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        width: 230.w,
        decoration: BoxDecoration(
          color: widget.isSender ? ColorsManager.primary400 : Colors.white,
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
            GestureDetector(
              onTap: _toggle,
              child: _isLoading
                  ? SpinKitThreeBounce(
                size: 16.sp,
                color: widget.isSender
                    ? Colors.white
                    : ColorsManager.primary400,
              )
                  : Icon(
                _playing ? Icons.pause_circle : Icons.play_circle,
                color: widget.isSender
                    ? Colors.white
                    : ColorsManager.primary400,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0,
                    max: _duration.inSeconds == 0
                        ? 1
                        : _duration.inSeconds.toDouble(),
                    onChanged: (v) async {
                      await _player.seek(Duration(seconds: v.toInt()));
                    },
                    activeColor: widget.isSender
                        ? Colors.white
                        : ColorsManager.primary400,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  Text(
                    '${_format(_position)} / ${_format(_duration)}',
                    style: TextStyle(
                      color: widget.isSender ? Colors.white70 : Colors.black54,
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

  String _format(Duration d) {
    if (d == Duration.zero) return '00:00';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}