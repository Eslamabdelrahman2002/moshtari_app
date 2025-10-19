enum TransactionType { deposit, withdrawal, fee }

class TransactionModel {
  final String title;
  final String date;
  final double amount;
  final TransactionType type;
  final String? transactionId;

  TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    this.transactionId,
  });
}