import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expense.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final User? user = FirebaseAuth.instance.currentUser;

  late String _title;
  late double _amount;
  late String _category;
  late DateTime _date;
  late bool _isRecurring;
  late String _paymentMethod;
  late String _note;
  late String _imageUrl;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.expense;
    _title = exp?.title ?? '';
    _amount = exp?.amount ?? 0.0;
    _category = exp?.category ?? '';
    _date = exp?.date ?? DateTime.now();
    _isRecurring = exp?.isRecurring ?? false;
    _paymentMethod = exp?.paymentMethod ?? 'Cash';
    _note = exp?.note ?? '';
    _imageUrl = exp?.imageUrl ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt image selected!'), backgroundColor: Color(0xFF55AC53)),
        );
      }
    }
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Category Required'),
          content: const Text('Please select an expense category.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF0B10C0))),
            ),
          ],
        ),
      );
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      String imageUrl = _imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadReceiptImage(_selectedImage!, user!.uid);
      }

      final expense = Expense(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user!.uid,
        title: _title,
        amount: _amount,
        category: _category,
        date: _date,
        imageUrl: imageUrl,
        isRecurring: _isRecurring,
        paymentMethod: _paymentMethod,
        note: _note,
      );

      if (widget.expense == null) {
        await _firestoreService.addExpense(expense);
      } else {
        await _firestoreService.updateExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved successfully!'), backgroundColor: Color(0xFF55AC53)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'New Expense' : 'Edit Expense'),
        backgroundColor: const Color(0xFFCFD0FC),
        foregroundColor: const Color(0xFF0B10C0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Expense Title', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Please enter title' : null,
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.expense != null ? _amount.toString() : '',
                decoration: const InputDecoration(labelText: 'Amount (₱)', border: OutlineInputBorder()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || double.tryParse(val) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (val) => _amount = double.parse(val!),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<CategoryModel>>(
                stream: _firestoreService.getCategories(user!.uid),
                builder: (context, snapshot) {
                  List<CategoryModel> categories = snapshot.data ?? [];
                  if (_category.isEmpty && categories.isNotEmpty) {
                    _category = categories.first.name;
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _category.isNotEmpty ? _category : null,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat.name, child: Text(cat.name));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _category = val ?? '');
                    },
                    validator: (val) => val == null || val.isEmpty ? 'Please select a category' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Repeating / Recurring Expense'),
                value: _isRecurring,
                activeColor: const Color(0xFF0B10C0),
                onChanged: (val) => setState(() => _isRecurring = val ?? false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                items: ['Cash', 'Credit Card', 'GCash', 'Bank Transfer'].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (val) => setState(() => _paymentMethod = val ?? 'Cash'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _note,
                decoration: const InputDecoration(labelText: 'Note (Optional)', border: OutlineInputBorder()),
                maxLines: 2,
                onSaved: (val) => _note = val ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0B10C0)),
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Receipt Image'),
                  ),
                  const SizedBox(width: 16),
                  if (_selectedImage != null)
                    const Text('Image selected', style: TextStyle(color: Color(0xFF55AC53), fontWeight: FontWeight.bold))
                  else if (_imageUrl.isNotEmpty)
                    const Text('Existing image attached', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0B10C0)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B10C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _saveExpense,
                      child: const Text('Save Expense', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
