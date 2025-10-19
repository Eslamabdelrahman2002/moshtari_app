import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import '../logic/cubit/commission_cubit.dart';
import '../logic/cubit/commission_state.dart';

class CommissionCalculatorScreen extends StatefulWidget {
  const CommissionCalculatorScreen({super.key});

  @override
  State<CommissionCalculatorScreen> createState() => _CommissionCalculatorScreenState();
}

class _CommissionCalculatorScreenState extends State<CommissionCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.decimalPattern('ar');

    return BlocProvider<CommissionCubit>(
      create: (_) => getIt<CommissionCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title:  Text('حاسبة العمولة',style: TextStyles.font20Black500Weight,),
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios,color:ColorsManager.darkGray300,),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: BlocBuilder<CommissionCubit, CommissionState>(
            builder: (context, state) {
              final cubit = context.read<CommissionCubit>();

              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('تعذّر جلب النسب', style: TextStyles.font14Black500Weight),
                      verticalSpace(8),
                      Text(state.error!, style: TextStyles.font12DarkGray400Weight),
                      verticalSpace(12),
                      PrimaryButton(text: 'إعادة المحاولة', onPressed: () => cubit.load()),
                    ],
                  ),
                );
              }

              // قائمة التصنيفات: "الكل" + من API
              final chips = <String>['الكل', ...state.items.map((e) => cubit.labelFor(e.category))];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تصنيف السلعة المباعة', style: TextStyles.font14Black500Weight),
                  verticalSpace(16),
                  SizedBox(
                    height: 35.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chips.length,
                      itemBuilder: (context, index) {
                        final selected = state.selectedIndex == index;
                        return ChoiceChip(
                          label: Text(chips[index]),
                          selected: selected,
                          onSelected: (_) => cubit.selectCategory(index),
                          backgroundColor: ColorsManager.dark50,
                          selectedColor: ColorsManager.primary50,
                          labelStyle: TextStyle(
                            color: selected ? ColorsManager.primaryColor : ColorsManager.darkGray,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            side: BorderSide(
                              color: selected ? ColorsManager.primaryColor : Colors.transparent,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => horizontalSpace(8),
                    ),
                  ),
                  verticalSpace(24),

                  // بطاقة "قيمة السعي X%"
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: ColorsManager.lightYellow,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        const MySvg(image: 'info-circle-yellow'),
                        horizontalSpace(8),
                        Text(
                          'قيمة السعي ${cubit.selectedPercentage.toStringAsFixed(2)}%',
                          style: TextStyles.font14secondary600yellow400Weight,
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(16),

                  SecondaryTextFormField(
                    controller: _priceController,
                    hint: 'اجمالي قيمة البيع',
                    keyboardType: TextInputType.number,
                    isNumber: true,
                    maxheight: 56.h,
                    minHeight: 56.h,
                  ),
                  verticalSpace(24),

                  // نتيجة الحساب
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: ColorsManager.primary50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الرسوم المستحقة', style: TextStyles.font12Primary300400Weight),
                        verticalSpace(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${nf.format(state.result)} رس',
                              style: TextStyles.font24Primary500Weight,
                            ),
                            Text('دفع المبلغ', style: TextStyles.font14PrimaryColor400Weight),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: 'احسب العمولة',
                    onPressed: () {
                      final price = double.tryParse(_priceController.text.trim().replaceAll(',', '')) ?? 0.0;
                      cubit.calculate(price);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}