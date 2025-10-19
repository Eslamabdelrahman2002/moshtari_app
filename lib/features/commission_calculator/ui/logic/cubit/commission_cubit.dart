import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/commission_repo.dart';
import 'commission_state.dart';

class CommissionCubit extends Cubit<CommissionState> {
  final CommissionRepo _repo;
  CommissionCubit(this._repo) : super(const CommissionState());

  // تحويل تصنيف API إلى نص عربي
  String labelFor(String key) {
    switch (key) {
      case 'cars':
        return 'سيارات';
      case 'real_estate':
        return 'عقارات';
      case 'spare_cars':
        return 'قطع غيار سيارات';
      case 'other':
      default:
        return 'أخرى';
    }
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.fetchAll();
      emit(state.copyWith(loading: false, items: list, selectedIndex: 0));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void selectCategory(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  double get selectedPercentage {
    if (state.items.isEmpty) return 0.0;
    if (state.selectedIndex == 0) {
      // "الكل" => خذ أعلى نسبة كافتراضي
      final maxP = state.items.map((e) => e.percentage).fold<double>(0.0, (a, b) => a > b ? a : b);
      return maxP;
    }
    final i = state.selectedIndex - 1;
    if (i < 0 || i >= state.items.length) return 0.0;
    return state.items[i].percentage;
  }

  void calculate(double price) {
    final res = price * (selectedPercentage / 100.0);
    emit(state.copyWith(result: res, inputPrice: price));
  }
}