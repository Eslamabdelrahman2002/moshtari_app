import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart'; // ✅ لـ verticalSpace
import 'package:mushtary/features/create_ad/ui/widgets/steps_header_rtl.dart'; // ✅ للـ Header

import '../../../../core/theme/text_styles.dart';
import '../cubit/real_estate_requests_cubit.dart';
import '../cubit/real_estate_requests_state.dart';
import 'real_estate_request_details_screen.dart'; // الخطوة 1
import 'real_estate_request_advanced_details_screen.dart'; // الخطوة 2
import 'real_estate_request_view_iformations_screen.dart'; // الخطوة 3

class RealEstateCreateRequestFlow extends StatefulWidget {
  const RealEstateCreateRequestFlow({super.key});

  @override
  State<RealEstateCreateRequestFlow> createState() => _RealEstateCreateRequestFlowState();
}

class _RealEstateCreateRequestFlowState extends State<RealEstateCreateRequestFlow> {
  final _controller = PageController();
  int currentPage = 0; // ✅ إضافة لتتبع الصفحة الحالية

  void _next() {
    print('>>> [Flow] Next called - Current page: ${_controller.page}'); // Debug
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // ✅ تسميات الخطوات (مثل CreateAdScreen)
  static const _stepLabels = ['حدد التصنيف', 'تفاصيل متقدمة', 'معلومات العرض'];

  // ✅ حساب الـ index الحالي للـ Header (مثل CreateAdScreen)
  int get _headerCurrentIndex {
    final i = currentPage;
    if (i <= 0) return 0;
    if (i == 1) return 1;
    return 2;
  }

  // ✅ التنقل إلى خطوة معيّنة عند الضغط على Header (مثل CreateAdScreen)
  void _goToHeaderStep(int step) {
    final target = step; // step 0..2 -> page 0..2
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('>>> [Flow] Build started - Cubit available: ${context.read<RealEstateRequestsCubit>() != null}'); // Debug
    return BlocListener<RealEstateRequestsCubit, RealEstateRequestsState>(
      listener: (context, state) {
        print('>>> [Flow] State changed: success=${state.success}, error=${state.error}'); // Debug
        if (state.error != null && state.error!.isNotEmpty && !state.submitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال طلب العقار بنجاح ✅')),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300),
          ),
          title: Text(
            'إنشاء طلب عقار',
            style: TextStyles.font18Black500Weight,
          ),
        ),
        body: SafeArea( // ✅ إضافة SafeArea للتوافق
          child: Column(
            children: [
              // ✅ إضافة StepsHeaderRtl (مثل CreateAdScreen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StepsHeaderRtl(
                  labels: _stepLabels,
                  current: _headerCurrentIndex,
                  onTap: _goToHeaderStep,
                ),
              ),
              verticalSpace(8), // ✅ spacing مثل CreateAdScreen

              // ✅ الـ PageView (مع onPageChanged لتحديث currentPage)
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => currentPage = index), // ✅ تحديث currentPage
                  children: [
                    RealEstateRequestDetailsScreen(onNext: _next), // الخطوة 1
                    RealEstateRequestAdvancedDetailsScreen(onNext: _next), // الخطوة 2
                    const RealEstateRequestViewIformationsScreen(), // الخطوة 3
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}