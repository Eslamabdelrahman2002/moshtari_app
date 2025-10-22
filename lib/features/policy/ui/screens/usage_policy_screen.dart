import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class UsagePolicyScreen extends StatelessWidget {
  final bool showAcceptButton;
  final VoidCallback? onAccept;

  const UsagePolicyScreen({
    super.key,
    this.showAcceptButton = true,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <_PolicySectionData>[
      _PolicySectionData(
        title: 'نطاق المنصّة',
        bullets: [
          'منصة “مشتري” تتيح: عرض الإعلانات، إنشاء/المشاركة في المزادات، طلب خدمات (مثل نقل أو عامل)، والتسجيل كمقدّم خدمات.',
          'استخدامك للمنصّة يعني قبولك الكامل لهذه السياسة وجميع التحديثات اللاحقة.',
        ],
      ),
      _PolicySectionData(
        title: 'الإعلانات',
        bullets: [
          'يلتزم المُعلن بصحّة بيانات الإعلان وعدم تضمين أي محتوى مضلّل أو مخالف للأنظمة.',
          'الصور والنصوص يجب أن تعكس السلعة/الخدمة بدقّة، ويُمنع استخدام العلامات التجارية دون إذن.',
          'يُمكن للمنصّة تعديل أو إخفاء أو حذف أي إعلان مخالف دون إشعار مسبق.',
        ],
      ),
      _PolicySectionData(
        title: 'المزادات',
        bullets: [
          'المشاركة في المزاد تعني الالتزام بشروط المزاد الخاصة (الأسعار، مواعيد الإغلاق، رسوم الإلغاء).',
          'أعلى مزايدة عند انتهاء الوقت تُعدّ فائزة مالم يثبت العكس وفق بنود المزاد أو سياسات التحقّق.',
          'يحق للمنصّة إلغاء أو إيقاف المزاد عند وجود اشتباه في أي نشاط مخالف.',
        ],
      ),
      _PolicySectionData(
        title: 'طلبات الخدمات',
        bullets: [
          'يجب أن تكون تفاصيل الطلب واضحة ومحدّدة (نوع الخدمة، المكان، الوقت، أي متطلبات خاصة).',
          'قد تُفرض رسوم إلغاء عند إلغاء الطلب بعد قبول مقدّم الخدمة، وفق ما يتم تحديده.',
          'المنصّة وسيط تقني لربطك بمقدّمي الخدمات، ولا تتحمّل مسؤولية أداء الخدمة إلا في حدود أنظمتها.',
        ],
      ),
      _PolicySectionData(
        title: 'مقدّمو الخدمات',
        bullets: [
          'يلتزم مقدّم الخدمة بامتلاك التراخيص/الموافقات اللازمة حسب نوع النشاط (نقل، عمالة، …).',
          'الأسعار والمدة وجودة الأداء هي مسؤولية مقدّم الخدمة، مع الالتزام بسياسات المنصّة.',
          'المنصّة قد تطلب توثيق الهوية/السجل التجاري قبل تفعيل الحساب أو استمرار استخدام بعض الميزات.',
        ],
      ),
      _PolicySectionData(
        title: 'المحفظة والمدفوعات',
        bullets: [
          'قد تتوفر وسائل دفع متعدّدة (بطاقات/مدى/Apple Pay وغيرها).',
          'عمليات الشحن والسحب قد تخضع للتحقق والأنظمة المحلية ومتطلبات مزوّد الدفع.',
          'قد تُحتجز مبالغ لفترة محددة لأغراض الأمان أو تسوية النزاعات، ويتم إشعارك بذلك داخل التطبيق.',
        ],
      ),
      _PolicySectionData(
        title: 'الرسوم والعمولات',
        bullets: [
          'قد تُطبّق رسوم على بعض العمليات (إدراج إعلان مميّز، عمولة مزاد، عمولة خدمة).',
          'تُعرض قيمة الرسوم بوضوح قبل إتمام العملية، ويُعد المضيّ قدماً موافقة صريحة عليها.',
        ],
      ),
      _PolicySectionData(
        title: 'المحتوى المحظور',
        bullets: [
          'يُمنع نشر أي محتوى مخالف للأنظمة أو مسيء أو يتضمن تمييزاً أو انتهاكاً للملكية الفكرية.',
          'يُمنع استخدام المنصّة في أنشطة احتيالية أو غير قانونية أو التلاعب بالمزادات/الطلبات.',
          'يحق للمنصّة إزالة المحتوى المخالف وإيقاف الحساب عند الحاجة.',
        ],
      ),
      _PolicySectionData(
        title: 'مسؤوليات المستخدم',
        bullets: [
          'حماية بيانات الدخول إلى حسابك وعدم مشاركتها مع الغير.',
          'التأكد من صحة المعلومات قبل النشر أو تقديم العروض أو المشاركة في المزادات.',
          'الإبلاغ عن أي نشاط مريب أو مخالف عبر قنوات الدعم داخل التطبيق.',
        ],
      ),
      _PolicySectionData(
        title: 'النزاعات والإبلاغ',
        bullets: [
          'يمكنك رفع بلاغ عن محادثة أو مزاد أو خدمة من خلال شاشة الدعم الفني.',
          'تُعالج النزاعات وفق السياسات الداخلية والأنظمة المرعية، وقد يُطلب مستندات أو أدلة داعمة.',
        ],
      ),
      _PolicySectionData(
        title: 'إيقاف/إنهاء الحساب',
        bullets: [
          'يحق للمنصّة إيقاف أو إنهاء الحساب عند مخالفة الشروط أو إساءة الاستخدام.',
          'يمكنك طلب حذف حسابك مع مراعاة المتطلبات النظامية والمالية المعلنة.',
        ],
      ),
      _PolicySectionData(
        title: 'التحديثات',
        bullets: [
          'قد يتم تعديل سياسة الاستخدام من وقت لآخر، وسيتم إشعارك داخل التطبيق أو عبر القنوات المناسبة.',
          'استمرارك في استخدام التطبيق بعد التحديثات يُعد موافقة على النسخة المحدّثة.',
        ],
      ),
      _PolicySectionData(
        title: 'التواصل',
        bullets: [
          'للاستفسارات أو الملاحظات: استخدم شاشة الدعم الفني داخل التطبيق.',
          'سيتم الرد خلال أوقات العمل المُعلنة.',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsManager.white,
        centerTitle: true,
        title: Text('سياسة الاستخدام', style: TextStyles.font20Black500Weight),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            children: [
              // Header
              CircleAvatar(
                radius: 75.w,
                backgroundColor: ColorsManager.primaryColor,
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: MySvg(
                    image: 'help_center',
                    color: Colors.white,
                    width: 60.w,
                    height: 60.w,
                  ),
                ),
              ),
              verticalSpace(16),
              Text('سياسة الاستخدام', style: TextStyles.font24Black700Weight),
              verticalSpace(12),
              Text(
                'توضّح هذه السياسة شروط استخدام منصّة “مشتري” لعرض الإعلانات والمزادات وطلب الخدمات والتسجيل كمقدّم خدمة.',
                textAlign: TextAlign.center,
                style: TextStyles.font14DarkGray400Weight,
              ),
              verticalSpace(20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'آخر تحديث: ${_formatDate(DateTime.now())}',
                  style: TextStyles.font12DarkGray400Weight,
                  textAlign: TextAlign.left,
                ),
              ),
              verticalSpace(16),

              // Sections
              ...sections.map((s) => _PolicySection(data: s)).toList(),

              verticalSpace(24),

              if (showAcceptButton)
                PrimaryButton(
                  text: 'أوافق على سياسة الاستخدام',
                  onPressed: onAccept ?? () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // dd/MM/yyyy
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }
}

class _PolicySectionData {
  final String title;
  final List<String> bullets;
  const _PolicySectionData({required this.title, required this.bullets});
}

class _PolicySection extends StatelessWidget {
  final _PolicySectionData data;
  const _PolicySection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorsManager.dark100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          iconColor: ColorsManager.primaryColor,
          collapsedIconColor: ColorsManager.darkGray300,
          title: Text(data.title, style: TextStyles.font16Black500Weight),
          children: [
            Column(
              children: data.bullets.map((b) => _Bullet(text: b)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            margin: EdgeInsets.only(top: 6.h, left: 8.w, right: 8.w),
            decoration: const BoxDecoration(
              color: ColorsManager.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyles.font14DarkGray400Weight,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}