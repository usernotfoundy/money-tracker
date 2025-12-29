import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class AppState extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  bool _isLoaded = false;
  
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];

  // Storage keys
  static const String _accountsKey = 'accounts_data';
  static const String _transactionsKey = 'transactions_data';
  static const String _incomeCategoriesKey = 'income_categories';
  static const String _expenseCategoriesKey = 'expense_categories';
  static const String _transferCategoriesKey = 'transfer_categories';
  static const String _paymentCategoriesKey = 'payment_categories';
  static const String _categoryIconsKey = 'category_icons';

  // Constructor - load data on initialization
  AppState() {
    _loadAllData();
  }

  bool get isLoaded => _isLoaded;

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
  Map<String, int> _categoryIconCodes = {
    // Income
    'Salary': Icons.work.codePoint,
    'Freelance': Icons.computer.codePoint,
    'Investment': Icons.trending_up.codePoint,
    'Gift': Icons.card_giftcard.codePoint,
    'Refund': Icons.replay.codePoint,
    // Expense
    'Food & Dining': Icons.restaurant.codePoint,
    'Transportation': Icons.directions_car.codePoint,
    'Shopping': Icons.shopping_bag.codePoint,
    'Entertainment': Icons.movie.codePoint,
    'Bills & Utilities': Icons.receipt_long.codePoint,
    'Healthcare': Icons.medical_services.codePoint,
    'Education': Icons.school.codePoint,
    'Travel': Icons.flight.codePoint,
    // Transfer
    'Account Transfer': Icons.swap_horiz.codePoint,
    'Savings': Icons.savings.codePoint,
    'Investment Transfer': Icons.show_chart.codePoint,
    'Emergency Fund': Icons.shield.codePoint,
    // Payment
    'Credit Card Payment': Icons.credit_card.codePoint,
    'Loan Payment': Icons.account_balance.codePoint,
    'Debt Payment': Icons.money_off.codePoint,
    'Mortgage Payment': Icons.home.codePoint,
    // Default
    'Other': Icons.more_horiz.codePoint,
    'Transfer Fees': Icons.money_off.codePoint,
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
    final codePoint = _categoryIconCodes[category];
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    return Icons.category;
  }

  void setCategoryIcon(String category, IconData icon) {
    _categoryIconCodes[category] = icon.codePoint;
    _saveCategoryIcons();
    notifyListeners();
  }

  void addIncomeCategory(String category, {IconData? icon}) {
    if (!_incomeCategories.contains(category)) {
      _incomeCategories.add(category);
      if (icon != null) {
        _categoryIconCodes[category] = icon.codePoint;
      }
      _saveCategories();
      notifyListeners();
    }
  }

  void removeIncomeCategory(String category) {
    _incomeCategories.remove(category);
    _categoryIconCodes.remove(category);
    _saveCategories();
    notifyListeners();
  }

  void addExpenseCategory(String category, {IconData? icon}) {
    if (!_expenseCategories.contains(category)) {
      _expenseCategories.add(category);
      if (icon != null) {
        _categoryIconCodes[category] = icon.codePoint;
      }
      _saveCategories();
      notifyListeners();
    }
  }

  void removeExpenseCategory(String category) {
    _expenseCategories.remove(category);
    _categoryIconCodes.remove(category);
    _saveCategories();
    notifyListeners();
  }

  void addTransferCategory(String category, {IconData? icon}) {
    if (!_transferCategories.contains(category)) {
      _transferCategories.add(category);
      if (icon != null) {
        _categoryIconCodes[category] = icon.codePoint;
      }
      _saveCategories();
      notifyListeners();
    }
  }

  void removeTransferCategory(String category) {
    _transferCategories.remove(category);
    _categoryIconCodes.remove(category);
    _saveCategories();
    notifyListeners();
  }

  void addPaymentCategory(String category, {IconData? icon}) {
    if (!_paymentCategories.contains(category)) {
      _paymentCategories.add(category);
      if (icon != null) {
        _categoryIconCodes[category] = icon.codePoint;
      }
      _saveCategories();
      notifyListeners();
    }
  }

  void removePaymentCategory(String category) {
    _paymentCategories.remove(category);
    _categoryIconCodes.remove(category);
    _saveCategories();
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
    _saveAccounts();
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
      
      _saveAccounts();
      notifyListeners();
    }
  }

  void closeAccount(String accountId) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(isClosed: true);
      _saveAccounts();
      notifyListeners();
    }
  }

  void reopenAccount(String accountId) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(isClosed: false);
      _saveAccounts();
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
    
    _saveTransactions();
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
    _saveTransactions();
    notifyListeners();
  }

  void deleteAccount(String id) {
    _accounts.removeWhere((a) => a.id == id);
    _saveAccounts();
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

  // ============= PERSISTENCE METHODS =============

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load accounts
    final accountsJson = prefs.getString(_accountsKey);
    if (accountsJson != null) {
      final List<dynamic> accountsList = jsonDecode(accountsJson);
      _accounts = accountsList.map((json) => Account.fromJson(json)).toList();
    } else {
      // Default accounts for first time
      _accounts = [
        Account(
          id: _uuid.v4(),
          name: 'Cash',
          balance: 0.0,
          icon: Icons.money,
          color: Colors.green,
          type: AccountType.asset,
        ),
        Account(
          id: _uuid.v4(),
          name: 'Bank Account',
          balance: 0.0,
          icon: Icons.account_balance,
          color: Colors.blue,
          type: AccountType.asset,
        ),
      ];
      _saveAccounts();
    }
    
    // Load transactions
    final transactionsJson = prefs.getString(_transactionsKey);
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      _transactions = transactionsList.map((json) => Transaction.fromJson(json)).toList();
    }
    
    // Load categories
    final incomeJson = prefs.getStringList(_incomeCategoriesKey);
    if (incomeJson != null) {
      _incomeCategories = incomeJson;
    }
    
    final expenseJson = prefs.getStringList(_expenseCategoriesKey);
    if (expenseJson != null) {
      _expenseCategories = expenseJson;
    }
    
    final transferJson = prefs.getStringList(_transferCategoriesKey);
    if (transferJson != null) {
      _transferCategories = transferJson;
    }
    
    final paymentJson = prefs.getStringList(_paymentCategoriesKey);
    if (paymentJson != null) {
      _paymentCategories = paymentJson;
    }
    
    // Load category icons
    final iconsJson = prefs.getString(_categoryIconsKey);
    if (iconsJson != null) {
      final Map<String, dynamic> iconsMap = jsonDecode(iconsJson);
      _categoryIconCodes = iconsMap.map((key, value) => MapEntry(key, value as int));
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = jsonEncode(_accounts.map((a) => a.toJson()).toList());
    await prefs.setString(_accountsKey, accountsJson);
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_transactionsKey, transactionsJson);
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_incomeCategoriesKey, _incomeCategories);
    await prefs.setStringList(_expenseCategoriesKey, _expenseCategories);
    await prefs.setStringList(_transferCategoriesKey, _transferCategories);
    await prefs.setStringList(_paymentCategoriesKey, _paymentCategories);
    await _saveCategoryIcons();
  }

  Future<void> _saveCategoryIcons() async {
    final prefs = await SharedPreferences.getInstance();
    final iconsJson = jsonEncode(_categoryIconCodes);
    await prefs.setString(_categoryIconsKey, iconsJson);
  }

  // Clear all data (for testing/reset purposes)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountsKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_incomeCategoriesKey);
    await prefs.remove(_expenseCategoriesKey);
    await prefs.remove(_transferCategoriesKey);
    await prefs.remove(_paymentCategoriesKey);
    await prefs.remove(_categoryIconsKey);
    
    // Reset to defaults
    _accounts = [];
    _transactions = [];
    _loadAllData();
  }
}
