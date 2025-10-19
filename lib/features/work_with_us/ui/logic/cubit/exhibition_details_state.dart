import 'package:equatable/equatable.dart';
import '../../../data/model/exhibition_details_models.dart';


class ExhibitionDetailsState extends Equatable {
  final bool loading;
  final ExhibitionDetailsData? data;
  final String? error;

  const ExhibitionDetailsState({this.loading = false, this.data, this.error});

  ExhibitionDetailsState copyWith({
    bool? loading,
    ExhibitionDetailsData? data,
    String? error,
  }) {
    return ExhibitionDetailsState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, data, error];
}