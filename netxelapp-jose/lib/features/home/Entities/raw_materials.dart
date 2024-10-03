class RawMaterial {
  final int id;
  final String name;
  final int quantity; // Agregamos esta línea

  RawMaterial({required this.id, required this.name, this.quantity = 0});

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'] ??
          0, // Manejamos el caso en que quantity no esté presente
    );
  }
}
