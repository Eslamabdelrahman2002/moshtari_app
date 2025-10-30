import 'package:equatable/equatable.dart';

class RealEstateRequestsState extends Equatable {
  final String? requestType; // 'rent' or 'sell'
  final String? realEstateType;
  final int? regionId; // ✅ إضافة regionId
  final int? cityId;
  final num? budgetMin;
  final num? budgetMax;
  final num? areaMin;
  final num? areaMax;
  final int? streetWidthMin;
  final int? streetWidthMax;
  final int? preferredFloors;
  final int? preferredRooms;
  final int? preferredBathrooms;
  final int? preferredLivingrooms;
  final String? preferredFacade;
  final List<String> services;
  final String? paymentMethod;
  final String? contactPhone;
  final bool allowComments;
  final bool allowMarketingOffers;
  final bool allowNegotiation;
  final String? notes;
  final bool submitting;
  final bool success;
  final String? error;

  const RealEstateRequestsState({
    this.requestType,
    this.realEstateType,
    this.regionId, // ✅ إضافة
    this.cityId,
    this.budgetMin,
    this.budgetMax,
    this.areaMin,
    this.areaMax,
    this.streetWidthMin,
    this.streetWidthMax,
    this.preferredFloors,
    this.preferredRooms,
    this.preferredBathrooms,
    this.preferredLivingrooms,
    this.preferredFacade,
    this.services = const [],
    this.paymentMethod,
    this.contactPhone,
    this.allowComments = true,
    this.allowMarketingOffers = true,
    this.allowNegotiation = true,
    this.notes,
    this.submitting = false,
    this.success = false,
    this.error,
  });

  factory RealEstateRequestsState.initial() => const RealEstateRequestsState();

  RealEstateRequestsState copyWith({
    String? requestType,
    String? realEstateType,
    int? regionId, // ✅ إضافة
    int? cityId,
    num? budgetMin,
    num? budgetMax,
    num? areaMin,
    num? areaMax,
    int? streetWidthMin,
    int? streetWidthMax,
    int? preferredFloors,
    int? preferredRooms,
    int? preferredBathrooms,
    int? preferredLivingrooms,
    String? preferredFacade,
    List<String>? services,
    String? paymentMethod,
    String? contactPhone,
    bool? allowComments,
    bool? allowMarketingOffers,
    bool? allowNegotiation,
    String? notes,
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return RealEstateRequestsState(
      requestType: requestType ?? this.requestType,
      realEstateType: realEstateType ?? this.realEstateType,
      regionId: regionId ?? this.regionId, // ✅ إضافة
      cityId: cityId ?? this.cityId,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      areaMin: areaMin ?? this.areaMin,
      areaMax: areaMax ?? this.areaMax,
      streetWidthMin: streetWidthMin ?? this.streetWidthMin,
      streetWidthMax: streetWidthMax ?? this.streetWidthMax,
      preferredFloors: preferredFloors ?? this.preferredFloors,
      preferredRooms: preferredRooms ?? this.preferredRooms,
      preferredBathrooms: preferredBathrooms ?? this.preferredBathrooms,
      preferredLivingrooms: preferredLivingrooms ?? this.preferredLivingrooms,
      preferredFacade: preferredFacade ?? this.preferredFacade,
      services: services ?? this.services,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      contactPhone: contactPhone ?? this.contactPhone,
      allowComments: allowComments ?? this.allowComments,
      allowMarketingOffers: allowMarketingOffers ?? this.allowMarketingOffers,
      allowNegotiation: allowNegotiation ?? this.allowNegotiation,
      notes: notes ?? this.notes,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    requestType,
    realEstateType,
    regionId, // ✅ إضافة
    cityId,
    budgetMin,
    budgetMax,
    areaMin,
    areaMax,
    streetWidthMin,
    streetWidthMax,
    preferredFloors,
    preferredRooms,
    preferredBathrooms,
    preferredLivingrooms,
    preferredFacade,
    services,
    paymentMethod,
    contactPhone,
    allowComments,
    allowMarketingOffers,
    allowNegotiation,
    notes,
    submitting,
    success,
    error,
  ];
}