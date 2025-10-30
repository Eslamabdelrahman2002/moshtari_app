import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/primary/my_svg.dart';
import 'cars_advanced_details_screen.dart';
import 'cars_display_information_screen.dart';
import 'cars_select_category_details_screen.dart';
import 'logic/cubit/car_ads_cubit.dart';
import 'logic/cubit/car_ads_state.dart';

class CreateCarAdFlow extends StatefulWidget {
  const CreateCarAdFlow({super.key});

  @override
  State<CreateCarAdFlow> createState() => _CreateCarAdFlowState();
}

class _CreateCarAdFlowState extends State<CreateCarAdFlow> {
  final _controller = PageController();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    // صَفّر حالة الإنشاء عند الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CarAdsCubit>().reset(); // أضف reset في CarAdsCubit
    });
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarAdsCubit, CarAdsState>(
      listenWhen: (prev, curr) =>
      (prev.success != curr.success && curr.success == true) ||
          (prev.error != curr.error && curr.error != null),
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('تم نشر الإعلان بنجاح ✅')));
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'إنشاء إعلان',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: MySvg(image: 'arrow-right', color: ColorsManager.darkGray300),
            tooltip: 'رجوع',
          ),
        ),
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _step = i),
          children: [
            CarsSelectCategoryDetailsScreen(onPressed: _next),
            CarsAdvancedDetailsScreen(onPressed: _next),
            CarsDisplayInformationScreen(onPressed: () {
              context.read<CarAdsCubit>().submit();
            }),
          ],
        ),
      ),
    );
  }
}