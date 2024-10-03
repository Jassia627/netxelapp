class Producto {
  final String productName;
  final double salePrice;
  final double productionPrice;
  final double presentationQuantity;
  final int categoryId;
  final int unitOfMeasureId;

  Producto({
    required this.productName,
    required this.salePrice,
    required this.productionPrice,
    required this.presentationQuantity,
    required this.categoryId,
    required this.unitOfMeasureId,
  });
}
