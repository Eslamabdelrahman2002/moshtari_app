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

    ImageProvider profileImage;

    if (imageFile != null) {
      profileImage = FileImage(imageFile);
    } else if (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty) {
      profileImage = CachedNetworkImageProvider(user.profilePictureUrl!);
    } else {
      profileImage = const AssetImage('assets/images/prof.png');
    }

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50.w,
              backgroundColor: ColorsManager.lightGrey,
              backgroundImage: profileImage,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MySvg(image: "edit", height: 30, color: ColorsManager.white),
                Text(
                  'تعديل الصورة',
                  style: TextStyle(fontSize: 14.sp, color: ColorsManager.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
