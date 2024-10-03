class Sale {
  final int? id;
  final double? total;
  final DateTime? createdAt;
  final String? client;
  final int? numeroFactura;
  bool? confirmed;

  Sale(
      {this.id,
      this.total,
      this.createdAt,
      this.client,
      this.confirmed,
      this.numeroFactura});

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      total: _toDouble(map['total']),
      createdAt: _toDateTime(map['created_at']),
      client: map['client_name']?.toString(),
      numeroFactura: _toInt(map['numero_factura']),
      confirmed: map['confirmed'] == true,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {}
    }
    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {}
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is double) return value.toInt();
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {}
    }
    return null;
  }

  @override
  String toString() {
    return 'Sale(id: $id, total: $total, createdAt: $createdAt, client: $client, confirmed: $confirmed)';
  }
}

class SaleDetail {
  int? id;
  int? soldProductId;
  int? quantity;
  int? saleId;
  String? userId;

  SaleDetail({
    this.id,
    this.soldProductId,
    this.quantity,
    this.saleId,
    this.userId,
  });

  factory SaleDetail.fromMap(Map<String, dynamic> map) {
    return SaleDetail(
      id: map['id'],
      soldProductId: map['sold_product_id'],
      quantity: map['quantity'],
      saleId: map['sale_id'],
      userId: map['user_id']?.toString(),
    );
  }

  @override
  String toString() {
    return 'SaleDetail(id: $id, soldProductId: $soldProductId, quantity: $quantity, saleId: $saleId, userId: $userId)';
  }
}

// Modelo para la tabla "products"
class Product {
  int? id;
  String? name;
  int? stockQuantity;
  int? categoryId;
  int? unitOfMeasureId;
  double? salePrice;
  double? productionPrice;
  int? presentationQuantity;

  Product({
    this.id,
    this.name,
    this.stockQuantity,
    this.categoryId,
    this.unitOfMeasureId,
    this.salePrice,
    this.productionPrice,
    this.presentationQuantity,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      stockQuantity: map['stock_quantity'],
      categoryId: map['category_id'],
      unitOfMeasureId: map['unit_of_measure_id'],
      salePrice: _toDouble(map['sale_price']),
      productionPrice: _toDouble(map['production_price']),
      presentationQuantity: map['presentation_quantity'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {}
    }
    return null;
  }

  @override
  String toString() {
    return 'Product(name: $name)';
  }
}
