import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/marketing_request_cubit.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/marketing_request_state.dart';

Future<void> showMarketingRequestSheet(BuildContext context, {
  required int adId,
  String defaultMessage = 'أرغب في تسويق هذا الإعلان، برجاء تواصلكم معي.',
}) async {
  final textCtrl = TextEditingController(text: defaultMessage);
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) {
      return BlocProvider(
        create: (_) => getIt<MarketingRequestCubit>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: BlocConsumer<MarketingRequestCubit, MarketingRequestState>(
            listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
            listener: (context, state) {
              if (state.success) {
                Navigator.of(sheetCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.serverMessage ?? 'تم إرسال طلب التسويق بنجاح')),
                );
              } else if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
            },
            builder: (context, state) {
              final sending = state.submitting;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('طلب تسويق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textCtrl,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: sending || textCtrl.text.trim().isEmpty
                              ? null
                              : () {
                            context.read<MarketingRequestCubit>().submit(
                              adId: adId,
                              message: textCtrl.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                          child: Text(sending ? 'جارٍ الإرسال...' : 'إرسال'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}