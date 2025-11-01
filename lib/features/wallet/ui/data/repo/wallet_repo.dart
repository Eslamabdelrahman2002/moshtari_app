import 'package:mushtary/core/api/api_service.dart' as core;
import 'package:mushtary/features/wallet/data/transaction_model.dart';

class WalletRepo {
  final core.ApiService _api;

  WalletRepo(this._api);

  // Mock - استبدل بـ real API calls
  Future<double> getBalance() async {
    // TODO: استدعِ API حقيقي مثل _api.get('/wallet/balance')
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    return 415.38; // mock balance
  }

  Future<List<TransactionModel>> getTransactions() async {
    // TODO: استدعِ API حقيقي مثل _api.get('/wallet/transactions')
    await Future.delayed(const Duration(seconds: 1));
    return [
      TransactionModel(title: 'شحن للحفظة', date: '20/04/2024', amount: 350, type: TransactionType.deposit),
      TransactionModel(title: 'كسب عن طريق التطبيق', date: '20/04/2024', amount: -150, type: TransactionType.withdrawal),
      // أضف المزيد...
    ];
  }
}