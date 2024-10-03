class Product {
  final int id;
  final String name;
  final int stockQuantity;
  final int salePrice;
  final int productionCost;

  Product(
      {required this.id,
      required this.name,
      required this.salePrice,
      required this.productionCost,
      required this.stockQuantity});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
        id: map['id'] as int,
        name: map['name'] as String,
        salePrice: map['sale_price'] as int,
        productionCost: map['production_price'] as int,
        stockQuantity: map['stock_quantity'] as int);
  }
}
