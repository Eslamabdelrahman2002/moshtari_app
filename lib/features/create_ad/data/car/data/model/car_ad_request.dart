import 'dart:io';

class CarAdRequest {
  final String title;
  final String description;
  final num price;
  final String priceType;

  final int categoryId; // لن يُستخدم مباشرة في toMap (سنرسل دائمًا 1)
  final int? cityId;
  final int? regionId;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool contactChat;
  final bool contactWhatsapp;
  final bool contactCall;

  final String condition;
  final String saleType;
  final String warranty;
  final num mileage;
  final String transmission;
  final int cylinders;
  final String color;
  final String fuelType;
  final String driveType;
  final int horsepower;
  final String doors;
  final String vehicleType;
  final int brandId;
  final int modelId;
  final int year;
  final bool allowComments;
  final bool allowMarketing;

  final List<File> images;
  final File? technicalReport;

  final int? exhibitionId; // ✅ NEW: أضف field لـ exhibitionId (اختياري)

  CarAdRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.priceType,
    required this.categoryId,
    this.cityId,
    this.regionId,
    this.latitude,
    this.longitude,
    this.phone,
    required this.contactChat,
    required this.contactWhatsapp,
    required this.contactCall,
    required this.condition,
    required this.saleType,
    required this.warranty,
    required this.mileage,
    required this.transmission,
    required this.cylinders,
    required this.color,
    required this.fuelType,
    required this.driveType,
    required this.horsepower,
    required this.doors,
    required this.vehicleType,
    required this.brandId,
    required this.modelId,
    required this.year,
    required this.allowComments,
    required this.allowMarketing,
    required this.images,
    this.technicalReport,
    this.exhibitionId, // ✅ NEW: اجعله optional
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'price_type': priceType,
      // ثابت: سيارات
      'category_id': 1,
      'city_id': cityId,
      'region_id': regionId,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'contact_chat': contactChat,
      'contact_whatsapp': contactWhatsapp,
      'contact_call': contactCall,
      'condition': condition,
      'sale_type': saleType,
      'warranty': warranty,
      'mileage': mileage,
      'transmission': transmission,
      'cylinders': cylinders,
      'color': color,
      'fuel_type': fuelType,
      'drive_type': driveType,
      'horsepower': horsepower,
      'doors': doors,
      'vehicle_type': vehicleType,
      'brand_id': brandId,
      'model_id': modelId,
      'year': year,
      'allow_comments': allowComments,
      'allow_marketing': allowMarketing,
      'exhibition_id': exhibitionId, // ✅ NEW: أضف exhibition_id في الـ map (لو موجود)
    };
  }
}