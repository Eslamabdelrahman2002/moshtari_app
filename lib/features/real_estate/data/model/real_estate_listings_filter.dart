// file: real_estate_listings_filter.dart

/// كائن الفلترة الرئيسي المستخدم لجلب القوائم العقارية
class RealEstateListingsFilter {
  /// ad | request
  final String type;

  /// الغرض: buy | sell | rent (حسب الـ API)
  final String? requestType;

  /// نوع العقار: apartment | villa | land | ...
  final String? realEstateType;

  /// طريقة الدفع: cash | installment (اختياري)
  final String? paymentMethod;

  /// المدينة
  final int? cityId;

  /// أقل وأعلى ميزانية
  final double? minBudget;
  final double? maxBudget;

  /// ترتيب النتائج: latest | price_asc | price_desc
  final String? sortBy;

  /// الترقيم
  final int page;
  final int perPage;

  const RealEstateListingsFilter({
    required this.type,
    this.requestType,
    this.realEstateType,
    this.paymentMethod,
    this.cityId,
    this.minBudget,
    this.maxBudget,
    this.sortBy,
    this.page = 1,
    this.perPage = 20,
  });

  /// إنشاء نسخة جديدة مع تغييرات معينة
  RealEstateListingsFilter copyWith({
    String? type,
    String? requestType,
    String? realEstateType,
    String? paymentMethod,
    int? cityId,
    double? minBudget,
    double? maxBudget,
    String? sortBy,
    int? page,
    int? perPage,
  }) {
    return RealEstateListingsFilter(
      type: type ?? this.type,
      requestType: requestType ?? this.requestType,
      realEstateType: realEstateType ?? this.realEstateType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cityId: cityId ?? this.cityId,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  /// تحويل الفلتر إلى بارامترات استعلام لإرسالها ضمن GET
  Map<String, dynamic> toQuery() {
    final Map<String, dynamic> q = {
      // نوع الصفحة: إعلانات أو طلبات
      'type': type, // ad | request

      // الغرض / نوع العملية (بيع - إيجار - شراء)
      if (requestType != null && requestType!.isNotEmpty)
        'purpose': requestType, // مفتاح يتطابق مع الحقل في الموديل RealEstateListModel

      // نوع العقار
      if (realEstateType != null && realEstateType!.isNotEmpty)
        'real_estate_type': realEstateType,

      // طريقة الدفع إن وُجدت
      if (paymentMethod != null && paymentMethod!.isNotEmpty)
        'payment_method': paymentMethod,

      // المدينة
      if (cityId != null) 'city_id': cityId,

      // الحدود السعرية
      if (minBudget != null) 'min_budget': minBudget,
      if (maxBudget != null) 'max_budget': maxBudget,

      // الترتيب المطلوب
      if (sortBy != null && sortBy!.isNotEmpty) 'sort_by': sortBy,

      // الترقيم (صفحة / عدد)
      'page': page,
      'per_page': perPage,
    };

    // تنظيف أي قيم null أو فاضية
    q.removeWhere((key, val) => val == null || (val is String && val.isEmpty));

    // لأغراض التتبع يمكنك إظهار القيم في الـ Console أثناء التطوير:
    // print('🛰️ Sending query params: $q');

    return q;
  }
}