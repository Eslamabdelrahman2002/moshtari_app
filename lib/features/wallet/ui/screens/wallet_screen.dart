import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
// ✨ 1. IMPORT the bottom sheet helper and the new dialog widgets
import 'package:mushtary/core/widgets/primary/primary_bottom_sheet.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/wallet/data/transaction_model.dart';
import 'package:mushtary/features/wallet/ui/screens/widgets/add_balance_sheet.dart';
import 'package:mushtary/features/wallet/ui/screens/widgets/transfer_balance_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with data from your Cubit
    final List<TransactionModel> transactions = [
      TransactionModel(title: 'شحن للحفظة', date: '20/04/2024', amount: 350, type: TransactionType.deposit),
      TransactionModel(title: 'كسب عن طريق التطبيق', date: '20/04/2024', amount: -150, type: TransactionType.withdrawal),
      TransactionModel(title: 'شحن للحفظة', date: '20/04/2024', amount: 350, type: TransactionType.deposit),
      TransactionModel(title: 'عميلة رقم #156555', date: '20/04/2024', amount: -350, type: TransactionType.fee, transactionId: '#156555'),
      TransactionModel(title: 'شحن للحفظة', date: '20/04/2024', amount: 350, type: TransactionType.deposit),
    ];

    return Scaffold(
      appBar: AppBar(
        title:  Text('المحفظة',style: TextStyles.font20Black500Weight,),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios,color: ColorsManager.darkGray300,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(24),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الرصيد الحالي', style: TextStyles.font14Primary300500Weight),
                  verticalSpace(8),
                  Row(
                    children: [
                      Text('415,38 رس', style: TextStyles.font24White500Weight),
                      const Spacer(),
                      Text('يمكنك سحبة', style: TextStyles.font12Primary100400Weight),
                    ],
                  ),
                ],
              ),
            ),
            verticalSpace(16),
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
                  Expanded(
                    child: Text(
                      'يوجد لديك 1250 ريال لا يمكن سحبهم حتي تاريخ 30/06/2024',
                      style: TextStyles.font14secondary600yellow400Weight,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'تحويل الرصيد',
                    // ✨ 2. CONNECT the "Transfer Balance" button
                    onPressed: () {
                      showPrimaryBottomSheet(
                        context: context,
                        child: const TransferBalanceSheet(),
                      );
                    },
                    isOutlineButton: true,
                    backgroundColor: ColorsManager.white,
                    textColor: ColorsManager.primaryColor,
                    borderColor: ColorsManager.primaryColor,
                    prefixIcon: const MySvg(image: 'arrow-up-primary'),
                  ),
                ),
                horizontalSpace(16),
                Expanded(
                  child: PrimaryButton(
                    text: 'شحن الرصيد',
                    // ✨ 3. CONNECT the "Add Balance" button
                    onPressed: () {
                      showPrimaryBottomSheet(
                        context: context,
                        child: const AddBalanceSheet(),
                      );
                    },
                    prefixIcon: const MySvg(image: 'arrow-down-white'),
                  ),
                ),
              ],
            ),
            verticalSpace(32),
            Text('العمليات السابقة', style: TextStyles.font16Black500Weight),
            verticalSpace(16),
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return _TransactionListItem(transaction: transactions[index]);
                },
                separatorBuilder: (context, index) => verticalSpace(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isDeposit = transaction.amount > 0;
    final Color amountColor = isDeposit ? ColorsManager.teal : ColorsManager.errorColor;
    final IconData iconData = isDeposit ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(iconData, color: amountColor, size: 20),
        ),
        horizontalSpace(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.title, style: TextStyles.font14Black500Weight),
            verticalSpace(4),
            Text(transaction.date, style: TextStyles.font12DarkGray400Weight),
          ],
        ),
        const Spacer(),
        Text(
          '${isDeposit ? '+' : ''}${transaction.amount.toStringAsFixed(0)} رس',
          style: TextStyles.font16Black500Weight.copyWith(color: amountColor),
        ),
      ],
    );
  }
}