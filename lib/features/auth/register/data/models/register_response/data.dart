import 'fcm_tokens.dart';
import 'last_login_details.dart';
import 'notification_manager.dart';

class Data {
  String? id;
  String? name;
  String? email;
  String? notVerifiedPhone;
  String? password;
  String? role;
  FcmTokens? fcmTokens;
  LastLoginDetails? lastLoginDetails;
  dynamic verifiedPhone;
  dynamic location;
  dynamic profilePicture;
  dynamic securityGroupId;
  dynamic token;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? gender;
  bool? isBlocked;
  bool? hasCompletedRegistration;
  NotificationManager? notificationManager;

  Data({
    this.id,
    this.name,
    this.email,
    this.notVerifiedPhone,
    this.password,
    this.role,
    this.fcmTokens,
    this.lastLoginDetails,
    this.verifiedPhone,
    this.location,
    this.profilePicture,
    this.securityGroupId,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.gender,
    this.isBlocked,
    this.hasCompletedRegistration,
    this.notificationManager,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json['id'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        notVerifiedPhone: json['notVerifiedPhone'] as String?,
        password: json['password'] as String?,
        role: json['role'] as String?,
        fcmTokens: json['fcmTokens'] == null
            ? null
            : FcmTokens.fromJson(json['fcmTokens'] as Map<String, dynamic>),
        lastLoginDetails: json['lastLoginDetails'] == null
            ? null
            : LastLoginDetails.fromJson(
                json['lastLoginDetails'] as Map<String, dynamic>),
        verifiedPhone: json['verifiedPhone'] as dynamic,
        location: json['location'] as dynamic,
        profilePicture: json['profilePicture'] as dynamic,
        securityGroupId: json['securityGroupId'] as dynamic,
        token: json['token'] as dynamic,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] as dynamic,
        gender: json['gender'] as String?,
        isBlocked: json['isBlocked'] as bool?,
        hasCompletedRegistration: json['hasCompletedRegistration'] as bool?,
        notificationManager: json['notificationManager'] == null
            ? null
            : NotificationManager.fromJson(
                json['notificationManager'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'notVerifiedPhone': notVerifiedPhone,
        'password': password,
        'role': role,
        'fcmTokens': fcmTokens?.toJson(),
        'lastLoginDetails': lastLoginDetails?.toJson(),
        'verifiedPhone': verifiedPhone,
        'location': location,
        'profilePicture': profilePicture,
        'securityGroupId': securityGroupId,
        'token': token,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'deletedAt': deletedAt,
        'gender': gender,
        'isBlocked': isBlocked,
        'hasCompletedRegistration': hasCompletedRegistration,
        'notificationManager': notificationManager?.toJson(),
      };
}
