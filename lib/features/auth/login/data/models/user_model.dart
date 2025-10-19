import 'package:mushtary/core/models/base_model.dart';
import 'package:mushtary/features/auth/login/data/models/user_rate_model.dart';

class UserModel extends BaseModel {
  String? email;
  String? name;
  String? phoneNumber;
  String? referralCode;
  bool? isVerified;
  String? profileImage;
  List<UserRateModel>? userRateList;
  int? projectCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    super.documentRef,
    this.email,
    this.name,
    this.phoneNumber,
    this.referralCode,
    this.isVerified,
    this.profileImage,
    this.userRateList,
    this.projectCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory من Map (Mock JSON أو Mock Data)
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      referralCode: map['referralCode'] ?? '',
      isVerified: map['isVerified'] ?? false,
      profileImage: map['profileImage'] ?? '',
      userRateList: (map['userRateList'] as List<dynamic>?)
          ?.map((x) => UserRateModel.fromMap(x))
          .toList() ??
          [],
      projectCount: map['projectCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'email': email,
    'name': name,
    'phoneNumber': phoneNumber,
    'referralCode': referralCode,
    'isVerified': isVerified,
    'profileImage': profileImage,
    'userRateList': userRateList?.map((x) => x.toMap()).toList(),
    'projectCount': projectCount,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
