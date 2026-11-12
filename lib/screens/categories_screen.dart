import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;

  void _showAddCategoryBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String iconUrl = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B10C0)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
                onSaved: (val) => name = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Icon Image URL', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Please enter icon URL' : null,
                onSaved: (val) => iconUrl = val!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B10C0),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final newCategory = CategoryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user!.uid,
                      name: name,
                      iconUrl: iconUrl,
                    );
                    await _firestoreService.addCategory(newCategory);
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category added successfully!'), backgroundColor: Color(0xFF55AC53)),
                      );
                    }
                  }
                },
                child: const Text('Save Category'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text('Please log in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Categories'),
        backgroundColor: const Color(0xFFCFD0FC),
        foregroundColor: const Color(0xFF0B10C0),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: _firestoreService.getCategories(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0B10C0)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No categories added yet. Add one using the button below!', textAlign: TextAlign.center),
            );
          }
          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: cat.iconUrl.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(cat.iconUrl))
                      : const CircleAvatar(backgroundColor: Color(0xFFCFD0FC), child: Icon(Icons.category, color: Color(0xFF0B10C0))),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Category'),
                          content: Text('Are you sure you want to delete ${cat.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                await _firestoreService.deleteCategory(cat.id);
                                if (mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF55AC53),
        foregroundColor: Colors.white,
        onPressed: () => _showAddCategoryBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
