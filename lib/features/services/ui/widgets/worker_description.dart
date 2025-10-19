import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/widgets/show_more.dart';

class WorkerDescription extends StatefulWidget {
  final String? description; // من provider.description (ديناميكي)

  const WorkerDescription({
    super.key,
    this.description, // يمكن null
  });

  @override
  State<WorkerDescription> createState() => _WorkerDescriptionState();
}

class _WorkerDescriptionState extends State<WorkerDescription> {
  double? _containerHeight = 25.h;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('الوصف', style: TextStyles.font16Dark300Grey400Weight),
          ),
        ),
        verticalSpace(8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _containerHeight,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Text(
                  widget.description ?? 'لا يوجد وصف متوفر', // ديناميكي مع null handling
                  style: TextStyles.font14Black500Weight,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                ),
              ),
            ),
          ),
        ),
        verticalSpace(16),
        ShowMore(
          onTap: _toggleHeight,
        )
      ],
    );
  }

  void _toggleHeight() {
    setState(() {
      _containerHeight = _containerHeight == 25.h ? null : 25.h;
    });
  }
}