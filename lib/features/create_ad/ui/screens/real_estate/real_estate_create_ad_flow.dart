// lib/features/real_estate_ads/ui/real_estate_create_ad_flow.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_select_category_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_advanced_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_view_iformations_screen.dart';
import 'logic/cubit/real_estate_ads_cubit.dart';
import 'logic/cubit/real_estate_ads_state.dart';

class RealEstateCreateAdFlow extends StatefulWidget {
  const RealEstateCreateAdFlow({super.key});

  @override
  State<RealEstateCreateAdFlow> createState() => _RealEstateCreateAdFlowState();
}

class _RealEstateCreateAdFlowState extends State<RealEstateCreateAdFlow> {
  final _controller = PageController();

  void _next() => _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RealEstateAdsCubit, RealEstateAdsState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر إعلان العقار بنجاح ✅')));
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء إعلان عقار')),
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            RealEstateSelectCategoryDetailsScreen(onNext: _next),
            RealEstateAdvancedDetailsScreen(onNext: _next),
            const RealEstateViewIformationsScreen(),
          ],
        ),
      ),
    );
  }
}