import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/sliver_app_bar_delegate.dart';
import 'package:mushtary/features/home/ui/widgets/home_banners.dart';
import 'package:mushtary/features/services/logic/cubit/laborer_type_state.dart';
import 'package:mushtary/features/services/logic/cubit/laborer_types_cubit.dart';
import 'package:mushtary/features/services/logic/cubit/service_providers_cubit.dart';
import 'package:mushtary/features/services/logic/cubit/service_providers_state.dart';
import 'package:mushtary/features/services/ui/widgets/service_app_bar.dart';
import '../../../../core/enums/mockpanners.dart';
import '../../../home/ui/widgets/home_screen_app_bar.dart';
import '../widgets/categories_list_view.dart';
import '../widgets/service_banners.dart';
import '../widgets/worker_list_view_item.dart';

// استورد الموديل المستخدم في CategoriesListView
import 'package:mushtary/features/real_estate/data/model/mock_data.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/services/data/model/service_provider_model.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class WorkerScreen extends StatefulWidget {
  const WorkerScreen({super.key});

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  int? _selectedLabourId;

  String _iconForLaborer(String nameEn) {
    final key = nameEn.toLowerCase();
    switch (key) {
      case 'tiler':
        return 'worker';
      default:
        return 'worker';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LaborerTypesCubit>(
          create: (_) => getIt<LaborerTypesCubit>()..fetch(),
        ),
        BlocProvider<ServiceProvidersCubit>(
          create: (_) => getIt<ServiceProvidersCubit>(),
        ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: SliverAppBarDelegate(
              maxHeight: 70.h,
              minHeight: 70.h,
              child: ServiceAppBar()
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                verticalSpace(16.0),
                HomeBanners(),
                verticalSpace(16.0),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: BlocConsumer<LaborerTypesCubit, LaborerTypesState>(
              listenWhen: (p, c) => p.loading != c.loading || p.types != c.types,
              listener: (context, state) {
                if (!state.loading && state.types.isNotEmpty && _selectedLabourId == null) {
                  setState(() {
                    _selectedLabourId = state.types.first.id;
                  });
                  context.read<ServiceProvidersCubit>().fetch(labourId: _selectedLabourId!);
                }
              },
              builder: (context, state) {
                if (state.loading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      height: 45.h,
                      child: Row(
                        children: List.generate(
                          4,
                              (_) => Container(
                            width: 90.w,
                            height: 36.h,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (state.error != null) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('تعذر تحميل الفئات: ${state.error}', style: const TextStyle(color: Colors.red)),
                  );
                }

                if (state.types.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const Text('لا توجد فئات متاحة حاليًا', style: TextStyle(color: Colors.grey)),
                  );
                }

                final categories = state.types
                    .map((t) => CategoryModel(id: t.id, name: t.nameAr, icon: _iconForLaborer(t.nameEn)))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoriesListView(
                      categories: categories,
                      onSelect: (c) {
                        if (_selectedLabourId != c.id) {
                          setState(() {
                            _selectedLabourId = c.id;
                          });
                          context.read<ServiceProvidersCubit>().fetch(labourId: c.id);
                        }
                      },
                    ),
                    verticalSpace(16.0),
                  ],
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: BlocBuilder<ServiceProvidersCubit, ServiceProvidersState>(
              builder: (context, state) {
                if (state.loading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: List.generate(
                        4,
                            (_) => Container(
                          height: 0.33.sw * 1.075,
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (state.error != null) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('تعذر تحميل العمال: ${state.error}', style: const TextStyle(color: Colors.red)),
                  );
                }

                final items = state.items;
                if (items.isEmpty) {
                  debugPrint('UI: No providers for selected labourId: $_selectedLabourId');
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const Text('لا يوجد عمال لهذه الفئة حالياً', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final sp = items[index];
                    return WorkerListViewItem(
                      name: sp.fullName,
                      imageUrl: sp.personalImage,
                      rating: (sp.averageRating ?? 0).toStringAsFixed(1),
                      jobTitle: sp.labourName,
                      worksCountText: '—',
                      cityName: sp.cityName ?? '',
                      nationality: '',
                      providerId: sp.id, // مرر providerId هنا (حل الـ error)
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}