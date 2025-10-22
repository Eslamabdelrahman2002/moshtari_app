import 'package:equatable/equatable.dart';
import '../../../data/model/promoter_profile_models.dart';

class PromoterProfileState extends Equatable {
  final bool loading;
  final String? error;
  final PromoterProfileResponse? data; // نتعامل في الـ UI مع الـ Response مباشرة

  const PromoterProfileState({
    this.loading = false,
    this.error,
    this.data,
  });

  // أضفنا clearError/clearData عشان تقدر تصفّر القيم عمداً
  PromoterProfileState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    PromoterProfileResponse? data,
    bool clearData = false,
  }) {
    return PromoterProfileState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      data: clearData ? null : (data ?? this.data),
    );
  }

  @override
  List<Object?> get props => [loading, error, data];
}