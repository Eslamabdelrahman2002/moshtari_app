class CreateServiceRequest {
  final String serviceType;           // dyna | flatbed | tanker
  final String description;
  final String phone;
  final String scheduleType;          // now | later
  final String? scheduleTimeIso;      // ISO-8601 إذا later
  final String? notes;
  final int cityId;
  final int regionId;
  final double latitude;
  final double longitude;

  final Map<String, dynamic> extras;  // حقول إضافية خاصة بكل خدمة

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
    this.extras = const {},
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'service_type': serviceType,
      'description': description,
      'phone': phone,
      'schedule_type': scheduleType,
      if (scheduleTimeIso != null) 'schedule_time': scheduleTimeIso,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
      'city_id': cityId,
      'region_id': regionId,
      'latitude': latitude,
      'longitude': longitude,
    };
    data.addAll(extras);
    return data;
  }
}