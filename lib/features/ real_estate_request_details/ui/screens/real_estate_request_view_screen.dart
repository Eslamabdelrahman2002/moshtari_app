import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ لفتح واتساب/اتصال
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import '../cubit/real_estate_request_details_cubit.dart';
import '../cubit/real_estate_request_details_state.dart';
import '../widgets/RealEstateRequestBody.dart';
import '../widgets/request_bottom_actions.dart'; // ✅ استيراد الويدجت اللي عملته

class RealEstateRequestViewScreen extends StatelessWidget {
  final int id;
  const RealEstateRequestViewScreen({super.key, required this.id});

  // ✅ فتح محادثة واتساب
  Future<void> _openWhatsapp(String? phone) async {
    if (phone == null || phone.isEmpty) {
      debugPrint('No phone number');
      return;
    }
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('WhatsApp not available');
    }
  }

  // ✅ إجراء اتصال عادي
  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      debugPrint('No phone number');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Cannot make call');
    }
  }

  // ✅ فتح شاشة محادثة داخل التطبيق (كمثال حالياً يظهر SnackBar)
  void _openChat(BuildContext context, String? username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فتح محادثة مع ${username ?? "المعلن"}')),
    );
    // هنا لاحقًا يمكنك استدعاء:
    // navigatorKey.currentState?.pushNamed(Routes.chatScreen, arguments: ChatScreenArgs(...));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:MySvg(image: 'realstate-logo'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<RealEstateRequestDetailsCubit, RealEstateRequestDetailsState>(
        builder: (context, state) {
          // 🌀 حالة التحميل
          if (state is RequestDetailsInitial || state is RequestDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ حالة النجاح
          if (state is RequestDetailsSuccess) {
            final property = state.details;
            final phone = property.user?.phoneNumber;
            final username = property.user?.username;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 90.h), // نترك مساحة للـ navbar
                child: RealEstateRequestBody(
                  property: property,
                  id: id,
                ),
              ),
            );
          }

          // ⚠️ حالة الخطأ
          if (state is RequestDetailsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'حدث خطأ أثناء تحميل التفاصيل',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<RealEstateRequestDetailsCubit>().fetch(id),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 📂 أي حالة أخرى
          return const Center(child: Text('لم يتم العثور على بيانات الطلب.'));
        },
      ),

      // ✅ الـ bottomNavigationBar
      bottomNavigationBar: BlocBuilder<RealEstateRequestDetailsCubit, RealEstateRequestDetailsState>(
        builder: (context, state) {
          if (state is! RequestDetailsSuccess) return const SizedBox();

          final user = state.details.user;
          final String? phone = user?.phoneNumber;
          final String? username = user?.username;

          return RequestBottomActions(
            onWhatsapp: () => _openWhatsapp(phone),
            onCall: () => _makeCall(phone),
            onChat: () => _openChat(context, username),
          );
        },
      ),
    );
  }
}