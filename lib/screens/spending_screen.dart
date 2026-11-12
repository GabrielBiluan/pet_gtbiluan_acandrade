import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import 'add_edit_expense_screen.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({super.key});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  
  String _filterMode = 'Monthly'; // Daily, Weekly, Monthly, Yearly
  DateTime _selectedDate = DateTime.now();

  void _previousPeriod() {
    setState(() {
      if (_filterMode == 'Monthly' || _filterMode == 'Weekly') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
      } else if (_filterMode == 'Yearly') {
        _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month, _selectedDate.day);
      } else {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_filterMode == 'Monthly' || _filterMode == 'Weekly') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
      } else if (_filterMode == 'Yearly') {
        _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month, _selectedDate.day);
      } else {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      }
    });
  }

  void _showSpendingMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((mode) {
        return PopupMenuItem<String>(
          value: mode,
          child: Row(
            children: [
              if (_filterMode == mode) const Icon(Icons.check, size: 16, color: Color(0xFF0B10C0)),
              if (_filterMode == mode) const SizedBox(width: 8),
              Text(mode, style: TextStyle(fontWeight: _filterMode == mode ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        );
      }).toList(),
    ).then((selected) {
      if (selected != null) {
        setState(() => _filterMode = selected);
      }
    });
  }

  bool _matchesFilter(DateTime expenseDate) {
    if (_filterMode == 'Daily') {
      return expenseDate.year == _selectedDate.year &&
          expenseDate.month == _selectedDate.month &&
          expenseDate.day == _selectedDate.day;
    } else if (_filterMode == 'Weekly') {
      final difference = _selectedDate.difference(expenseDate).inDays;
      return difference >= 0 && difference < 7;
    } else if (_filterMode == 'Monthly') {
      return expenseDate.year == _selectedDate.year && expenseDate.month == _selectedDate.month;
    } else if (_filterMode == 'Yearly') {
      return expenseDate.year == _selectedDate.year;
    }
    return true;
  }

  String _getPeriodTitle() {
    if (_filterMode == 'Yearly') {
      return DateFormat('yyyy').format(_selectedDate);
    } else if (_filterMode == 'Daily') {
      return DateFormat('dd MMM yyyy').format(_selectedDate);
    }
    return DateFormat('MMMM yyyy').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text('Please log in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Overview'),
        backgroundColor: const Color(0xFFCFD0FC),
        foregroundColor: const Color(0xFF0B10C0),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0B10C0)),
            onPressed: () => _showSpendingMenu(context),
            icon: const Icon(Icons.filter_list, size: 18),
            label: Text(_filterMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpenses(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0B10C0)));
          }
          final allExpenses = snapshot.data ?? [];
          final filteredExpenses = allExpenses.where((e) => _matchesFilter(e.date)).toList();

          double totalSpending = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);

          Map<String, double> categoryTotals = {};
          for (var e in filteredExpenses) {
            categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month / Period Navigation Header matching reference UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Color(0xFF0B10C0), size: 28),
                      onPressed: _previousPeriod,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0B10C0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getPeriodTitle(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B10C0)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Color(0xFF0B10C0), size: 28),
                      onPressed: _nextPeriod,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFF0B10C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Expenses ($_filterMode)',
                          style: const TextStyle(color: Color(0xFFCFD0FC), fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${NumberFormat('#,##0.00').format(totalSpending)}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Spending by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B10C0)),
                ),
                const SizedBox(height: 12),
                categoryTotals.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No expenses recorded for this period.')),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: categoryTotals.keys.length,
                        itemBuilder: (ctx, index) {
                          String catName = categoryTotals.keys.elementAt(index);
                          double catAmount = categoryTotals[catName]!;
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    catName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B10C0)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₱${NumberFormat('#,##0.00').format(catAmount)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF55AC53)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF55AC53),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
