import 'package:flutter/material.dart';

enum AccountType { asset, liability }

class Account {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final Color color;
  final AccountType type;
  final bool isClosed;

  Account({
    required this.id,
    required this.name,
    this.balance = 0.0,
    this.icon = Icons.account_balance_wallet,
    this.color = Colors.teal,
    this.type = AccountType.asset,
    this.isClosed = false,
  });

  bool get isAsset => type == AccountType.asset;
  bool get isLiability => type == AccountType.liability;
  bool get isOpen => !isClosed;

  Account copyWith({
    String? id,
    String? name,
    double? balance,
    IconData? icon,
    Color? color,
    AccountType? type,
    bool? isClosed,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  // Convert Account to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'colorValue': color.value,
      'type': type.index,
      'isClosed': isClosed,
    };
  }

  // Create Account from JSON Map
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontFamily'] == 'MaterialIcons' ? null : null,
      ),
      color: Color(json['colorValue'] as int),
      type: AccountType.values[json['type'] as int],
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}
