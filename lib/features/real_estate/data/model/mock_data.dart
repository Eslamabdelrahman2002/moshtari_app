// lib/features/real_estate/data/model/mock_data.dart

import 'package:flutter/material.dart';
import 'package:mushtary/core/utils/enums.dart';
import 'package:mushtary/features/auth/login/data/models/user_model.dart';
import 'package:mushtary/features/home/data/models/auctions/auctions_model.dart';
import 'package:mushtary/features/home/data/models/auctions/bargains_model.dart';
import 'package:mushtary/features/home/data/models/auctions/car_model.dart';

/// -------------------- PROPERTY MODEL --------------------
class PropertyItemDetailsModel {
  final String? title, userName, createdAt, windDirection, description;
  final num? price;
  final double? area, streetWidth;
  final int? bedrooms, bathrooms, numberOfStreetFrontages;
  final List<String>? imagesUrl;
  final List<int>? cityId, areaId;

  PropertyItemDetailsModel({
    this.title,
    this.userName,
    this.price,
    this.createdAt,
    this.area,
    this.bedrooms,
    this.bathrooms,
    this.imagesUrl,
    this.cityId,
    this.areaId,
    this.numberOfStreetFrontages,
    this.streetWidth,
    this.windDirection,
    this.description,
  });
}

/// -------------------- APPLICATION MODEL --------------------
class RealStateApplicationsDetailsModel {
  final String? title;
  final String? location;
  final String? lowestPrice;
  final String? highestPrice;
  final String? lowestArea;
  final String? highestArea;
  final DateTime? createdAt;
  final RealStateUserTypes? propertyUserType;
  final RealStateApplicationType? applicationType;
  final double? streetWidth;
  final int? numberOfFloors;
  final int? orderNumber;
  final RealStatePaymentType? paymentMethod;
  final String? description;

  RealStateApplicationsDetailsModel({
    this.title,
    this.location,
    this.createdAt,
    this.propertyUserType,
    this.applicationType,
    this.lowestPrice,
    this.highestPrice,
    this.lowestArea,
    this.highestArea,
    this.streetWidth,
    this.numberOfFloors,
    this.orderNumber,
    this.paymentMethod,
    this.description,
  });
}

/// بيانات وهمية لطلبات العقارات
final List<RealStateApplicationsDetailsModel> mockApplications = [
  RealStateApplicationsDetailsModel(
    title: "مطلوب شقة سكنية ٣ غرف",
    location: "حي النرجس، الرياض",
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    propertyUserType: RealStateUserTypes.buyer,
    applicationType: RealStateApplicationType.residential,
    lowestPrice: "800,000",
    highestPrice: "1,200,000",
    lowestArea: "150",
    highestArea: "200",
    paymentMethod: RealStatePaymentType.installments,
    description:
    "أبحث عن شقة مناسبة لعائلة صغيرة مع مواقف سيارات وقريبة من المدارس.",
  ),
];

/// -------------------- PROPERTIES MOCK --------------------
final List<PropertyItemDetailsModel> mockProperties = [
  PropertyItemDetailsModel(
    title: "فيلا راقية للبيع",
    userName: "محمد علي",
    price: 2500000,
    createdAt: "2025-09-24",
    area: 350.0,
    bedrooms: 5,
    bathrooms: 4,
    numberOfStreetFrontages: 2,
    streetWidth: 20.0,
    windDirection: "شمال",
    description: "فيلا فاخرة بحي الياسمين مع حديقة ومسبح خاص.",
    imagesUrl: [
      "https://example.com/villa1.jpg",
      "https://example.com/villa2.jpg",
    ],
    cityId: [1],
    areaId: [10],
  ),
  PropertyItemDetailsModel(
    title: "شقة سكنية مميزة",
    userName: "أحمد حسن",
    price: 900000,
    createdAt: "2025-09-20",
    area: 150.0,
    bedrooms: 3,
    bathrooms: 2,
    numberOfStreetFrontages: 1,
    streetWidth: 10.0,
    windDirection: "جنوب",
    description: "شقة عائلية قريبة من المدارس والخدمات.",
    imagesUrl: [
      "https://example.com/apt1.jpg",
      "https://example.com/apt2.jpg",
    ],
    cityId: [1],
    areaId: [12],
  ),
];

