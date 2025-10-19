class UserRateModel {
  final String? userId;
  final String? rate;
  final String? comment;

  UserRateModel({
    this.userId,
    this.rate,
    this.comment,
  });

  factory UserRateModel.fromMap(Map<String, dynamic> map) {
    return UserRateModel(
      userId: map['userId'],
      rate: map['rate'],
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rate': rate,
      'comment': comment,
    };
  }
}
