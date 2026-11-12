import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/category_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Expenses Stream & CRUD
  Stream<List<Expense>> getExpenses(String userId) {
    return _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()))
            .toList());
  }

  Future<void> addExpense(Expense expense) async {
    // Local cache is updated instantly; timeout handles server ACK delays gracefully
    await _db
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap())
        .timeout(const Duration(seconds: 2), onTimeout: () {});
  }

  Future<void> updateExpense(Expense expense) async {
    await _db
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap())
        .timeout(const Duration(seconds: 2), onTimeout: () {});
  }

  Future<void> deleteExpense(String expenseId) async {
    await _db
        .collection('expenses')
        .doc(expenseId)
        .delete()
        .timeout(const Duration(seconds: 2), onTimeout: () {});
  }

  // Categories Stream & CRUD
  Stream<List<CategoryModel>> getCategories(String userId) {
    return _db
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db
        .collection('categories')
        .doc(category.id)
        .set(category.toMap())
        .timeout(const Duration(seconds: 2), onTimeout: () {});
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .delete()
        .timeout(const Duration(seconds: 2), onTimeout: () {});
  }
}
