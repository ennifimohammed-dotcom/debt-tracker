class Payment {
  final int? id;
  final int debtId;
  final double amount;
  final String date;
  final String note;

  Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debt_id': debtId,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }
}
