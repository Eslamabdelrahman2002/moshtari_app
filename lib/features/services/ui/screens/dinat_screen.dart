// features/services/ui/screens/dinat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/sliver_app_bar_delegate.dart';
import 'package:mushtary/features/home/ui/widgets/home_screen_app_bar.dart';
import '../../data/model/dinat_mock_data.dart';
import '../widgets/dinat_grid_view.dart';
import '../widgets/dinat_section_header.dart';
import '../widgets/service_action_bar.dart';

class DinatScreen extends StatefulWidget {
  const DinatScreen({super.key});

  @override
  State<DinatScreen> createState() => _DinatScreenState();
}

class _DinatScreenState extends State<DinatScreen> {
  bool isListView = false; // افتراضي Grid

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // AppBar (تم تثبيته)
        SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: SliverAppBarDelegate(
            maxHeight: 70.h,
            minHeight: 70.h,
            child: DinatSectionHeader()
          ),
        ),

        SliverToBoxAdapter(child: verticalSpace(8)),

        // شريط التحويل (مُعلق حالياً، يمكن فك تعليقه لاستخدامه)
        // SliverToBoxAdapter(
        //   child: ServiceActionBar(
        //     onGridViewTap: () => setState(() => isListView = false),
        //     onListViewTap: () => setState(() => isListView = true),
        //     isListView: isListView,
        //   ),
        // ),

        // محتوى الشبكة
        DinatGridView(trips: mockDinatTrips),
        SliverToBoxAdapter(child: verticalSpace(16)),
      ],
    );
  }
}