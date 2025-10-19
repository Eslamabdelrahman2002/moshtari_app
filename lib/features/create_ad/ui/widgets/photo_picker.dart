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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result == null) {
      return [];
    }

    List<File> files = [];

    if (!Platform.isIOS) {
      for (var file in result.files) {
        if (file.path != null &&
            !_selectedFiles.contains(p.basename(file.path!))) {
          File fileObj = File(file.path!);
          if (await fileObj.length() <= maxSizeInBytes) {
            _selectedFiles.add(p.basename(file.path!));
            files.add(fileObj);
          } else {
            if (context.mounted) {
              context.showErrorSnackbar(
                'حجم الملف يجب ان يكون اقل من 2 ميغا بايت',
              );
            }
          }
        } else {
          if (context.mounted) {
            context.showErrorSnackbar('الملف موجود مسبقاً');
          }
        }
      }
    }

    if (Platform.isIOS) {
      for (var file in result.files) {
        if (file.path != null &&
            !_selectedFiles.contains(
              p.basename(file.path!).extractFileNamePartFromIOS(),
            )) {
          File fileObj = File(file.path!);
          if (await fileObj.length() <= maxSizeInBytes) {
            _selectedFiles.add(
              p.basename(file.path!).extractFileNamePartFromIOS(),
            );
            files.add(fileObj);
          } else {
            if (context.mounted) {
              context.showErrorSnackbar(
                'حجم الملف يجب ان يكون اقل من 2 ميغا بايت',
              );
            }
          }
        } else {
          if (context.mounted) {
            context.showErrorSnackbar('الملف موجود مسبقاً');
          }
        }
      }
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
