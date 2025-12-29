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
}
