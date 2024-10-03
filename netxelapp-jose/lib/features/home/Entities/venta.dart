import 'package:netxelapp/features/home/Entities/producto_seleccionado.dart';

class Venta {
  final List<ProductoSeleccionado> productosSeleccionados;
  final double total;

  Venta({
    required this.productosSeleccionados,
    required this.total,
  });
}
