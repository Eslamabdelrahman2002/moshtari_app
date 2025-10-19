enum EarningCategory { all, partners, referral, services }

class EarningModel {
  final String title;
  final String date;
  final double amount;
  final EarningCategory category;

  EarningModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
  });
}