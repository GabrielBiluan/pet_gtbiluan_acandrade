import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import 'add_edit_expense_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text('Please log in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFFCFD0FC),
        foregroundColor: const Color(0xFF0B10C0),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B10C0)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transactions sorted by date (newest first).')),
              );
            },
            icon: const Icon(Icons.sort, size: 18),
            label: const Text('Sort'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Month navigation matching reference UI
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF0B10C0), size: 28),
                  onPressed: _previousMonth,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0B10C0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B10C0)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF0B10C0), size: 28),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: _firestoreService.getExpenses(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0B10C0)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No transactions recorded yet.'));
                }

                // Filter by selected month and search query
                final expenses = snapshot.data!.where((e) {
                  bool matchesMonth = e.date.year == _selectedDate.year && e.date.month == _selectedDate.month;
                  bool matchesSearch = e.title.toLowerCase().contains(_searchQuery) ||
                      e.category.toLowerCase().contains(_searchQuery);
                  return matchesMonth && matchesSearch;
                }).toList();

                if (expenses.isEmpty) {
                  return const Center(child: Text('No transactions for this month.'));
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (ctx, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFCFD0FC),
                          child: const Icon(Icons.restaurant, color: Color(0xFF0B10C0)),
                        ),
                        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${expense.category} • ${DateFormat('EEEE, dd MMM yyyy').format(expense.date)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱${NumberFormat('#,##0.00').format(expense.amount)}',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Color(0xFF0B10C0)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddEditExpenseScreen(expense: expense)),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Expense'),
                                    content: Text('Delete "${expense.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () async {
                                          await _firestoreService.deleteExpense(expense.id);
                                          if (mounted) Navigator.pop(ctx);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
