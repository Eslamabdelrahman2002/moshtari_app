// lib/features/create_ad/ui/widgets/car_brand_model_picker.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/car/data/model/car_model.dart';
import 'package:mushtary/core/car/data/model/car_type.dart';
import 'package:mushtary/core/car/logic/cubit/car_catalog_cubit.dart';
import 'package:mushtary/core/car/logic/cubit/car_catalog_state.dart';

InputDecoration _ddDecoration(String label) {
  return InputDecoration(
    labelText: label,
    hintText: label,
    filled: true,
    fillColor: const Color(0xFFF7F7F9),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFF14457F)),
    ),
  );
}

class CarBrandModelPicker extends StatelessWidget {
  final String brandLabel;
  final String modelLabel;
  final void Function(CarType brand)? onBrandChanged;
  final void Function(CarModel model)? onModelChanged;

  const CarBrandModelPicker({
    super.key,
    this.brandLabel = 'اختر الماركة',
    this.modelLabel = 'الموديل',
    this.onBrandChanged,
    this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCatalogCubit, CarCatalogState>(
      builder: (context, state) {
        // 🔴 طباعة حالة البيانات
        debugPrint('[Picker DEBUG] Brands Loaded: ${state.brands.length}, Models Loaded: ${state.models.length}, Brand Loading: ${state.brandsLoading}');
        if (state.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Catalog Error: ${state.error!}')));
          });
        }

        CarType? brandValue;
        if (state.selectedBrand != null) {
          try {
            brandValue = state.brands.firstWhere((b) => b.id == state.selectedBrand!.id);
          } catch (_) {
            brandValue = state.selectedBrand;
          }
        }

        CarModel? modelValue;
        if (state.selectedModel != null) {
          try {
            modelValue = state.models.firstWhere((m) => m.id == state.selectedModel!.id);
          } catch (_) {
            modelValue = state.selectedModel;
          }
        }

        final bool brandsLoading = state.brandsLoading;
        final bool modelsLoading = state.modelsLoading;

        return Column(
          children: [
            // Dropdown الماركة
            DropdownButtonFormField<CarType>(
              isExpanded: true,
              decoration: _ddDecoration(brandsLoading ? 'جاري التحميل...' : brandLabel),
              value: brandValue,
              // 💡 الإجراء: تحرير التركيز قبل فتح القائمة (السبب الشائع لعدم ظهورها داخل ScrollView)
              onTap: () {
                debugPrint('[Picker DEBUG] Brand Dropdown Tapped. Unfocusing...');
                FocusScope.of(context).unfocus();
              },
              onChanged: brandsLoading ? null : (val) {
                if (val == null) return;
                // بعد الاختيار، لا نحتاج unfocus هنا، يحدث تلقائيًا
                context.read<CarCatalogCubit>().selectBrand(val);
                onBrandChanged?.call(val);
              },
              items: state.brands
                  .map((b) => DropdownMenuItem<CarType>(value: b, child: Text(b.name)))
                  .toList(),
              menuMaxHeight: 320,
            ),
            SizedBox(height: 16.h),

            // Dropdown الموديل
            DropdownButtonFormField<CarModel>(
              isExpanded: true,
              decoration: _ddDecoration(modelsLoading ? 'جاري تحميل الموديلات...' : modelLabel),
              value: modelValue,
              // 💡 الإجراء: تحرير التركيز قبل فتح القائمة (السبب الشائع لعدم ظهورها داخل ScrollView)
              onTap: (state.selectedBrand == null || modelsLoading) ? null : () {
                debugPrint('[Picker DEBUG] Model Dropdown Tapped. Unfocusing...');
                FocusScope.of(context).unfocus();
              },
              onChanged: (state.selectedBrand == null || modelsLoading) ? null : (val) {
                if (val == null) return;
                // بعد الاختيار، لا نحتاج unfocus هنا
                context.read<CarCatalogCubit>().selectModel(val);
                onModelChanged?.call(val);
              },
              items: state.models
                  .map((m) => DropdownMenuItem<CarModel>(value: m, child: Text(m.displayName)))
                  .toList(),
              menuMaxHeight: 320,
            ),
          ],
        );
      },
    );
  }
}