import 'package:equatable/equatable.dart';
import '../../../data/model/commission_models.dart';

class CommissionState extends Equatable {
  final bool loading;
  final String? error;
  final List<CommissionItem> items;
  final int selectedIndex; // 0 => "الكل", 1..N => items[index-1]
  final double result; // آخر نتيجة حساب
  final double inputPrice; // آخر سعر أدخله المستخدم

  const CommissionState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.selectedIndex = 0,
    this.result = 0.0,
    this.inputPrice = 0.0,
  });

  CommissionState copyWith({
    bool? loading,
    String? error,
    List<CommissionItem>? items,
    int? selectedIndex,
    double? result,
    double? inputPrice,
  }) {
    return CommissionState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      result: result ?? this.result,
      inputPrice: inputPrice ?? this.inputPrice,
    );
  }

  @override
  List<Object?> get props => [loading, error, items, selectedIndex, result, inputPrice];
}