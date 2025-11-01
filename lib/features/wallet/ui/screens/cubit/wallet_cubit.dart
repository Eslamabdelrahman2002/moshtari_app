import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/transaction_model.dart';
import '../../data/repo/wallet_repo.dart';
// افترض موجود

class WalletCubit extends Cubit<WalletState> {
  final WalletRepo _repo;
  WalletCubit(this._repo) : super(WalletState.initial()) {
    refresh(); // تحميل أولي
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true));
    try {
      final balance = await _repo.getBalance();
      final transactions = await _repo.getTransactions();
      emit(WalletState(
        balance: balance,
        transactions: transactions,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}

class WalletState {
  final double? balance;
  final List<TransactionModel>? transactions;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.balance,
    this.transactions,
    this.isLoading = false,
    this.error,
  });

  factory WalletState.initial() => const WalletState(
    balance: 0.0,
    transactions: [],
  );

  WalletState copyWith({
    double? balance,
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}