import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import '../../data/repo/myfatoorah_service.dart';
import '../../data/repo/payment_config_repo.dart';

enum PaymentMethod { applePay, card }

class AddBalanceSheet extends StatefulWidget {
  const AddBalanceSheet({super.key});

  @override
  State<AddBalanceSheet> createState() => _AddBalanceSheetState();
}

class _AddBalanceSheetState extends State<AddBalanceSheet> {
  PaymentMethod? _selectedMethod = PaymentMethod.applePay;
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPaying = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureMyFatoorahInited() async {
    if (MyFatoorahService.isInited) return;
    final cfg = await getIt<PaymentConfigRepo>().fetchMyFatoorahConfig();
    await MyFatoorahService.init(cfg);
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل مبلغ صحيح')));
      return;
    }

    setState(() => _isPaying = true);
    try {
      await _ensureMyFatoorahInited();

      // مبدئياً بنعرض كل طرق الدفع (paymentMethodId = 0)، اختيار Apple/Card في الواجهة شكلي
      await MyFatoorahService.pay(
        context: context,
        amount: amount,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // اقفل الشيت
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الدفع بنجاح، سيتم تحديث الرصيد قريباً')),
      );

      // TODO: استدعِ API لتأكيد الشحن وتحديث الرصيد:
      // await context.read<WalletCubit>().refresh();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شحن الرصيد', style: TextStyles.font18Black500Weight),
            verticalSpace(24),
            SecondaryTextFormField(
              controller: _amountCtrl,
              label: 'مبلغ الشحن',
              hint: '1500',
              isNumber: true,
              maxheight: 56,
              minHeight: 56,
              validator: (v) {
                final t = (v ?? '').trim();
                final n = double.tryParse(t);
                if (n == null || n <= 0) return 'أدخل مبلغ صحيح';
                return null;
              },
            ),
            verticalSpace(16),
            _buildPaymentMethodTile(title: 'Apple Pay', value: PaymentMethod.applePay),
            const Divider(color: ColorsManager.dark100),
            _buildPaymentMethodTile(title: 'مدى - Mastercard/Visa', value: PaymentMethod.card),
            verticalSpace(24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'إلغاء',
                    // مهم: onPressed يجب أن يكون غير nullable
                    onPressed: () {
                      if (_isPaying) return;
                      Navigator.of(context).pop();
                    },
                    backgroundColor: ColorsManager.dark50,
                    textColor: ColorsManager.darkGray600,
                  ),
                ),
                horizontalSpace(16),
                Expanded(
                  child: PrimaryButton(
                    text: _isPaying ? 'جاري الدفع...' : 'Pay',
                    onPressed: () {
                      if (_isPaying) return;
                      _handlePayment();
                    },
                    backgroundColor: Colors.black,
                    prefixIcon: const Icon(Icons.apple, color: Colors.white),
                    isLoading: _isPaying,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({required String title, required PaymentMethod value}) {
    return RadioListTile<PaymentMethod>(
      title: Text(title, style: TextStyles.font14Black500Weight),
      value: value,
      groupValue: _selectedMethod,
      onChanged: _isPaying
          ? null
          : (PaymentMethod? newValue) {
        setState(() => _selectedMethod = newValue);
      },
      activeColor: ColorsManager.primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}