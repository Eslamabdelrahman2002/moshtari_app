class Region {
  final int id;
  final String nameAr;
  final String nameEn;

  Region({required this.id, required this.nameAr, required this.nameEn});

  factory Region.fromJson(Map<String, dynamic> j) => Region(
    id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
    nameAr: (j['name_ar'] ?? j['nameAr'] ?? '').toString(),
    nameEn: (j['name_en'] ?? j['nameEn'] ?? '').toString(),
  );

  static List<Region> parseList(dynamic json) {
    final list = <Region>[];
    if (json is List) {
      for (final e in json) list.add(Region.fromJson(e));
    } else if (json is Map && json['data'] is List) {
      for (final e in (json['data'] as List)) list.add(Region.fromJson(e));
    }
    return list;
  }
}

class City {
  final int id;
  final String nameAr;
  final String nameEn;
  final int regionId;

  City({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.regionId,
  });

  factory City.fromJson(Map<String, dynamic> j) => City(
    id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
    nameAr: (j['name_ar'] ?? j['nameAr'] ?? '').toString(),
    nameEn: (j['name_en'] ?? j['nameEn'] ?? '').toString(),
    regionId: j['region_id'] is int
        ? j['region_id'] as int
        : int.tryParse('${j['region_id']}') ?? 0,
  );

  static List<City> parseList(dynamic json) {
    final list = <City>[];
    if (json is List) {
      for (final e in json) list.add(City.fromJson(e));
    } else if (json is Map && json['data'] is List) {
      for (final e in (json['data'] as List)) list.add(City.fromJson(e));
    }
    return list;
  }
}