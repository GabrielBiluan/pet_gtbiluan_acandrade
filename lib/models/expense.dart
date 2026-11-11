class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String imageUrl;
  final bool isRecurring;
  final String paymentMethod;
  final String note;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.isRecurring,
    required this.paymentMethod,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'isRecurring': isRecurring,
      'paymentMethod': paymentMethod,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      imageUrl: map['imageUrl'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      note: map['note'] ?? '',
    );
  }
}
