import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_state.dart';
import 'package:mushtary/features/user_profile/ui/widgets/profile_image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    final user = profileCubit.user; // جلب بيانات المستخدم الحالية

    return Scaffold(
      appBar: AppBar(
        title:  Text('تعديل الملف الشخصي',style:TextStyles.font20Black500Weight,),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new,color: ColorsManager.darkGray300,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم تحديث الملف الشخصي بنجاح!'),
                backgroundColor: ColorsManager.success200,
              ),
            );

            Navigator.pop(context, profileCubit.user);
          }

          if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: ColorsManager.redButton,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: profileCubit.formKey,
            child: ListView(
              children: [
                ProfileImagePicker(profileCubit: profileCubit,),
                verticalSpace(8),

                verticalSpace(24),
                SecondaryTextFormField(
                  controller: profileCubit.nameController,
                  label: 'الاسم',
                  hint: 'أدخل اسمك',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  prefixIcon: 'profile',
                  suffexIcon: 'edit',
                ),
                verticalSpace(16),
                SecondaryTextFormField(
                  controller: profileCubit.emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  prefixIcon: 'email',
                  suffexIcon: 'edit',
                ),
                verticalSpace(16),
                SecondaryTextFormField(
                  controller: profileCubit.phoneController,
                  label: 'رقم الجوال',
                  hint: 'أدخل رقم الجوال',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  prefixIcon: 'phone',
                  suffexIcon: 'edit',
                ),
                verticalSpace(16),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileUpdateInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return PrimaryButton(
                      text: 'حفظ التغييرات',
                      onPressed: () async {
                        await profileCubit.updateProfile();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
