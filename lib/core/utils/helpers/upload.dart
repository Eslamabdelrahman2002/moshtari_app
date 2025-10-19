// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:mushtary/core/api/api_constants.dart';
// import 'package:mushtary/core/dependency_injection/injection_container.dart';
// import 'package:path/path.dart';
//
// Future<void> uploadFiles({
//   required File profilePicture,
//   required List<File> mediaFiles,
//   required List<File> technicalCheckingFiles,
//   File? banner,
//   File? carFrontPhoto,
//   File? carRearPhoto,
//   File? carLicensePhoto,
//   File? carDocsPhoto,
//   String? saveTo,
// }) async {
//   final dio = getIt<Dio>();
//
//   FormData formData = FormData();
//
//   // Required field
//   formData.files.add(
//     MapEntry(
//       'profilePicture',
//       await MultipartFile.fromFile(
//         profilePicture.path,
//         filename: basename(profilePicture.path),
//       ),
//     ),
//   );
//
//   // Optional multiple files
//   for (var file in mediaFiles) {
//     formData.files.add(
//       MapEntry(
//         'media',
//         await MultipartFile.fromFile(file.path, filename: basename(file.path)),
//       ),
//     );
//   }
//
//   for (var file in technicalCheckingFiles) {
//     formData.files.add(
//       MapEntry(
//         'technicalCheckingFiles',
//         await MultipartFile.fromFile(file.path, filename: basename(file.path)),
//       ),
//     );
//   }
//
//   if (banner != null) {
//     formData.files.add(
//       MapEntry(
//         'banner',
//         await MultipartFile.fromFile(
//           banner.path,
//           filename: basename(banner.path),
//         ),
//       ),
//     );
//   }
//
//   if (carFrontPhoto != null) {
//     formData.files.add(
//       MapEntry(
//         'carFrontPhoto',
//         await MultipartFile.fromFile(
//           carFrontPhoto.path,
//           filename: basename(carFrontPhoto.path),
//         ),
//       ),
//     );
//   }
//
//   if (carRearPhoto != null) {
//     formData.files.add(
//       MapEntry(
//         'carRearPhoto',
//         await MultipartFile.fromFile(
//           carRearPhoto.path,
//           filename: basename(carRearPhoto.path),
//         ),
//       ),
//     );
//   }
//
//   if (carLicensePhoto != null) {
//     formData.files.add(
//       MapEntry(
//         'carLicensePhoto',
//         await MultipartFile.fromFile(
//           carLicensePhoto.path,
//           filename: basename(carLicensePhoto.path),
//         ),
//       ),
//     );
//   }
//
//   if (carDocsPhoto != null) {
//     formData.files.add(
//       MapEntry(
//         'carDocsPhoto',
//         await MultipartFile.fromFile(
//           carDocsPhoto.path,
//           filename: basename(carDocsPhoto.path),
//         ),
//       ),
//     );
//   }
//
//   if (saveTo != null) {
//     formData.fields.add(MapEntry('saveTo', saveTo));
//   }
//
//   try {
//     final response = await dio.post(
//       ApiConstants.baseUrl + ApiConstants.upload,
//       data: formData,
//       options: Options(contentType: 'multipart/form-data'),
//     );
//   } catch (e) {}
// }