/// -------------------- CATEGORY MODEL --------------------
class CategoryModel {
  final int id;
  final String name;
  final String icon;

  CategoryModel({required this.id, required this.name, required this.icon});
}

final mockCategories = [
  CategoryModel(id: 1, name: "عقارات", icon: "home"),
  CategoryModel(id: 2, name: "سيارات", icon: "car"),
];

/// -------------------- MOCK AUCTIONS --------------------
// final List<AuctionsModel> mockAuctions = [
//   AuctionsModel(
//     documentRef: "auction_1",
//     car: CarModel(
//       images: [
//         "https://example.com/toyota1.jpg",
//         "https://example.com/toyota2.jpg",
//       ],
//       status: "Used",
//       brand: "Toyota",
//       model: "Corolla",
//       gearType: "Automatic",
//       fuelType: "Petrol",
//       kilometers: "35000",
//       cylinderCount: "4",
//       color: "White",
//       wheelDriveType: "FWD",
//       year: 2020,
//       engineCapacity: "1600cc",
//     ),
//     title: "Toyota Corolla 2020 - Like New",
//     location: "Cairo, Egypt",
//     description: "Well-maintained Corolla with low mileage and service history.",
//     categoryId: "cars",
//     userId: "user_123",
//     price: "250000",
//     bargain: [
//       BargainsModel(
//         userId: "buyer_1",
//         price: 240000,
//         comment: "Cash payment, ready today.",
//         createdAt: DateTime.now().subtract(const Duration(hours: 5)),
//         updatedAt: DateTime.now(),
//       ),
//       BargainsModel(
//         userId: "buyer_2",
//         price: 245000,
//         comment: "Final offer, please confirm.",
//         createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//         updatedAt: DateTime.now(),
//       ),
//     ],
//     createdAt: DateTime.now().subtract(const Duration(days: 1)),
//     updatedAt: DateTime.now(),
//   ),
//   AuctionsModel(
//     documentRef: "auction_2",
//     car: CarModel(
//       images: [
//         "https://example.com/bmw1.jpg",
//         "https://example.com/bmw2.jpg",
//       ],
//       status: "New",
//       brand: "BMW",
//       model: "X5",
//       gearType: "Automatic",
//       fuelType: "Diesel",
//       kilometers: "0",
//       cylinderCount: "6",
//       color: "Black",
//       wheelDriveType: "AWD",
//       year: 2022,
//       engineCapacity: "3000cc",
//     ),
//     title: "BMW X5 2022 - Brand New",
//     location: "Alexandria, Egypt",
//     description: "Luxury BMW X5 with premium package, full option.",
//     categoryId: "cars",
//     userId: "user_456",
//     price: "2500000",
//     bargain: [
//       BargainsModel(
//         userId: "buyer_3",
//         price: 2400000,
//         comment: "Looking for slight discount.",
//         createdAt: DateTime.now().subtract(const Duration(hours: 8)),
//         updatedAt: DateTime.now(),
//       ),
//     ],
//     createdAt: DateTime.now().subtract(const Duration(days: 2)),
//     updatedAt: DateTime.now(),
//   ),
// ];

/// -------------------- MOCK MESSAGES --------------------
class MessagesModel {
  final String senderUserId;
  final String receiverUserId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final UserModel partnerUser;

  MessagesModel({
    required this.senderUserId,
    required this.receiverUserId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.partnerUser,
  });
}

final List<MessagesModel> mockMessages = [
  MessagesModel(
    senderUserId: "user_1",
    receiverUserId: "user_2",
    lastMessage: "السلام عليكم، هل العقار مازال متاح؟",
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    partnerUser: UserModel(
      documentRef: "user_2",
      name: "أحمد محمد",
      email: "ahmed@example.com",
    ),
  ),
  MessagesModel(
    senderUserId: "user_2",
    receiverUserId: "user_1",
    lastMessage: "وعليكم السلام، نعم مازال متاح.",
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
    partnerUser: UserModel(
      documentRef: "user_1",
      name: "مالك العقار",
      email: "owner@example.com",
    ),
  ),
];
