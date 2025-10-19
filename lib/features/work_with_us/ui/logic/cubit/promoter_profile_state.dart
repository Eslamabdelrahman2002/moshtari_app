import 'package:equatable/equatable.dart';
import '../../../data/model/promoter_profile_models.dart';

class PromoterProfileState extends Equatable {
  final bool loading;
  final PromoterProfileData? data;
  final String? error;

  const PromoterProfileState({
    this.loading = false,
    this.data,
    this.error,
  });

  PromoterProfileState copyWith({
    bool? loading,
    PromoterProfileData? data,
    String? error,
  }) {
    return PromoterProfileState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, data, error];
}