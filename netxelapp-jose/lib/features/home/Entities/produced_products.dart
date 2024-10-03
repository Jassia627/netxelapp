class ProducedProduct {
  int? id;
  int productId;
  String name;
  int quantity;
  int recipeId;
  String userId;

  ProducedProduct({
    this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.recipeId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': name,
      'quantity': quantity,
      'recipe_id': recipeId,
      'user_id': userId,
    };
  }

  factory ProducedProduct.fromMap(Map<String, dynamic> map) {
    return ProducedProduct(
      id: map['id']?.toInt(),
      productId: map['product_id']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      recipeId: map['recipe_id']?.toInt() ?? 0,
      userId: map['user_id'] ?? '',
      name: map['product_name'] ?? '',
    );
  }
}
