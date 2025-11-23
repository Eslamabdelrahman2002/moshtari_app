class CreateServiceRequest {
  // dyna | flatbed | tanker
  final String serviceType;

  final String description;
  final String phone;

  // now | scheduled
  final String scheduleType;

  // يُفضّل ISO-8601 عند الإرسال (مثال: 2025-01-25T14:00:00)
  // لكن يُمكن تمرير أي String إذا الـ Backend يقبله
  final String? scheduleTimeIso;

  final String? notes;

  // التابع الإداري والموقع العام (عادة موقع المستخدم/الطلب)
  final int cityId;
  final int regionId;
  final double latitude;
  final double longitude;

  // مواقع الالتقاط والتسليم (مشتركة بين كل الخدمات)
  final String pickupLocation;
  final double pickupLatitude;
  final double pickupLongitude;

  final String dropoffLocation;
  final double dropoffLatitude;
  final double dropoffLongitude;

  // حقول إضافية لكل خدمة (flatbed/dyna/tanker)
  final Map<String, dynamic> extras;

  CreateServiceRequest({
    required this.serviceType,
    required this.description,
    required this.phone,
    required this.scheduleType,
    this.scheduleTimeIso,
    this.notes,
    required this.cityId,
    required this.regionId,
    required this.latitude,
    required this.longitude,
    required this.pickupLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLocation,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    this.extras = const {},
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'service_type': serviceType,
      'description': description,
      'phone': phone,
      'schedule_type': scheduleType,
      if (scheduleTimeIso != null && scheduleTimeIso!.trim().isNotEmpty)
        'schedule_time': scheduleTimeIso,

      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,

      'city_id': cityId,
      'region_id': regionId,
      'latitude': latitude,
      'longitude': longitude,

      'pickup_location': pickupLocation,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,

      'dropoff_location': dropoffLocation,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
    };

    // دمج الحقول الإضافية الخاصة بكل خدمة
    data.addAll(extras);
    return data;
  }

  // مُنشئات مساعدة لكل نوع خدمة لتجميع الحقول الإضافية بسهولة
  factory CreateServiceRequest.flatbed({
    required String description,
    required String phone,
    String scheduleType = 'now', // now | scheduled
    String? scheduleTimeIso,
    String? notes,
    required int cityId,
    required int regionId,
    required double latitude,
    required double longitude,
    required String pickupLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required String dropoffLocation,
    required double dropoffLatitude,
    required double dropoffLongitude,

    // Extras
    required String vehicleType,          // مثال: "سيدان"
    required String vehicleStatus,        // مثال: "سليم"
    required String flatbedServiceType,   // مثال: "عادية"
    required String flatbedSize,          // مثال: "متوسطة"
  }) {
    return CreateServiceRequest(
      serviceType: 'flatbed',
      description: description,
      phone: phone,
      scheduleType: scheduleType,
      scheduleTimeIso: scheduleTimeIso,
      notes: notes,
      cityId: cityId,
      regionId: regionId,
      latitude: latitude,
      longitude: longitude,
      pickupLocation: pickupLocation,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLocation: dropoffLocation,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      extras: {
        'vehicle_type': vehicleType,
        'vehicle_status': vehicleStatus,
        'flatbed_service_type': flatbedServiceType,
        'flatbed_size': flatbedSize,
      },
    );
  }

  factory CreateServiceRequest.dyna({
    required String description,
    required String phone,
    String scheduleType = 'now', // now | scheduled
    String? scheduleTimeIso,
    String? notes,
    required int cityId,
    required int regionId,
    required double latitude,
    required double longitude,
    required String pickupLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required String dropoffLocation,
    required double dropoffLatitude,
    required double dropoffLongitude,

    // Extras
    required String cargoType,          // مثال: "اثاث"
    required String vehicleSize,        // مثال: "كبيرة"
    String? extraDetails,               // مثال: "التواصل سيتم من خلال رقم الهاتف"
  }) {
    return CreateServiceRequest(
      serviceType: 'dyna',
      description: description,
      phone: phone,
      scheduleType: scheduleType,
      scheduleTimeIso: scheduleTimeIso,
      notes: notes,
      cityId: cityId,
      regionId: regionId,
      latitude: latitude,
      longitude: longitude,
      pickupLocation: pickupLocation,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLocation: dropoffLocation,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      extras: {
        'cargo_type': cargoType,
        'vehicle_size': vehicleSize,
        if (extraDetails != null && extraDetails.trim().isNotEmpty)
          'extra_details': extraDetails,
      },
    );
  }

  factory CreateServiceRequest.tanker({
    required String description,
    required String phone,
    String scheduleType = 'now', // now | scheduled
    String? scheduleTimeIso,
    String? notes,
    required int cityId,
    required int regionId,
    required double latitude,
    required double longitude,
    required String pickupLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required String dropoffLocation,
    required double dropoffLatitude,
    required double dropoffLongitude,

    // Extras
    required String tankerSize,           // مثال: "Medium"
    required String tankerWaterType,      // مثال: "sweet"
    required List<String> tankerServices, // مثال: ["منزل","شركة","مستشفى"]
  }) {
    return CreateServiceRequest(
      serviceType: 'tanker',
      description: description,
      phone: phone,
      scheduleType: scheduleType,
      scheduleTimeIso: scheduleTimeIso,
      notes: notes,
      cityId: cityId,
      regionId: regionId,
      latitude: latitude,
      longitude: longitude,
      pickupLocation: pickupLocation,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLocation: dropoffLocation,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      extras: {
        'tanker_size': tankerSize,
        'tanker_water_type': tankerWaterType,
        'tanker_services': tankerServices,
      },
    );
  }

  factory CreateServiceRequest.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    int _toInt(dynamic v) => v is num ? v.toInt() : int.parse(v.toString());

    final serviceType = (json['service_type'] ?? '').toString();

    // التقاط الحقول الإضافية حسب نوع الخدمة
    final Map<String, dynamic> extras = {};
    if (serviceType == 'flatbed') {
      if (json.containsKey('vehicle_type')) extras['vehicle_type'] = json['vehicle_type'];
      if (json.containsKey('vehicle_status')) extras['vehicle_status'] = json['vehicle_status'];
      if (json.containsKey('flatbed_service_type')) extras['flatbed_service_type'] = json['flatbed_service_type'];
      if (json.containsKey('flatbed_size')) extras['flatbed_size'] = json['flatbed_size'];
    } else if (serviceType == 'dyna') {
      if (json.containsKey('cargo_type')) extras['cargo_type'] = json['cargo_type'];
      if (json.containsKey('vehicle_size')) extras['vehicle_size'] = json['vehicle_size'];
      if (json.containsKey('extra_details')) extras['extra_details'] = json['extra_details'];
    } else if (serviceType == 'tanker') {
      if (json.containsKey('tanker_size')) extras['tanker_size'] = json['tanker_size'];
      if (json.containsKey('tanker_water_type')) extras['tanker_water_type'] = json['tanker_water_type'];
      if (json.containsKey('tanker_services')) extras['tanker_services'] = json['tanker_services'];
    }

    // دعم الخلفية القديمة 'later' وتحويلها لـ 'scheduled'
    final String scheduleType = switch ((json['schedule_type'] ?? 'now').toString()) {
      'later' => 'scheduled',
      'scheduled' => 'scheduled',
      _ => 'now',
    };

    return CreateServiceRequest(
      serviceType: serviceType,
      description: json['description']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      scheduleType: scheduleType,
      scheduleTimeIso: json['schedule_time']?.toString(),
      notes: json['notes']?.toString(),
      cityId: _toInt(json['city_id']),
      regionId: _toInt(json['region_id']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      pickupLocation: json['pickup_location']?.toString() ?? '',
      pickupLatitude: _toDouble(json['pickup_latitude']),
      pickupLongitude: _toDouble(json['pickup_longitude']),
      dropoffLocation: json['dropoff_location']?.toString() ?? '',
      dropoffLatitude: _toDouble(json['dropoff_latitude']),
      dropoffLongitude: _toDouble(json['dropoff_longitude']),
      extras: extras,
    );
  }
}