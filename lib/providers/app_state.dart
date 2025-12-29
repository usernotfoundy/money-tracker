import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class AppState extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  List<Account> _accounts = [
    Account(
      id: '1',
      name: 'Cash',
      balance: 0.0,
      icon: Icons.money,
      color: Colors.green,
      type: AccountType.asset,
    ),
    Account(
      id: '2',
      name: 'Bank Account',
      balance: 0.0,
      icon: Icons.account_balance,
      color: Colors.blue,
      type: AccountType.asset,
    ),
  ];

  List<Transaction> _transactions = [];

  // All accounts
  List<Account> get accounts => _accounts;
  
  // Open accounts only
  List<Account> get openAccounts => _accounts.where((a) => a.isOpen).toList();
  List<Account> get openAssetAccounts => _accounts.where((a) => a.isAsset && a.isOpen).toList();
  List<Account> get openLiabilityAccounts => _accounts.where((a) => a.isLiability && a.isOpen).toList();
  
  // Closed accounts
  List<Account> get closedAccounts => _accounts.where((a) => a.isClosed).toList();
  List<Account> get closedAssetAccounts => _accounts.where((a) => a.isAsset && a.isClosed).toList();
  List<Account> get closedLiabilityAccounts => _accounts.where((a) => a.isLiability && a.isClosed).toList();
  
  // Legacy getters (for backward compatibility)
  List<Account> get assetAccounts => openAssetAccounts;
  List<Account> get liabilityAccounts => openLiabilityAccounts;
  
  List<Transaction> get transactions => _transactions;

  // Category icons map
  final Map<String, IconData> _categoryIcons = {
    // Income
    'Salary': Icons.work,
    'Freelance': Icons.computer,
    'Investment': Icons.trending_up,
    'Gift': Icons.card_giftcard,
    'Refund': Icons.replay,
    // Expense
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills & Utilities': Icons.receipt_long,
    'Healthcare': Icons.medical_services,
    'Education': Icons.school,
    'Travel': Icons.flight,
    // Transfer
    'Account Transfer': Icons.swap_horiz,
    'Savings': Icons.savings,
    'Investment Transfer': Icons.show_chart,
    'Emergency Fund': Icons.shield,
    // Payment
    'Credit Card Payment': Icons.credit_card,
    'Loan Payment': Icons.account_balance,
    'Debt Payment': Icons.money_off,
    'Mortgage Payment': Icons.home,
    // Default
    'Other': Icons.more_horiz,
  };

  // Income categories
  List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Refund',
    'Other',
  ];

  // Expense categories
  List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Other',
  ];

  // Transfer categories
  List<String> _transferCategories = [
    'Account Transfer',
    'Savings',
    'Investment Transfer',
    'Emergency Fund',
    'Other',
  ];

  // Payment categories (for paying liabilities)
  List<String> _paymentCategories = [
    'Credit Card Payment',
    'Loan Payment',
    'Debt Payment',
    'Mortgage Payment',
    'Other',
  ];

  List<String> get incomeCategories => _incomeCategories;
  List<String> get expenseCategories => _expenseCategories;
  List<String> get transferCategories => _transferCategories;
  List<String> get paymentCategories => _paymentCategories;

  IconData getCategoryIcon(String category) {
    return _categoryIcons[category] ?? Icons.category;
  }

  void setCategoryIcon(String category, IconData icon) {
    _categoryIcons[category] = icon;
    notifyListeners();
  }

  void addIncomeCategory(String category, {IconData? icon}) {
    if (!_incomeCategories.contains(category)) {
      _incomeCategories.add(category);
      if (icon != null) {
        _categoryIcons[category] = icon;
      }
      notifyListeners();
    }
  }

  void removeIncomeCategory(String category) {
    _incomeCategories.remove(category);
    _categoryIcons.remove(category);
    notifyListeners();
  }

  void addExpenseCategory(String category, {IconData? icon}) {
    if (!_expenseCategories.contains(category)) {
      _expenseCategories.add(category);
      if (icon != null) {
        _categoryIcons[category] = icon;
      }
      notifyListeners();
    }
  }

  void removeExpenseCategory(String category) {
    _expenseCategories.remove(category);
    _categoryIcons.remove(category);
    notifyListeners();
  }

  void addTransferCategory(String category, {IconData? icon}) {
    if (!_transferCategories.contains(category)) {
      _transferCategories.add(category);
      if (icon != null) {
        _categoryIcons[category] = icon;
      }
      notifyListeners();
    }
  }

  void removeTransferCategory(String category) {
    _transferCategories.remove(category);
    _categoryIcons.remove(category);
    notifyListeners();
  }

  void addPaymentCategory(String category, {IconData? icon}) {
    if (!_paymentCategories.contains(category)) {
      _paymentCategories.add(category);
      if (icon != null) {
        _categoryIcons[category] = icon;
      }
      notifyListeners();
    }
  }

  void removePaymentCategory(String category) {
    _paymentCategories.remove(category);
    _categoryIcons.remove(category);
    notifyListeners();
  }

  bool isCategoryInUse(String category) {
    return _transactions.any((t) => t.category == category);
  }

  double get totalAssets {
    return openAssetAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get totalLiabilities {
    return openLiabilityAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get netWorth {
    return totalAssets - totalLiabilities;
  }

  double get totalBalance {
    return openAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void addAccount(String name, IconData icon, Color color, {double initialBalance = 0.0, AccountType type = AccountType.asset}) {
    final account = Account(
      id: _uuid.v4(),
      name: name,
      balance: initialBalance,
      icon: icon,
      color: color,
      type: type,
    );
    _accounts.add(account);
    notifyListeners();
  }

  void updateAccountBalance(String accountId, double amount) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      final newBalance = _accounts[index].balance + amount;
      _accounts[index] = _accounts[index].copyWith(
        balance: newBalance,
      );
      
      // Auto-close liability accounts when balance reaches zero
      if (_accounts[index].isLiability && newBalance <= 0 && !_accounts[index].isClosed) {
        _accounts[index] = _accounts[index].copyWith(
          balance: 0.0, // Ensure it's exactly 0
          isClosed: true,
        );
      }
      
      notifyListeners();
    }
  }

  void closeAccount(String accountId) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(isClosed: true);
      notifyListeners();
    }
  }

  void reopenAccount(String accountId) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(isClosed: false);
      notifyListeners();
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    
    // Update account balances
    if (transaction.type == TransactionType.income) {
      updateAccountBalance(transaction.accountId, transaction.amount);
    } else if (transaction.type == TransactionType.expense) {
      updateAccountBalance(transaction.accountId, -transaction.amount);
    } else if (transaction.type == TransactionType.transfer) {
      // Deduct amount + fees from source account
      updateAccountBalance(transaction.accountId, -transaction.totalDeducted);
      if (transaction.toAccountId != null) {
        // Add only the amount to destination (fees are lost)
        updateAccountBalance(transaction.toAccountId!, transaction.amount);
      }
    } else if (transaction.type == TransactionType.payment) {
      // Payment: deduct from asset account, reduce liability balance
      updateAccountBalance(transaction.accountId, -transaction.amount);
      if (transaction.toAccountId != null) {
        updateAccountBalance(transaction.toAccountId!, -transaction.amount);
      }
    }
  }

  void deleteTransaction(String id) {
    final transaction = _transactions.firstWhere((t) => t.id == id);
    
    // Reverse the balance changes
    if (transaction.type == TransactionType.income) {
      updateAccountBalance(transaction.accountId, -transaction.amount);
    } else if (transaction.type == TransactionType.expense) {
      updateAccountBalance(transaction.accountId, transaction.amount);
    } else if (transaction.type == TransactionType.transfer) {
      // Restore amount + fees to source account
      updateAccountBalance(transaction.accountId, transaction.totalDeducted);
      if (transaction.toAccountId != null) {
        // Remove amount from destination
        updateAccountBalance(transaction.toAccountId!, -transaction.amount);
      }
    } else if (transaction.type == TransactionType.payment) {
      // Reverse payment: restore asset, restore liability
      updateAccountBalance(transaction.accountId, transaction.amount);
      if (transaction.toAccountId != null) {
        updateAccountBalance(transaction.toAccountId!, transaction.amount);
      }
    }
    
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void deleteAccount(String id) {
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  bool hasTransactions(String accountId) {
    return _transactions.any((t) => 
      t.accountId == accountId || t.toAccountId == accountId
    );
  }

  int getTransactionCount(String accountId) {
    return _transactions.where((t) => 
      t.accountId == accountId || t.toAccountId == accountId
    ).length;
  }
}
