import 'package:equatable/equatable.dart';
import 'package:mushtary/features/work_with_us/data/model/exhibitions_list_models.dart';

class ExhibitionsState extends Equatable {
  final bool loading;
  final List<ExhibitionItem> items;
  final String? error;

  const ExhibitionsState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  ExhibitionsState copyWith({
    bool? loading,
    List<ExhibitionItem>? items,
    String? error,
  }) {
    return ExhibitionsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, items, error];
}