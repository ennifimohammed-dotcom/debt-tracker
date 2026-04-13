import 'package:flutter/material.dart';

enum DebtDirection { iOwe, theyOwe }
enum DebtStatus    { unpaid, partial, paid }

extension DebtDirectionX on DebtDirection {
  String get label     => this == DebtDirection.iOwe ? 'عليّ' : 'لي';
  String get labelFull => this == DebtDirection.iOwe ? 'دين عليّ' : 'دين لي';
  Color  get color     => this == DebtDirection.iOwe ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
}

extension DebtStatusX on DebtStatus {
  String get label {
    switch (this) {
      case DebtStatus.unpaid:  return 'غير مدفوع';
      case DebtStatus.partial: return 'مدفوع جزئياً';
      case DebtStatus.paid:    return 'مدفوع بالكامل';
    }
  }
  String get emoji {
    switch (this) {
      case DebtStatus.unpaid:  return '❌';
      case DebtStatus.partial: return '⚠️';
      case DebtStatus.paid:    return '✅';
    }
  }
  Color get color {
    switch (this) {
      case DebtStatus.unpaid:  return const Color(0xFFE53935);
      case DebtStatus.partial: return const Color(0xFFFB8C00);
      case DebtStatus.paid:    return const Color(0xFF2E7D32);
    }
  }
  Color get bg {
    switch (this) {
      case DebtStatus.unpaid:  return const Color(0xFFFFEBEE);
      case DebtStatus.partial: return const Color(0xFFFFF8E1);
      case DebtStatus.paid:    return const Color(0xFFE8F5E9);
    }
  }
}

class Debt {
  final int?          id;
  final String        personName;
  final double        amount;
  final double        paidAmount;
  final DateTime      date;
  final String?       notes;
  final DebtDirection direction;

  const Debt({
    this.id, required this.personName, required this.amount,
    this.paidAmount = 0, required this.date, this.notes, required this.direction,
  });

  double get remaining   => amount - paidAmount;
  double get progress    => amount > 0 ? (paidAmount / amount).clamp(0.0, 1.0) : 0.0;
  double get progressPct => progress * 100;

  DebtStatus get status {
    if (paidAmount <= 0)      return DebtStatus.unpaid;
    if (paidAmount >= amount) return DebtStatus.paid;
    return DebtStatus.partial;
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'personName': personName, 'amount': amount,
    'paidAmount': paidAmount, 'date': date.toIso8601String(),
    'notes': notes, 'direction': direction.index,
  };

  factory Debt.fromMap(Map<String, dynamic> m) => Debt(
    id: m['id'] as int?,
    personName: m['personName'] as String,
    amount: (m['amount'] as num).toDouble(),
    paidAmount: (m['paidAmount'] as num? ?? 0).toDouble(),
    date: DateTime.parse(m['date'] as String),
    notes: m['notes'] as String?,
    direction: DebtDirection.values[m['direction'] as int? ?? 0],
  );

  Debt copyWith({int? id, String? personName, double? amount, double? paidAmount,
      DateTime? date, String? notes, DebtDirection? direction}) => Debt(
    id: id ?? this.id, personName: personName ?? this.personName,
    amount: amount ?? this.amount, paidAmount: paidAmount ?? this.paidAmount,
    date: date ?? this.date, notes: notes ?? this.notes,
    direction: direction ?? this.direction,
  );
}
