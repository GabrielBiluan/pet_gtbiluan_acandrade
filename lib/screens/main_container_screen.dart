import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_edit_expense_screen.dart';

class MainContainerScreen extends StatelessWidget {
  const MainContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: const Color(0xFF0B10C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: firestoreService.getExpenses(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0B10C0)));
          }
          final expenses = snapshot.data ?? [];
          double total = expenses.fold(0.0, (sum, item) => sum + item.amount);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFCFD0FC),
                child: Column(
                  children: [
                    const Text('Total Expenses', style: TextStyle(fontSize: 16, color: Color(0xFF0B10C0))),
                    const SizedBox(height: 8),
                    Text(
                      '₱${NumberFormat('#,##0.00').format(total)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0B10C0)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text('No expenses recorded yet.'))
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (ctx, index) {
                          final expense = expenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFCFD0FC),
                                child: Icon(Icons.receipt, color: Color(0xFF0B10C0)),
                              ),
                              title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '-₱${NumberFormat('#,##0.00').format(expense.amount)}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                                    onPressed: () async {
                                      await firestoreService.deleteExpense(expense.id);
                                    },
                                  ),
                                ],
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
