// lib/features/user_profile/ui/widgets/profile_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../logic/cubit/profile_cubit.dart';

class ProfileImagePicker extends StatefulWidget {
  final ProfileCubit profileCubit;

  const ProfileImagePicker({super.key, required this.profileCubit});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File pickedImageFile = File(pickedFile.path);
      await widget.profileCubit.changeImage(pickedImageFile);
      setState(() {}); // لإعادة بناء الـ UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.profileCubit.user;
    final imageFile = widget.profileCubit.imageFile;

    // 1. تحديد الـ ImageProvider للصور الفعلية فقط.
    final ImageProvider<Object>? profileImage;
    if (imageFile != null) {
      profileImage = FileImage(imageFile);
    } else if (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty) {
      profileImage = CachedNetworkImageProvider(user.profilePictureUrl!);
    } else {
      profileImage = null; // لا يوجد صورة، نعتمد على الـ Child/Color
    }

    // 2. تحديد ويدجت الـ Fallback (MySvg)
    final Widget? fallbackChild = (profileImage == null)
        ? MySvg(image: "profile", height: 100.w, color: ColorsManager.primary400) // حجم ولون مناسبين
        : null;


    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50.w,
              backgroundColor: ColorsManager.lightGrey,
              backgroundImage: profileImage, // قد تكون null الآن
              child: fallbackChild, // 💡 عرض الـ MySvg هنا في حالة الـ Fallback
            ),
            // أيقونة التعديل تكون فوق الصورة/الفولباك
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54, // طبقة داكنة فوق الصورة
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MySvg(image: "edit", height: 30, color: ColorsManager.white),
                  Text(
                    'تعديل الصورة',
                    style: TextStyle(fontSize: 14.sp, color: ColorsManager.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}