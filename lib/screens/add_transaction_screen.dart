import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType type;

  const AddTransactionScreen({super.key, required this.type});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedCategory;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  String? _imagePath;
  
  final _uuid = const Uuid();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00D9A5),
              surface: Color(0xFF16213E),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00D9A5),
                surface: Color(0xFF16213E),
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _selectedAccountId != null) {
      
      if (widget.type == TransactionType.transfer && _selectedToAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select destination account')),
        );
        return;
      }

      if (widget.type == TransactionType.payment && _selectedToAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a liability to pay')),
        );
        return;
      }

      final transaction = Transaction(
        id: _uuid.v4(),
        type: widget.type,
        dateTime: _selectedDateTime,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        accountId: _selectedAccountId!,
        toAccountId: _selectedToAccountId,
        note: _noteController.text,
        description: _descriptionController.text,
        imagePath: _imagePath,
      );

      context.read<AppState>().addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  String get _title {
    switch (widget.type) {
      case TransactionType.income:
        return 'Add Income';
      case TransactionType.expense:
        return 'Add Expense';
      case TransactionType.transfer:
        return 'Add Transfer';
      case TransactionType.payment:
        return 'Pay Liability';
    }
  }

  Color get _accentColor {
    switch (widget.type) {
      case TransactionType.income:
        return const Color(0xFF00D9A5);
      case TransactionType.expense:
        return const Color(0xFFFF6B6B);
      case TransactionType.transfer:
        return const Color(0xFF4ECDC4);
      case TransactionType.payment:
        return const Color(0xFFFFB347);
    }
  }

  List<String> get _categories {
    final appState = context.read<AppState>();
    if (widget.type == TransactionType.income) {
      return appState.incomeCategories;
    } else if (widget.type == TransactionType.expense) {
      return appState.expenseCategories;
    } else if (widget.type == TransactionType.payment) {
      return appState.paymentCategories;
    } else {
      return appState.transferCategories;
    }
  }

  bool get _isPayment => widget.type == TransactionType.payment;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount Field
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₱',
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: _accentColor.withOpacity(0.3),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date Time Picker
            _buildCard(
              'Date & Time',
              Icons.calendar_today,
              child: InkWell(
                onTap: _selectDateTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(_selectedDateTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category Dropdown
            _buildCard(
              'Category',
              Icons.category,
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF16213E),
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                hint: Text(
                  'Select category',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Select a category';
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Account Dropdown (From Account for transfer/payment)
            _buildCard(
              (widget.type == TransactionType.transfer || _isPayment) 
                  ? 'From Account' 
                  : 'Account',
              Icons.account_balance_wallet,
              child: DropdownButtonFormField<String>(
                value: _selectedAccountId,
                dropdownColor: const Color(0xFF16213E),
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                hint: Text(
                  _isPayment ? 'Select asset account' : 'Select account',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                items: (_isPayment ? appState.openAssetAccounts : appState.openAccounts)
                    .map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(
                      '${account.name} (₱${account.balance.toStringAsFixed(2)})',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Select an account';
                  return null;
                },
              ),
            ),
            
            // To Account (for transfers)
            if (widget.type == TransactionType.transfer) ...[
              const SizedBox(height: 16),
              _buildCard(
                'To Account',
                Icons.account_balance,
                child: DropdownButtonFormField<String>(
                  value: _selectedToAccountId,
                  dropdownColor: const Color(0xFF16213E),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    'Select destination account',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  items: appState.openAccounts
                      .where((a) => a.id != _selectedAccountId)
                      .map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(
                        account.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedToAccountId = value;
                    });
                  },
                ),
              ),
            ],
            
            // To Liability (for payment)
            if (_isPayment) ...[
              const SizedBox(height: 16),
              _buildCard(
                'Pay To Liability',
                Icons.credit_card,
                child: DropdownButtonFormField<String>(
                  value: _selectedToAccountId,
                  dropdownColor: const Color(0xFF16213E),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    'Select liability to pay',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  items: appState.openLiabilityAccounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(
                        '${account.name} (₱${account.balance.toStringAsFixed(2)} owed)',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedToAccountId = value;
                    });
                  },
                  validator: (value) {
                    if (_isPayment && value == null) return 'Select a liability';
                    return null;
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Note Field
            _buildCard(
              'Note',
              Icons.note,
              child: TextFormField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add a note',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description Field
            _buildCard(
              'Description',
              Icons.description,
              child: TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add a description',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Image Attachment
            _buildCard(
              'Attachment',
              Icons.attach_file,
              child: InkWell(
                onTap: _pickImage,
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagePath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white.withOpacity(0.5),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String label, IconData icon, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

