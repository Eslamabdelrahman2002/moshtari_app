// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mushtary/core/router/routes.dart';
// import 'package:mushtary/core/widgets/primary/primary_button.dart';
// import 'package:mushtary/features/register_service/logic/cubit/service_registration_cubit.dart';
// import 'package:mushtary/features/register_service/register_service_dialog.dart';
//
// class ServiceSelectionScreen extends StatelessWidget {
//   const ServiceSelectionScreen({super.key});
//
//   Future<void> _openRegisterDialog(BuildContext context) async {
//     // افتح الديالوج واستلم نتيجة (routeName + serviceType)
//     final result = await showModalBottomSheet<Map<String, String>>(
//       context: context,
//       isScrollControlled: true,
//       builder: (_) => const RegisterServiceDialog(),
//     );
//
//     if (result == null) return;
//
//     final routeName = result['routeName'];
//     final serviceType = result['serviceType'];
//
//     if (routeName == null || serviceType == null) return;
//
//     // جهّز الكيوبِت
//     context.read<ServiceRegistrationCubit>().initialize(serviceType);
//
//     // روح للمسار المناسب
//     Navigator.of(context).pushNamed(routeName);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('اختر نوع الخدمة')),
//       body: Center(
//         child: PrimaryButton(
//           text: 'سجل كمقدم خدمة',
//           onPressed: () => _openRegisterDialog(context),
//         ),
//       ),
//     );
//   }
// }