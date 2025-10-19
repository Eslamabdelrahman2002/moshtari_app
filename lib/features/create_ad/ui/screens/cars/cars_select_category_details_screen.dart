import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';

import '../../../../../core/car/data/model/car_model.dart';
import '../../../../../core/car/data/model/car_type.dart';
import '../../../../../core/car/logic/cubit/car_catalog_cubit.dart';
import '../../../../../core/car/logic/cubit/car_catalog_state.dart';
import '../../../../../core/widgets/primary/car_brand_model_picker.dart';
import '../../../data/car/utils/car_mappers.dart';
import '../../widgets/next_button_bar.dart';
import 'logic/cubit/car_ads_cubit.dart';
import 'logic/cubit/car_ads_state.dart';


class CarsSelectCategoryDetailsScreen extends StatefulWidget {
  final VoidCallback? onPressed;
  const CarsSelectCategoryDetailsScreen({super.key, this.onPressed});

  @override
  State<CarsSelectCategoryDetailsScreen> createState() => _CarsSelectCategoryDetailsScreenState();
}

class _CarsSelectCategoryDetailsScreenState extends State<CarsSelectCategoryDetailsScreen> {
  late final TextEditingController _yearCtrl;

  @override
  void initState() {
    super.initState();
    final st = context.read<CarAdsCubit>().state;
    _yearCtrl = TextEditingController(text: st.year?.toString() ?? '');
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  // 🟢 ويدجت لعرض الخطأ وإعادة المحاولة
  Widget _buildErrorState(BuildContext context, CarCatalogState state) {
    final cubit = context.read<CarCatalogCubit>();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error ?? 'حدث خطأ غير معروف.',
              style: TextStyle(color: Colors.red, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            verticalSpace(16),
            SizedBox(
              height: 40.h,
              child: ElevatedButton(
                onPressed: () => cubit.loadBrands(autoSelectFirst: false),
                child: const Text('إعادة المحاولة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carAdsCubit = context.read<CarAdsCubit>();
    final carState = carAdsCubit.state;

    return MultiBlocProvider(
      providers: [
        BlocProvider<CarCatalogCubit>(
          create: (_) => getIt<CarCatalogCubit>()
            ..loadBrands(
              preselectBrandId: carState.brandId,
              preselectModelId: carState.modelId,
              autoSelectFirst: false, // 🟢 لا يتم الاختيار التلقائي لتجنب تعيين قيم غير مرغوبة
            ),
        ),
      ],
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: MultiBlocListener(
            listeners: [
              // 🟢 ربط اختيارات الكتالوج بـ CarAdsCubit
              BlocListener<CarCatalogCubit, CarCatalogState>(
                listenWhen: (p, c) => p.selectedBrand != c.selectedBrand || p.selectedModel != c.selectedModel,
                listener: (context, cat) {
                  final carAds = context.read<CarAdsCubit>();
                  // 🟢 ربط الماركة
                  if (cat.selectedBrand != null) carAds.setBrandId(cat.selectedBrand!.id);
                  else carAds.setBrandId(null);

                  // 🟢 ربط الموديل
                  if (cat.selectedModel != null) carAds.setModelId(cat.selectedModel!.id);
                  else carAds.setModelId(null);
                },
              ),
            ],
            child: BlocBuilder<CarAdsCubit, CarAdsState>(
              builder: (context, state) {
                return BlocBuilder<CarCatalogCubit, CarCatalogState>( // 🟢 BlocBuilder إضافي لمراقبة حالة جلب الكتالوج
                  builder: (context, catalogState) {
                    // 1. حالة التحميل
                    if (catalogState.brandsLoading && catalogState.brands.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // 2. حالة الخطأ
                    if (catalogState.error != null && catalogState.brands.isEmpty) {
                      return _buildErrorState(context, catalogState);
                    }

                    // 3. حالة النجاح (عرض المحتوى)
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          verticalSpace(16),

                          // الحالة
                          DetailSelector(
                            title: 'الحالة',
                            widget: Row(
                              children: [
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'جديد',
                                    isSelected: state.condition == 'new',
                                    onTap: () => carAdsCubit.setCondition(CarMappers.condition('جديد')),
                                  ),
                                ),
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'مستعمل',
                                    isSelected: state.condition == 'used',
                                    onTap: () => carAdsCubit.setCondition(CarMappers.condition('مستعمل')),
                                  ),
                                ),
                                Expanded(
                                  child: CustomizedChip(
                                    title: 'تالف',
                                    isSelected: state.condition == 'damaged',
                                    onTap: () => carAdsCubit.setCondition(CarMappers.condition('تالف')),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          verticalSpace(16),

                          // 🟢 استخدام الـ Picker الموحد للماركة والموديل
                          CarBrandModelPicker(
                            onBrandChanged: (brand) { /* يتم التعامل معه في BlocListener */ },
                            onModelChanged: (model) { /* يتم التعامل معه في BlocListener */ },
                          ),

                          verticalSpace(16),

                          // السنة
                          SecondaryTextFormField(
                            label: 'اختر السنة',
                            hint: 'مثال: 2024',
                            maxheight: 56.h,
                            minHeight: 56.h,
                            controller: _yearCtrl,
                            onChanged: (v) => carAdsCubit.setYear(int.tryParse(v.trim())),
                            isNumber: true,
                          ),

                          verticalSpace(16),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16),
          child: NextButtonBar(onPressed: widget.onPressed),
        ),
      ),
    );
  }
}