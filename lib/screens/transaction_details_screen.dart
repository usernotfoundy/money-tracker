import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  final AppState appState;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.appState,
  });

  String get _typeLabel {
    switch (transaction.type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.payment:
        return 'Liability Payment';
    }
  }

  Color get _accentColor {
    switch (transaction.type) {
      case TransactionType.income:
        return const Color(0xFF84A98C);
      case TransactionType.expense:
        return const Color(0xFFFF6B6B);
      case TransactionType.transfer:
        return const Color(0xFF52796F);
      case TransactionType.payment:
        return const Color(0xFFA3B18A);
    }
  }

  IconData get _typeIcon {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.payment:
        return Icons.payment;
    }
  }

  String get _amountPrefix {
    switch (transaction.type) {
      case TransactionType.income:
        return '+';
      case TransactionType.expense:
      case TransactionType.payment:
        return '-';
      case TransactionType.transfer:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = appState.getAccountById(transaction.accountId);
    final toAccount = transaction.toAccountId != null
        ? appState.getAccountById(transaction.toAccountId!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF1B2E20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2E20),
        elevation: 0,
        title: const Text(
          'Transaction Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accentColor.withOpacity(0.2),
                    _accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_typeIcon, color: _accentColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeLabel,
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_amountPrefix₱${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.category,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Section
            _buildSectionTitle('Details'),
            const SizedBox(height: 12),

            // Date & Time
            _buildDetailCard(
              icon: Icons.calendar_today,
              label: 'Date & Time',
              value: DateFormat('EEEE, MMMM dd, yyyy • HH:mm').format(transaction.dateTime),
            ),

            const SizedBox(height: 12),

            // Account
            _buildDetailCard(
              icon: Icons.account_balance_wallet,
              label: transaction.type == TransactionType.transfer || 
                     transaction.type == TransactionType.payment
                  ? 'From Account'
                  : 'Account',
              value: account?.name ?? 'Unknown Account',
              valueColor: account?.color,
            ),

            // To Account (for transfers and payments)
            if (toAccount != null) ...[
              const SizedBox(height: 12),
              _buildDetailCard(
                icon: transaction.type == TransactionType.payment 
                    ? Icons.credit_card 
                    : Icons.account_balance,
                label: transaction.type == TransactionType.payment
                    ? 'Paid To Liability'
                    : 'To Account',
                value: toAccount.name,
                valueColor: toAccount.color,
              ),
            ],

            // Transfer Fees
            if (transaction.type == TransactionType.transfer && transaction.fees > 0) ...[
              const SizedBox(height: 12),
              _buildDetailCard(
                icon: Icons.money_off,
                label: 'Transfer Fees',
                value: '₱${transaction.fees.toStringAsFixed(2)}',
                valueColor: const Color(0xFFFF6B6B),
              ),
              const SizedBox(height: 12),
              _buildDetailCard(
                icon: Icons.calculate,
                label: 'Total Deducted',
                value: '₱${transaction.totalDeducted.toStringAsFixed(2)}',
                valueColor: Colors.white.withOpacity(0.7),
              ),
            ],

            // Note
            if (transaction.note.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Note'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF283D2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  transaction.note,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],

            // Description
            if (transaction.description.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Description'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF283D2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  transaction.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            // Attached Image
            if (transaction.imagePath != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Attachment'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF283D2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: () => _showFullImage(context, transaction.imagePath!),
                    child: Image.file(
                      File(transaction.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: const Color(0xFF283D2F),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to view full image',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Transaction ID (subtle)
            Center(
              child: Text(
                'ID: ${transaction.id.substring(0, 8)}...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF283D2F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2E20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF283D2F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Transaction',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this ${transaction.category} transaction of ₱${transaction.amount.toStringAsFixed(2)}?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              appState.deleteTransaction(transaction.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to transactions screen
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

