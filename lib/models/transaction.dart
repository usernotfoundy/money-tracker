enum TransactionType { income, expense, transfer, payment }

class Transaction {
  final String id;
  final TransactionType type;
  final DateTime dateTime;
  final double amount;
  final String category;
  final String accountId;
  final String? toAccountId; // For transfers
  final String note;
  final String description;
  final String? imagePath;
  final double fees; // Transfer fees

  Transaction({
    required this.id,
    required this.type,
    required this.dateTime,
    required this.amount,
    required this.category,
    required this.accountId,
    this.toAccountId,
    this.note = '',
    this.description = '',
    this.imagePath,
    this.fees = 0.0,
  });

  // Total amount deducted from source (amount + fees)
  double get totalDeducted => amount + fees;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    DateTime? dateTime,
    double? amount,
    String? category,
    String? accountId,
    String? toAccountId,
    String? note,
    String? description,
    String? imagePath,
    double? fees,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      note: note ?? this.note,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      fees: fees ?? this.fees,
    );
  }

  // Convert Transaction to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'dateTime': dateTime.toIso8601String(),
      'amount': amount,
      'category': category,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'note': note,
      'description': description,
      'imagePath': imagePath,
      'fees': fees,
    };
  }

  // Create Transaction from JSON Map
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values[json['type'] as int],
      dateTime: DateTime.parse(json['dateTime'] as String),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      note: json['note'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
