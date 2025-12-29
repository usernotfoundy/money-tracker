import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D9A5),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
            Tab(text: 'Transfer'),
            Tab(text: 'Payment'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Income Categories Tab
              _CategoryList(
                categories: appState.incomeCategories,
                type: 'Income',
                accentColor: const Color(0xFF00D9A5),
                onAdd: (category, icon) => appState.addIncomeCategory(category, icon: icon),
                onDelete: (category) => appState.removeIncomeCategory(category),
                isCategoryInUse: appState.isCategoryInUse,
                getCategoryIcon: appState.getCategoryIcon,
              ),
              // Expense Categories Tab
              _CategoryList(
                categories: appState.expenseCategories,
                type: 'Expense',
                accentColor: const Color(0xFFFF6B6B),
                onAdd: (category, icon) => appState.addExpenseCategory(category, icon: icon),
                onDelete: (category) => appState.removeExpenseCategory(category),
                isCategoryInUse: appState.isCategoryInUse,
                getCategoryIcon: appState.getCategoryIcon,
              ),
              // Transfer Categories Tab
              _CategoryList(
                categories: appState.transferCategories,
                type: 'Transfer',
                accentColor: const Color(0xFF4ECDC4),
                onAdd: (category, icon) => appState.addTransferCategory(category, icon: icon),
                onDelete: (category) => appState.removeTransferCategory(category),
                isCategoryInUse: appState.isCategoryInUse,
                getCategoryIcon: appState.getCategoryIcon,
              ),
              // Payment Categories Tab
              _CategoryList(
                categories: appState.paymentCategories,
                type: 'Payment',
                accentColor: const Color(0xFFFFB347),
                onAdd: (category, icon) => appState.addPaymentCategory(category, icon: icon),
                onDelete: (category) => appState.removePaymentCategory(category),
                isCategoryInUse: appState.isCategoryInUse,
                getCategoryIcon: appState.getCategoryIcon,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<String> categories;
  final String type;
  final Color accentColor;
  final Function(String, IconData) onAdd;
  final Function(String) onDelete;
  final bool Function(String) isCategoryInUse;
  final IconData Function(String) getCategoryIcon;

  const _CategoryList({
    required this.categories,
    required this.type,
    required this.accentColor,
    required this.onAdd,
    required this.onDelete,
    required this.isCategoryInUse,
    required this.getCategoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Category Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () => _showAddCategoryDialog(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'Add $type Category',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Categories List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final inUse = isCategoryInUse(category);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      getCategoryIcon(category),
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: inUse
                      ? Text(
                          'In use',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        )
                      : null,
                  trailing: inUse
                      ? Icon(
                          Icons.lock_outline,
                          color: Colors.white.withOpacity(0.3),
                          size: 20,
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFFF6B6B),
                          ),
                          onPressed: () => _showDeleteDialog(context, category),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    IconData selectedIcon = Icons.category;
    
    final availableIcons = [
      Icons.category,
      Icons.work,
      Icons.computer,
      Icons.trending_up,
      Icons.card_giftcard,
      Icons.replay,
      Icons.restaurant,
      Icons.directions_car,
      Icons.shopping_bag,
      Icons.movie,
      Icons.receipt_long,
      Icons.medical_services,
      Icons.school,
      Icons.flight,
      Icons.swap_horiz,
      Icons.savings,
      Icons.show_chart,
      Icons.shield,
      Icons.credit_card,
      Icons.account_balance,
      Icons.money_off,
      Icons.home,
      Icons.sports_esports,
      Icons.pets,
      Icons.child_care,
      Icons.fitness_center,
      Icons.local_cafe,
      Icons.local_grocery_store,
      Icons.phone_android,
      Icons.wifi,
      Icons.electric_bolt,
      Icons.water_drop,
      Icons.local_gas_station,
      Icons.attach_money,
      Icons.more_horiz,
    ];
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add $type Category',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 280,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Category name',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Icon Selection
                  Text(
                    'Choose Icon',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final icon = availableIcons[index];
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentColor.withOpacity(0.3)
                                  : const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: accentColor, width: 2)
                                  : null,
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? accentColor
                                  : Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                if (controller.text.trim().isNotEmpty) {
                  onAdd(controller.text.trim(), selectedIcon);
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Category',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "$category"? This action cannot be undone.',
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
              onDelete(category);
              Navigator.pop(ctx);
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

