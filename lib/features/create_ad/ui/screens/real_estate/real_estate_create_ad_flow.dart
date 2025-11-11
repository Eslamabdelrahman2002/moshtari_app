import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_select_category_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_advanced_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_view_iformations_screen.dart';
import '../../widgets/steps_header_rtl.dart';
import 'logic/cubit/real_estate_ads_cubit.dart';
import 'logic/cubit/real_estate_ads_state.dart';


class RealEstateCreateAdFlow extends StatefulWidget {
  final int? exhibitionId;
  final bool isEditing;
  const RealEstateCreateAdFlow({super.key, this.exhibitionId, this.isEditing = false});

  @override
  State<RealEstateCreateAdFlow> createState() => _RealEstateCreateAdFlowState();
}

class _RealEstateCreateAdFlowState extends State<RealEstateCreateAdFlow> {
  final _controller = PageController();
  int _currentStep = 0;

  final List<String> _labels = const [
    'نوع العقار',
    'تفاصيل متقدمة',
    'معلومات العرض',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.exhibitionId != null) {
        context.read<RealEstateAdsCubit>().setExhibitionId(widget.exhibitionId);
      }
    });
  }

  void _next() {
    if (_currentStep < _labels.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int index) {
    // السماح بالرجوع فقط
    if (index <= _currentStep) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RealEstateAdsCubit, RealEstateAdsState>(
      listener: (context, state) {
        if (state.success) {
          final msg = state.isEditing ? 'تم تحديث إعلان العقار بنجاح ✅' : 'تم نشر إعلان العقار بنجاح ✅';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        appBar: widget.isEditing
            ? AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300),
          ),
          title: Text(
            'تعديل إعلان عقار',
            style: TextStyles.font18Black400Weight,
          ),
        )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.isEditing) ...[
                const SizedBox(height: 12),
                StepsHeaderRtl(
                  labels: _labels,
                  current: _currentStep,
                  onTap: _goToStep,
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    RealEstateSelectCategoryDetailsScreen(onNext: _next),
                    RealEstateAdvancedDetailsScreen(onNext: _next),
                    const RealEstateViewIformationsScreen(),
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