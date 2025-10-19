import 'package:mushtary/core/location/data/model/location_models.dart';

class LocationState {
  final bool regionsLoading;
  final List<Region> regions;
  final String? regionsError;

  final bool citiesLoading;
  final List<City> cities;
  final String? citiesError;

  const LocationState({
    this.regionsLoading = false,
    this.regions = const [],
    this.regionsError,
    this.citiesLoading = false,
    this.cities = const [],
    this.citiesError,
  });

  LocationState copyWith({
    bool? regionsLoading,
    List<Region>? regions,
    String? regionsError,
    bool? citiesLoading,
    List<City>? cities,
    String? citiesError,
  }) {
    return LocationState(
      regionsLoading: regionsLoading ?? this.regionsLoading,
      regions: regions ?? this.regions,
      regionsError: regionsError,
      citiesLoading: citiesLoading ?? this.citiesLoading,
      cities: cities ?? this.cities,
      citiesError: citiesError,
    );
  }
}