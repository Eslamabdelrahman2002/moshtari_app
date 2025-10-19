import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../data/model/earning_model.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  // State for managing the selected filter
  EarningCategory _selectedFilter = EarningCategory.all;

  // Mock data for the list
  final List<EarningModel> _allEarnings = [
    EarningModel(title: 'مشاركة رابط الاحالة', date: '20/04/2024', amount: 400, category: EarningCategory.referral),
    EarningModel(title: 'خدمات مشتري', date: '20/04/2024', amount: 800, category: EarningCategory.services),
    EarningModel(title: 'شركائنا', date: '20/04/2024', amount: 700, category: EarningCategory.partners),
    EarningModel(title: 'مشاركة رابط الاحالة', date: '20/04/2024', amount: 600, category: EarningCategory.referral),
    EarningModel(title: 'خدمات مشتري', date: '20/04/2024', amount: 500, category: EarningCategory.services),
    EarningModel(title: 'شركائنا', date: '20/04/2024', amount: 850, category: EarningCategory.partners),
  ];

  // List that will be displayed in the UI
  late List<EarningModel> _filteredEarnings;

  @override
  void initState() {
    super.initState();
    // Initially, show all earnings
    _filteredEarnings = _allEarnings;
  }

  void _filterEarnings(EarningCategory category) {
    setState(() {
      _selectedFilter = category;
      if (category == EarningCategory.all) {
        _filteredEarnings = _allEarnings;
      } else {
        _filteredEarnings = _allEarnings.where((earning) => earning.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أرباحي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          verticalSpace(24),
          _buildTotalEarningsCard(),
          verticalSpace(24),
          _buildFilterChips(),
          verticalSpace(24),
          _buildEarningsList(),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(42.w),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('مجموع الأرباح', style: TextStyles.font20White500Weight),
            verticalSpace(8),
            Text('415,38 رس', style: TextStyles.font24White500Weight),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 35.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _FilterChip(
            label: 'الكل',
            isSelected: _selectedFilter == EarningCategory.all,
            onTap: () => _filterEarnings(EarningCategory.all),
          ),
          _FilterChip(
            label: 'شركائنا',
            isSelected: _selectedFilter == EarningCategory.partners,
            onTap: () => _filterEarnings(EarningCategory.partners),
          ),
          _FilterChip(
            label: 'مشاركة رابط الاحالة',
            isSelected: _selectedFilter == EarningCategory.referral,
            onTap: () => _filterEarnings(EarningCategory.referral),
          ),
          _FilterChip(
            label: 'خدمات مشتري',
            isSelected: _selectedFilter == EarningCategory.services,
            onTap: () => _filterEarnings(EarningCategory.services),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _filteredEarnings.length,
        itemBuilder: (context, index) {
          return _EarningListItem(earning: _filteredEarnings[index]);
        },
        separatorBuilder: (context, index) => verticalSpace(16),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.only(left: 8.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: isSelected ? TextStyles.font14Blue500Weight : TextStyles.font14DarkGray400Weight,
        ),
      ),
    );
  }
}

class _EarningListItem extends StatelessWidget {
  final EarningModel earning;
  const _EarningListItem({required this.earning});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: ColorsManager.dark50,
          child: MySvg(image: 'money-recive'),
        ),
        horizontalSpace(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(earning.title, style: TextStyles.font14Black500Weight),
            verticalSpace(4),
            Text(earning.date, style: TextStyles.font12DarkGray400Weight),
          ],
        ),
        const Spacer(),
        Text(
          '+${earning.amount.toStringAsFixed(0)} رس',
          style: TextStyles.font16Dark500400Weight.copyWith(color: ColorsManager.teal),
        ),


      ],
    );
  }
}