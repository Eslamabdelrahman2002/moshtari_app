// lib/features/create_ad/ui/screens/car/create_car_ad_flow.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/primary/my_svg.dart';
import '../../widgets/steps_header_rtl.dart';
import 'cars_advanced_details_screen.dart';
import 'cars_display_information_screen.dart';
import 'cars_select_category_details_screen.dart';
import 'logic/cubit/car_ads_cubit.dart';
import 'logic/cubit/car_ads_state.dart';

class CreateCarAdFlow extends StatefulWidget {
  final int? exhibitionId;
  final bool isEditing; // ✅ لتحديد وضع التعديل
  const CreateCarAdFlow({super.key, this.exhibitionId, this.isEditing = false});

  @override
  State<CreateCarAdFlow> createState() => _CreateCarAdFlowState();
}

class _CreateCarAdFlowState extends State<CreateCarAdFlow> {
  final _controller = PageController();
  int _step = 0;

  final List<String> _labels = const [
    'تفاصيل السيارة',
    'تفاصيل متقدمة',
    'عرض الإعلان',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CarAdsCubit>();

      if (!cubit.state.isEditing) {
        cubit.reset();
      }

      if (widget.exhibitionId != null) {
        cubit.setExhibitionId(widget.exhibitionId);
      }
    });
  }

  void _next() {
    if (_step < _labels.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onStepTap(int index) {
    if (index <= _step) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarAdsCubit, CarAdsState>(
      listenWhen: (prev, curr) =>
      (prev.success != curr.success && curr.success == true) ||
          (prev.error != curr.error && curr.error != null),
      listener: (context, state) {
        if (state.success) {
          final msg = state.isEditing
              ? 'تم تحديث إعلان السيارة بنجاح ✅'
              : 'تم نشر الإعلان بنجاح ✅';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        appBar: widget.isEditing
            ? AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تعديل إعلان',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: MySvg(image: 'arrow-right', color: ColorsManager.darkGray300),
            tooltip: 'رجوع',
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
                  current: _step,
                  onTap: _onStepTap,
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _step = i),
                  children: [
                    CarsSelectCategoryDetailsScreen(onPressed: _next),
                    CarsAdvancedDetailsScreen(onPressed: _next),
                    CarsDisplayInformationScreen(
                      popOnSuccess: false, // مهم: الـ pop في هذا الـ BlocListener
                      onPressed: () {
                        context.read<CarAdsCubit>().submit();
                      },
                    ),
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