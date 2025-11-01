import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import '../../../../../core/dependency_injection/injection_container.dart';
import '../../data/model/offer_request.dart';
import '../logic/cubit/offer_cubit.dart';
import '../logic/cubit/offer_state.dart';

Future<void> showOfferSheet(BuildContext context, {required int adId}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
    builder: (_) {
      return BlocProvider<OfferCubit>(
        create: (_) => getIt<OfferCubit>(),
        child: _OfferSheet(adId: adId),
      );
    },
  );
}

class _OfferSheet extends StatefulWidget {
  final int adId;
  const _OfferSheet({required this.adId});

  @override
  State<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<_OfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: BlocConsumer<OfferCubit, OfferState>(
          listener: (context, state) {
            if (state is OfferSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is OfferFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            final loading = state is OfferLoading;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('أضف سومتك', style: TextStyles.font18Black500Weight),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                verticalSpace(8),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'قيمة السومة',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (v) {
                          final n = num.tryParse(v?.trim() ?? '');
                          if (n == null) return 'أدخل رقمًا صحيحًا';
                          if (n <= 0) return 'القيمة يجب أن تكون أكبر من صفر';
                          return null;
                        },
                      ),
                      verticalSpace(12),
                      TextFormField(
                        controller: _messageCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'رسالة (اختياري)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(16),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;
                      final amount = num.parse(_priceCtrl.text.trim());
                      final req = OfferRequest(adId: widget.adId, amount: amount, message: _messageCtrl.text.trim());
                      context.read<OfferCubit>().sendOffer(req);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primary400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(Colors.white))
                        : const Text('إرسال السومة', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}