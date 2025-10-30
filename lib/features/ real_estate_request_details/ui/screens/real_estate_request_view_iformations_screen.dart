import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

import '../cubit/real_estate_requests_cubit.dart';
import '../cubit/real_estate_requests_state.dart';

class RealEstateRequestViewIformationsScreen extends StatefulWidget {
  const RealEstateRequestViewIformationsScreen({super.key});

  @override
  State<RealEstateRequestViewIformationsScreen> createState() =>
      _RealEstateRequestViewIformationsScreenState();
}

class _RealEstateRequestViewIformationsScreenState
    extends State<RealEstateRequestViewIformationsScreen> {
  // الحالات الافتراضية (مثل الـ Create)
  bool isCommentsAvailable = true;
  bool isAllowedToAdvertisingMarketing = true;
  bool isAllowNegotiation = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ نقل هنا بدلاً من initState - يضمن الـ Cubit جاهز
    final cubit = context.read<RealEstateRequestsCubit>();
    cubit.setAllowComments(isCommentsAvailable);
    cubit.setAllowMarketingOffers(isAllowedToAdvertisingMarketing);
    cubit.setAllowNegotiation(isAllowNegotiation);
    print('>>> [View Info] Initial settings applied'); // Debug
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RealEstateRequestsCubit, RealEstateRequestsState>(
      listener: (context, state) {
        print('>>> [View Info] State: submitting=${state.submitting}, success=${state.success}, error=${state.error}'); // Debug
        if (state.error != null && state.error!.isNotEmpty && !state.submitting) {
          // ✅ تأكيد إظهار SnackBar للـ Error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (state.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showSuccessDialog(context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<RealEstateRequestsCubit>();
        return SizedBox(
          height: 535.h,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 25.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // رقم التواصل (مثل Title في الـ Create)
                  SecondaryTextFormField(
                    label: 'رقم التواصل',
                    hint: '+966...',
                    isNumber: true,
                    maxheight: 56.h,
                    minHeight: 56.h,
                    onChanged: (v) {
                      print('>>> [View Info] Phone changed: $v'); // Debug
                      cubit.setContactPhone(v);
                    },
                  ),
                  verticalSpace(16),

                  // ملاحظات (مثل Description في الـ Create)
                  SecondaryTextFormField(
                    label: 'ملاحظات إضافية',
                    hint: 'مثال: يفضل قريب من الخدمات',
                    maxheight: 96.w,
                    minHeight: 96.w,
                    maxLines: 4,
                    onChanged: (v) {
                      print('>>> [View Info] Notes changed: $v'); // Debug
                      cubit.setNotes(v);
                    },
                  ),
                  verticalSpace(16),

                  // السويتشات (مثل الـ Create بالضبط)
                  _buildSwitchRow(
                    label: 'السماح بالتعليق على الطلب',
                    value: isCommentsAvailable,
                    onChanged: (value) {
                      setState(() => isCommentsAvailable = value);
                      cubit.setAllowComments(value);
                      print('>>> [View Info] Comments: $value'); // Debug
                    },
                  ),
                  verticalSpace(4),
                  _buildSwitchRow(
                    label: 'السماح بتسويق الطلب',
                    value: isAllowedToAdvertisingMarketing,
                    onChanged: (value) {
                      setState(() => isAllowedToAdvertisingMarketing = value);
                      cubit.setAllowMarketingOffers(value);
                      print('>>> [View Info] Marketing: $value'); // Debug
                    },
                  ),
                  verticalSpace(4),
                  _buildSwitchRow(
                    label: 'قابل للتفاوض في السعر',
                    value: isAllowNegotiation,
                    onChanged: (value) {
                      setState(() => isAllowNegotiation = value);
                      cubit.setAllowNegotiation(value);
                      print('>>> [View Info] Negotiation: $value'); // Debug
                    },
                  ),
                  verticalSpace(16),

                  // زر الإرسال (مثل Publish في الـ Create)
                  NextButtonBar(
                    title: state.submitting ? 'جاري إرسال الطلب...' : 'إرسال الطلب',
                    onPressed: state.submitting
                        ? null
                        : () {
                      print('>>> [View Info] Submit pressed!'); // Debug
                      cubit.submit();
                    },
                  ),
                  verticalSpace(16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            inactiveTrackColor: ColorsManager.lightGrey,
            thumbColor: ColorsManager.secondary500,
            activeTrackColor: ColorsManager.secondary200,
            value: value,
            onChanged: onChanged,
          ),
        ),
        Expanded(
          child: Text(label, style: TextStyles.font14Dark500Weight, textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: Text(
            'تم إرسال الطلب بنجاح',
            style: TextStyles.font18Black500Weight.copyWith(color: ColorsManager.primary400),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'سيتم إرسال إشعار لك فور توفر عروض مناسبة لطلبك.',
            style: TextStyles.font14Dark500Weight.copyWith(color: Colors.black87),
            textAlign: TextAlign.right,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('العودة للرئيسية', style: TextStyles.font14Primary500Weight),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }
}