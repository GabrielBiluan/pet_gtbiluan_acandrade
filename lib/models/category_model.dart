class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String iconUrl;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'iconUrl': iconUrl,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
    );
  }
}
