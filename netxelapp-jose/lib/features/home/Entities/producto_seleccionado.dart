import 'package:netxelapp/features/home/Entities/producto.dart';

class ProductoSeleccionado {
  final Producto producto;
  int cantidad;

  ProductoSeleccionado({required this.producto, this.cantidad = 1});
}
