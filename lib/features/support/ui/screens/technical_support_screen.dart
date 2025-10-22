import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import '../logic/conversation_report_cubit.dart';
import '../logic/conversation_report_state.dart';

enum TicketType { complaint, suggestion }

class TechnicalSupportScreen extends StatefulWidget {
  final int? conversationId; // صار اختياري

  const TechnicalSupportScreen({super.key, this.conversationId});

  @override
  State<TechnicalSupportScreen> createState() => _TechnicalSupportScreenState();
}

class _TechnicalSupportScreenState extends State<TechnicalSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();

  TicketType? _selectedType = TicketType.complaint;
  String? _selectedDepartment;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReportEnabled = widget.conversationId != null;

    return BlocProvider<ConversationReportCubit>(
      create: (_) => getIt<ConversationReportCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('الدعم الفني', style: TextStyles.font20Black500Weight),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocListener<ConversationReportCubit, ConversationReportState>(
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال البلاغ بنجاح')),
              );
              Navigator.of(context).pop(true);
            } else if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تلميح إن ما في محادثة محددة (لو فتحت الدعم من المنيو)
                  if (!isReportEnabled) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.orange.withOpacity(0.25)),
                      ),
                      child: Text(
                        'لفتح بلاغ يخص محادثة، الرجاء فتح شاشة الدعم من داخل المحادثة.',
                        style: TextStyles.font12DarkGray400Weight,
                      ),
                    ),
                    verticalSpace(16),
                  ],

                  Text('نوع التذكرة', style: TextStyles.font14Black500Weight),
                  verticalSpace(16),
                  Row(
                    children: [
                      Expanded(child: _buildTypeChip('شكوى', TicketType.complaint)),
                      horizontalSpace(16),
                      Expanded(child: _buildTypeChip('إقتراح', TicketType.suggestion)),
                    ],
                  ),
                  verticalSpace(24),

                  if (_selectedType == TicketType.complaint) _buildComplaintForm(),
                  if (_selectedType == TicketType.suggestion) _buildSuggestionForm(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.w),
          child: BlocBuilder<ConversationReportCubit, ConversationReportState>(
            builder: (context, state) {
              final disabled = state.submitting || !isReportEnabled;

              return PrimaryButton(
                text: state.submitting
                    ? 'جاري الإرسال...'
                    : (isReportEnabled ? 'إرسال رسالة' : 'افتح من المحادثة للإبلاغ'),
                isDisabled: disabled,
                isLoading: state.submitting,
                onPressed: () {
                  if (!isReportEnabled) return;
                  if (_formKey.currentState!.validate()) {
                    final reason = _reasonCtrl.text.trim();
                    context.read<ConversationReportCubit>().submit(
                      conversationId: widget.conversationId!,
                      reason: reason,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, TicketType type) {
    bool isSelected = _selectedType == type;
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? ColorsManager.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : ColorsManager.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: isSelected ? BorderSide.none : const BorderSide(color: ColorsManager.dark200),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyles.font14Black500Weight.copyWith(
            color: isSelected ? Colors.white : ColorsManager.darkGray,
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintForm() {
    final List<String> departments = ['القسم الأول', 'القسم الثاني', 'القسم الثالث'];
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          hint: Text('القسم المختار', style: TextStyles.font14Dark200400Weight),
          decoration: InputDecoration(
            labelText: 'الشكوى في قسم',
            labelStyle: TextStyles.font12Dark500400Weight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: ColorsManager.dark200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: ColorsManager.dark200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: ColorsManager.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: departments.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDepartment = newValue;
            });
          },
        ),
        verticalSpace(16),
        SecondaryTextFormField(
          controller: _reasonCtrl,
          label: 'تفاصيل الشكوى',
          hint: 'اكتب تفاصيل شكواك هنا...',
          maxLines: 5,
          maxheight: 120,
          minHeight: 120,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'اكتب سبب البلاغ' : null,
        ),
      ],
    );
  }

  Widget _buildSuggestionForm() {
    return Column(
      children: [
        SecondaryTextFormField(
          controller: _reasonCtrl,
          label: 'تفاصيل الإقتراح',
          hint: 'اكتب تفاصيل اقتراحك هنا...',
          maxLines: 5,
          maxheight: 120,
          minHeight: 120,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'اكتب سبب البلاغ' : null,
        ),
      ],
    );
  }
}