class LaborerType {
  final int id;
  final String nameAr;
  final String nameEn;

  LaborerType({required this.id, required this.nameAr, required this.nameEn});

  factory LaborerType.fromJson(Map<String, dynamic> j) => LaborerType(
    id: (j['id'] as int?) ?? 0, // default if null
    nameAr: (j['name_ar'] ?? '').toString(),
    nameEn: (j['name_en'] ?? '').toString(),
  );
}