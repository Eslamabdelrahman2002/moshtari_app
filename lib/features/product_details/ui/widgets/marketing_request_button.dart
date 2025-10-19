// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mushtary/core/widgets/primary/primary_button.dart';
//
// import '../logic/cubit/marketing_request_cubit.dart';
// import '../logic/cubit/marketing_request_state.dart';
//
// class MarketingRequestButton extends StatelessWidget {
//   final int adId;
//   final bool isOwner;
//   final String defaultMessage;
//
//   const MarketingRequestButton({
//     super.key,
//     required this.adId,
//     required this.isOwner,
//     this.defaultMessage = 'أرغب في تسويق هذا الإعلان، برجاء تواصلكم معي.',
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return PrimaryButton(
//       text: isOwner ? 'لا يمكنك طلب تسويق لإعلانك' : 'طلب تسويق',
//       onPressed: isOwner ? null : () => _openSheet(context),
//     );
//   }
//
//   void _openSheet(BuildContext context) {
//     final textCtrl = TextEditingController(text: defaultMessage);
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (sheetCtx) {
//         // استخدم نفس الكيوبت من السياق الأب
//         final cubit = context.read<MarketingRequestCubit>();
//         return BlocProvider.value(
//           value: cubit,
//           child: Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
//               left: 16,
//               right: 16,
//               top: 16,
//             ),
//             child: BlocConsumer<MarketingRequestCubit, MarketingRequestState>(
//               listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
//               listener: (context, state) {
//                 if (state.success) {
//                   Navigator.of(sheetCtx).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.serverMessage ?? 'تم إرسال طلب التسويق بنجاح')),
//                   );
//                 } else if (state.error != null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.error!)),
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 final sending = state.submitting;
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text('طلب تسويق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: textCtrl,
//                       minLines: 3,
//                       maxLines: 6,
//                       decoration: const InputDecoration(
//                         hintText: 'اكتب رسالتك للمسوق...',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: PrimaryButton(
//                             text: sending ? 'جارٍ الإرسال...' : 'إرسال',
//                             onPressed: sending || textCtrl.text.trim().isEmpty
//                                 ? null
//                                 : () {
//                               context.read<MarketingRequestCubit>().submit(
//                                 adId: adId,
//                                 message: textCtrl.text.trim(),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }