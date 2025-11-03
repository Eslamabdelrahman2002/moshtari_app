import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

class MessageInputBox extends StatefulWidget {
  final int receiverId;
  // onSend يستقبل content (نص أو مسار ملف) و messageType
  final void Function(String content, String messageType)? onSend;

  const MessageInputBox({super.key, required this.receiverId, this.onSend});

  @override
  State<MessageInputBox> createState() => _MessageInputBoxState();
}

class _MessageInputBoxState extends State<MessageInputBox> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 🔹 الكلاس الجديد في record v6.x
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  String? _currentFilePath;

  @override
  void dispose() {
    _recorder.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text, 'text');
    _msgCtrl.clear();
  }

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      // 💡 إرسال مسار الصورة كـ content ونوع الرسالة 'image'
      widget.onSend?.call(img.path, 'image');
    }
  }

  /// ✅ يبدأ التسجيل
  Future<void> _startRecording() async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى السماح بالوصول للمايكروفون')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: filePath,
    );

    setState(() {
      _isRecording = true;
      _currentFilePath = filePath;
    });

    debugPrint('[MIC] Recording started >> $_currentFilePath');
  }

  /// ✅ يوقف التسجيل
  Future<void> _stopRecording() async {
    final filePath = await _recorder.stop();
    setState(() => _isRecording = false);

    if (filePath == null) {
      debugPrint('[MIC] stopRecording returned null');
      return;
    }

    final file = File(filePath);
    if (await file.exists() && (await file.length()) > 0) {
      // 💡 إرسال مسار ملف الصوت كـ content ونوع الرسالة 'voice'
      widget.onSend?.call(filePath, 'voice');
      debugPrint('[MIC] Saved voice file: $filePath');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الصوت، حاول مرة أخرى')),
      );
      debugPrint('[MIC] empty file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        children: [

          GestureDetector(
            onTap: () async {
              if (_isRecording) {
                await _stopRecording();
              } else {
                await _startRecording();
              }
            },
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor:
              _isRecording ? Colors.redAccent : ColorsManager.primaryColor,
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic_none,
                color: Colors.white,
              ),
            ),
          ),
          horizontalSpace(8),
          Expanded(
            child: TextFormField(
              controller: _msgCtrl,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => _sendText(),
              decoration: InputDecoration(
                hintText: 'أكتب رسالتك هنا...',
                hintStyle: TextStyles.font12Dark500400Weight,
                fillColor: const Color(0xffFAFAFA),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
          ),
          horizontalSpace(8),
          InkWell(
            onTap: _pickImage,
            child: Icon(Icons.add, size: 28.sp, color: ColorsManager.darkGray300),
          ),
        ],
      ),
    );
  }
}
