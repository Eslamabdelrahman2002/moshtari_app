class BaseModel {
  late String? documentRef;

  BaseModel({this.documentRef});

  BaseModel.fromJson(Map<String, dynamic> map) {
    documentRef = map['documentRef'];
  }

  Map<String, Object?> toJson() => {
        'documentRef': documentRef,
      };
}
