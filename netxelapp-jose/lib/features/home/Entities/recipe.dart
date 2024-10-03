class Recipe {
  int? id;
  String name;
  String? userId;

  Recipe({
    this.id,
    required this.name,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      userId: map['user_id'] ?? '',
    );
  }
}
