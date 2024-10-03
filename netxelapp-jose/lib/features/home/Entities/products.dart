class Product {
  final int id;
  final String name;
  final int quantity; // Agregamos esta línea

  Product({required this.id, required this.name, this.quantity = 0});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      quantity: map['quantity'] ??
          0, // Manejamos el caso en que quantity no esté presente
    );
  }
}
