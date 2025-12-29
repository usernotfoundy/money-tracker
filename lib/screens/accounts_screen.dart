import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/account.dart';
import 'closed_accounts_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2E20),
      appBar: AppBar(
        title: const Text(
          'Accounts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B2E20),
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              final closedCount = appState.closedAccounts.length;
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClosedAccountsScreen(),
                    ),
                  );
                },
                icon: Badge(
                  isLabelVisible: closedCount > 0,
                  label: Text('$closedCount'),
                  child: const Icon(Icons.archive_outlined, color: Colors.white),
                ),
                tooltip: 'Closed Accounts',
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              // Net Worth Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF344E41), Color(0xFF283D2F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF84A98C).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Net Worth',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱${appState.netWorth.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: appState.netWorth >= 0 
                            ? const Color(0xFF84A98C)
                            : const Color(0xFFFF6B6B),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_upward, color: Color(0xFF84A98C), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Assets',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${appState.totalAssets.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF84A98C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: Color(0xFFFF6B6B), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Liabilities',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${appState.totalLiabilities.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Accounts List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Accounts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showAddAccountDialog(context),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF84A98C),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Accounts List
              Expanded(
                child: appState.openAccounts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 80,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No accounts yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _showAddAccountDialog(context),
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFF84A98C),
                              ),
                              label: const Text(
                                'Add your first account',
                                style: TextStyle(color: Color(0xFF84A98C)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appState.openAccounts.length,
                        itemBuilder: (context, index) {
                          final account = appState.openAccounts[index];
                          return GestureDetector(
                            onLongPress: () => _showAccountOptionsDialog(context, appState, account),
                            child: Dismissible(
                              key: Key(account.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF52796F).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.archive, color: Color(0xFF52796F)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Close',
                                      style: TextStyle(
                                        color: Color(0xFF52796F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF283D2F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text(
                                      'Close Account',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Close "${account.name}"? You can reopen it later from Closed Accounts.',
                                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(color: Color(0xFF52796F)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
                              },
                              onDismissed: (direction) {
                                appState.closeAccount(account.id);
                              },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF283D2F),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: account.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      account.icon,
                                      color: account.color,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Available Balance',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₱${account.balance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: account.isLiability
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0xFF84A98C),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        account.isAsset ? 'Asset' : 'Liability',
                                        style: TextStyle(
                                          color: account.isAsset 
                                              ? const Color(0xFF84A98C).withOpacity(0.5)
                                              : const Color(0xFFFF6B6B).withOpacity(0.5),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        backgroundColor: const Color(0xFF84A98C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddAccountSheet(),
    );
  }

  void _showAccountOptionsDialog(BuildContext context, AppState appState, Account account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF283D2F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                account.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₱${account.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: account.isAsset 
                      ? const Color(0xFF84A98C)
                      : const Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.archive, color: Color(0xFF52796F)),
                title: const Text(
                  'Close Account',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Move to closed accounts',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  appState.closeAccount(account.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${account.name} has been closed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => appState.reopenAccount(account.id),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Permanently remove this account',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteAccount(context, appState, account);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AppState appState, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF283D2F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${account.name}"? This action cannot be undone.',
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
              Navigator.pop(ctx);
              appState.deleteAccount(account.id);
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
}

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet();

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  IconData _selectedIcon = Icons.account_balance_wallet;
  Color _selectedColor = Colors.teal;
  AccountType _selectedType = AccountType.asset;

  final List<IconData> _icons = [
    Icons.account_balance_wallet,
    Icons.account_balance,
    Icons.credit_card,
    Icons.money,
    Icons.savings,
    Icons.payment,
    Icons.attach_money,
    Icons.monetization_on,
  ];

  final List<Color> _colors = [
    Colors.teal,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
    Colors.green,
    Colors.red,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_nameController.text.isNotEmpty) {
      final initialBalance = double.tryParse(_balanceController.text) ?? 0.0;
      context.read<AppState>().addAccount(
        _nameController.text,
        _selectedIcon,
        _selectedColor,
        initialBalance: initialBalance,
        type: _selectedType,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF283D2F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add New Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Account Type Selector
            Text(
              'Account Type',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = AccountType.asset),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedType == AccountType.asset
                            ? const Color(0xFF84A98C).withOpacity(0.2)
                            : const Color(0xFF1B2E20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == AccountType.asset
                              ? const Color(0xFF84A98C)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: _selectedType == AccountType.asset
                                ? const Color(0xFF84A98C)
                                : Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Asset',
                            style: TextStyle(
                              color: _selectedType == AccountType.asset
                                  ? const Color(0xFF84A98C)
                                  : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cash, Bank, Savings',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = AccountType.liability),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedType == AccountType.liability
                            ? const Color(0xFFFF6B6B).withOpacity(0.2)
                            : const Color(0xFF1B2E20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == AccountType.liability
                              ? const Color(0xFFFF6B6B)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trending_down,
                            color: _selectedType == AccountType.liability
                                ? const Color(0xFFFF6B6B)
                                : Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Liability',
                            style: TextStyle(
                              color: _selectedType == AccountType.liability
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Credit Card, Loan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Account Name
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Account Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF1B2E20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF84A98C)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Initial Balance
            TextField(
              controller: _balanceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Initial Balance',
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixText: '₱ ',
                prefixStyle: const TextStyle(color: Color(0xFF84A98C)),
                filled: true,
                fillColor: const Color(0xFF1B2E20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF84A98C)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Icon Selection
            Text(
              'Icon',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _icons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.3)
                          : const Color(0xFF1B2E20),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: _selectedColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? _selectedColor : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Color Selection
            Text(
              'Color',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF84A98C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
