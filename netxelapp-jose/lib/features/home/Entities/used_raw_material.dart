class UsedRawMaterial {
  int? id;
  String name;
  int rawMaterialId;
  double quantity;
  int recipeId;
  String userId;

  UsedRawMaterial({
    this.id,
    required this.name,
    required this.rawMaterialId,
    required this.quantity,
    required this.recipeId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'raw_material_name': name,
      'raw_material_id': rawMaterialId,
      'quantity': quantity,
      'recipe_id': recipeId,
      'user_id': userId,
    };
  }

  factory UsedRawMaterial.fromMap(Map<String, dynamic> map) {
    return UsedRawMaterial(
      id: map['id']?.toInt(),
      name: map['raw_material_name'] ?? '',
      rawMaterialId: map['raw_material_id']?.toInt() ?? 0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      recipeId: map['recipe_id']?.toInt() ?? 0,
      userId: map['user_id'] ?? '',
    );
  }
}
