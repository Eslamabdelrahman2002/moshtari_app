import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mushtary/core/widgets/show_snackbar.dart';
import 'package:path/path.dart' as p;

class PhotoPicker {
  static const int maxSizeInBytes = 2 * 1024 * 1024; // 2 MB
  static final List<String> _selectedFiles = [];
  final BuildContext context;

  PhotoPicker(this.context);

  /// Picks photos and videos from the gallery with the given constraints.
  Future<List<File>> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowCompression: false, // بدون ضغط
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
      withData: false,
    );

    if (result == null) return [];

    final files = <File>[];

    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;

      // مفتاح التمييز لمنع التكرار (مراعاة اختلاف iOS)
      final key = Platform.isIOS
          ? p.basename(path).extractFileNamePartFromIOS()
          : p.basename(path);

      if (_selectedFiles.contains(key)) {
        if (context.mounted) {
          context.showErrorSnackbar('الملف موجود مسبقاً');
        }
        continue;
      }

      _selectedFiles.add(key);
      files.add(File(path));
    }

    return files;
  }


  /// Clears the list of selected files.
  static void clearSelectedFiles() {
    _selectedFiles.clear();
  }
}

extension FilenameExtension on String {
  String extractFileNamePartFromIOS() {
    return split('-').first;
  }
}
