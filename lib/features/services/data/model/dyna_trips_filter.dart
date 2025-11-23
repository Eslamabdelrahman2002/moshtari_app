class DynaTripsFilter {
  final int? fromCityId;
  final int? toCityId;
  final int? dynaCapacity; // مثال: صغير=10، وسط=15، كبير=20 (اضبطها حسب الباك)
  final DateTime? date;    // سنرسل YYYY-MM-DD
  final int? regionId;     // اختياري

  const DynaTripsFilter({
    this.fromCityId,
    this.toCityId,
    this.dynaCapacity,
    this.date,
    this.regionId,
  });

  bool get isEmpty =>
      fromCityId == null &&
          toCityId == null &&
          dynaCapacity == null &&
          date == null &&
          regionId == null;

  DynaTripsFilter copyWith({
    int? fromCityId,
    int? toCityId,
    int? dynaCapacity,
    DateTime? date,
    int? regionId,
    bool clearFromCity = false,
    bool clearToCity = false,
    bool clearCapacity = false,
    bool clearDate = false,
    bool clearRegion = false,
  }) {
    return DynaTripsFilter(
      fromCityId: clearFromCity ? null : (fromCityId ?? this.fromCityId),
      toCityId: clearToCity ? null : (toCityId ?? this.toCityId),
      dynaCapacity: clearCapacity ? null : (dynaCapacity ?? this.dynaCapacity),
      date: clearDate ? null : (date ?? this.date),
      regionId: clearRegion ? null : (regionId ?? this.regionId),
    );
  }

  Map<String, dynamic> toQuery() {
    String? _fmtDate(DateTime? d) {
      if (d == null) return null;
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day'; // YYYY-MM-DD
    }

    final q = <String, dynamic>{
      if (fromCityId != null) 'from_city_id': fromCityId,
      if (toCityId != null) 'to_city_id': toCityId,
      if (dynaCapacity != null) 'dyna_capacity': dynaCapacity,
      if (regionId != null) 'region_id': regionId,
      if (_fmtDate(date) != null) 'date': _fmtDate(date),
    };
    return q;
  }
}