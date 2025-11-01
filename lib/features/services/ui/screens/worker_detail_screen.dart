import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/reminder.dart';

import 'package:mushtary/features/services/ui/widgets/rates.dart';
import 'package:mushtary/features/services/ui/widgets/service_app_bar.dart';
import 'package:mushtary/features/services/ui/widgets/user_comments.dart';
import 'package:mushtary/features/services/ui/widgets/user_profile_summary.dart';
import 'package:mushtary/features/services/ui/widgets/worker_description.dart';
import 'package:mushtary/features/services/ui/widgets/worker_images.dart';

import '../../../service_profile/ui/logic/cubit/provider_cubit.dart';
import '../../../service_profile/ui/logic/cubit/provider_state.dart';
import 'package:flutter/foundation.dart';

// Chat imports
import 'package:url_launcher/url_launcher.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';
import 'package:mushtary/features/messages/ui/widgets/chats/chat_initiation_sheet.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final int providerId;

  const WorkerDetailsScreen({super.key, required this.providerId});

  void _startChat(BuildContext context, int receiverUserId, String receiverName) {
    showChatInitiationSheet(
      context,
      receiverName: receiverName,
      onInitiate: (initialMessage) async {
        final repo = getIt<MessagesRepo>();

        int? conversationId;
        String errorMessage = 'تعذّر بدء المحادثة الآن.';

        try {
          conversationId = await repo.initiateChat(receiverUserId);
        } catch (e) {
          errorMessage = 'فشل: ${e.toString()}';
          debugPrint('Chat initiation failed: $e');
        }

        if (conversationId != null) {
          final chatModel = MessagesModel(
            conversationId: conversationId,
            partnerUser: UserModel(id: receiverUserId, name: receiverName),
            lastMessage: initialMessage,
          );

          final args = ChatScreenArgs(chatModel: chatModel, adInfo: null);
          NavX(context).pushNamed(Routes.chatScreen, arguments: args);

          await Future.delayed(const Duration(milliseconds: 400));

          final body = SendMessageRequestBody(
            receiverId: receiverUserId,
            messageContent: initialMessage,
            listingId: null,
          );
          await repo.sendMessage(body, conversationId);
        } else {
          _showSnack(context, errorMessage);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProviderCubit>(
          create: (context) => getIt<ProviderCubit>()..loadAll(providerId),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ProviderCubit, ProviderState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
              if (state.error != null) {
                return Center(child: Text('خطأ: ${state.error}', style: const TextStyle(color: Colors.red)));
              }
              final provider = state.provider;
              if (provider == null) {
                return const Center(child: Text('لا توجد بيانات للعرض'));
              }

              // Parsing images مع fallback لـ personalImage
              List<String> images = (provider.extraImages ?? [])
                  .whereType<List<dynamic>>()
                  .expand((list) => list.whereType<String>())
                  .toList();

              if (images.isEmpty && provider.personalImage != null && provider.personalImage!.isNotEmpty) {
                images = [provider.personalImage!];
              }

              debugPrint('Images in details: $images');

              final rate = provider.rating.average.toStringAsFixed(1);
              final jobTitle = provider.labourName ?? '';
              final displayJobTitle = jobTitle.isEmpty ? 'غير محدد' : jobTitle;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ServiceAppBar(),
                    WorkerImages(
                      images: images.isEmpty ? ['https://placeholder.com/default-image'] : images,
                      rate: rate,
                    ),
                    verticalSpace(16),
                    UserProfileSummary(
                      name: provider.fullName,
                      serviceType: displayJobTitle,
                      cityName: provider.cityName ?? 'غير متوفر',
                      nationality: provider.nationality ?? 'غير متوفر',
                      worksCount: '${provider.reviewsCount} عمل',
                    ),
                    MyDivider(height: 32.w),
                    WorkerDescription(description: provider.description ?? 'لا يوجد وصف'),
                    verticalSpace(16),
                    MyDivider(height: 48.w),
                    const Reminder(),
                    MyDivider(height: 48.w),
                    Rates(
                      average: provider.rating.average,
                      price: provider.rating.price,
                      professionalism: provider.rating.professionalism,
                      speed: provider.rating.speed,
                      quality: provider.rating.quality,
                      behavior: provider.rating.behavior,
                      reviewsCount: provider.reviewsCount,
                    ),
                    MyDivider(height: 48.w),
                    UserComments(comments: provider.comments),
                    verticalSpace(16),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BlocBuilder<ProviderCubit, ProviderState>(
            builder: (context, state) {
              if (state.loading || state.provider == null) {
                return const SizedBox.shrink();
              }
              final p = state.provider!;
              final phone = (p.phone ?? '').trim();
              final whatsappPhone = phone;

              // استخدم user_id الخاص بمقدم الخدمة (مهم جداً)
              final receiverUserId = p.labourId ?? 0;       // ← هنا الحل الحقيقي
              final receiverName = p.fullName;

              final myId = context.select<ProfileCubit, int?>((c) => c.user?.userId);
              final isOwner = (myId != null && receiverUserId == myId);

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // محادثة داخل التطبيق
                    Expanded(
                      child: _ContactButton(
                        background: ColorsManager.primary50,
                        iconColor: ColorsManager.primaryColor,
                        image: 'message_icon',
                        tooltip: 'محادثة',
                        onTap: () {
                          if (myId == null) {
                            _showSnack(context, 'يجب تسجيل الدخول أولاً لبدء المحادثة.');
                            return;
                          }
                          if (receiverUserId == 0) {
                            _showSnack(context, 'لا يمكن تحديد هوية مقدم الخدمة.');
                            return;
                          }
                          if (isOwner) {
                            _showSnack(context, 'لا يمكنك المحادثة مع نفسك.');
                            return;
                          }
                          _startChat(context, receiverUserId, receiverName);
                        },
                      ),
                    ),
                    horizontalSpace(12),
                    // اتصال
                    Expanded(
                      child: _ContactButton(
                        background: ColorsManager.primary50,
                        iconColor: ColorsManager.primaryColor,
                        image: 'callCalling',
                        tooltip: 'اتصال',
                        onTap: () => _callNumber(context, phone),
                      ),
                    ),
                    horizontalSpace(12),
                    // واتساب
                    Expanded(
                      child: _ContactButton(
                        background: ColorsManager.success100,
                        iconColor: ColorsManager.success500,
                        image: 'mingcute_whatsapp-line',
                        tooltip: 'واتساب',
                        onTap: () => _openWhatsApp(context, whatsappPhone),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final String image;
  final String? tooltip;

  const _ContactButton({
    super.key,
    required this.background,
    required this.iconColor,
    required this.onTap,
    required this.image,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            height: 48.w,
            decoration: BoxDecoration(
              color: background,
              borderRadius: radius,
            ),
            child: Center(
              child: MySvg(
                image: image,
                color: iconColor,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// دوال الربط

Future<void> _openWhatsApp(BuildContext context, String? phone) async {
  if (phone == null || phone.trim().isEmpty) {
    _showSnack(context, 'لا يوجد رقم واتساب');
    return;
  }
  final normalized = _normalizePhone(phone);
  final uri = Uri.parse('https://wa.me/$normalized');
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) _showSnack(context, 'تعذر فتح واتساب');
}

Future<void> _callNumber(BuildContext context, String? phone) async {
  if (phone == null || phone.trim().isEmpty) {
    _showSnack(context, 'لا يوجد رقم للاتصال');
    return;
  }
  final uri = Uri(scheme: 'tel', path: _normalizePhone(phone));
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) _showSnack(context, 'تعذر إجراء الاتصال');
}

String _normalizePhone(String phone) {
  return phone.replaceAll(RegExp(r'[^\d+]'), '');
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}