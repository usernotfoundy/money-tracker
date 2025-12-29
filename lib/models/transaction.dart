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
  });

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
    );
  }
}


