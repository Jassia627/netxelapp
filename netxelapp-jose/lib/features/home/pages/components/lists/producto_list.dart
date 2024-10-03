// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/core/utils/show_snackbar.dart';

import 'package:netxelapp/features/home/pages/components/forms/producto_form.dart';
import 'package:netxelapp/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductoList extends StatefulWidget {
  const ProductoList({super.key});

  @override
  _ProductoListState createState() => _ProductoListState();
}

class _ProductoListState extends State<ProductoList> {
  final _client = supabase;
  List<Map<String, dynamic>> _productos = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _client
          .from('products')
          .select(
              '*, products_categories(category_name), units_of_measures(large_name, short_name)')
          .eq('active', true)
          .order('name');

      setState(() {
        _productos = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addProducto(
    String productName,
    double salePrice,
    double productionPrice,
    int presentationQuantity,
    int categoryId,
    int unitOfMeasureId,
  ) async {
    try {
      await _client.from('products').insert({
        'name': productName,
        'sale_price': salePrice,
        'production_price': productionPrice,
        'presentation_quantity': presentationQuantity,
        'category_id': categoryId,
        'unit_of_measure_id': unitOfMeasureId,
        'user_id': supabase.auth.currentUser?.id,
      });
      _fetchProductos();
    } on PostgrestException catch (e) {
      throw e.toString();
    }
  }

  Future<void> _updateProducto(
    int index,
    String productName,
    double salePrice,
    double productionPrice,
    int presentationQuantity,
    int categoryId,
    int unitOfMeasureId,
  ) async {
    try {
      final productoId = _productos[index]['id'];
      await _client.from('products').update({
        'name': productName,
        'sale_price': salePrice,
        'production_price': productionPrice,
        'presentation_quantity': presentationQuantity,
        'category_id': categoryId,
        'unit_of_measure_id': unitOfMeasureId,
        'user_id': supabase.auth.currentUser?.id,
      }).eq('id', productoId);
      _fetchProductos();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _deleteProducto(int index) async {
    try {
      final productoId = _productos[index]['id'];
      print('Hola');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar producto'),
            content: Text(
                '¿Estás seguro de eliminar el producto "${_productos[index]['name']}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await supabase.from('products').update({
                    'active': false,
                  }).eq('id', productoId);
                  Navigator.of(context).pop();
                  _fetchProductos();
                },
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _scanBarcodeAndAssign(int productId) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);

      if (barcodeScanRes != '-1') {
        await supabase.from('products').update({
          'barcode': barcodeScanRes,
        }).eq('id', productId);
        showSnackBar(context, 'Código de barras asignado correctamente');

        _fetchProductos();
      }
    } on PlatformException {
      barcodeScanRes = "failed to get platform";
    }
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
      '#ff6666',
      'Cancelar',
      true,
      ScanMode.BARCODE,
    )!
        .listen((barcode) => debugPrint(barcode));
  }

  @override
  Widget build(BuildContext context) {
    final filteredProductos = _productos.where((producto) {
      final productName = producto['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return productName.contains(query);
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProductos.length,
                    itemBuilder: (context, index) {
                      final producto = filteredProductos[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          12.0), // Radio de los bordes redondeados
                                      image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/Ejemplo.png'), // Ruta de la imagen
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text(producto['name'] +
                                        ' x ${producto['presentation_quantity']}${producto['units_of_measures']['short_name']}'),
                                    subtitle: Text(
                                      'Precio de venta: \$${producto['sale_price']} \nPrecio de producción: \$${producto['production_price']}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ProductoForm(
                                        productName: producto['name'] != null
                                            ? producto['name'] as String
                                            : '',
                                        salePrice: producto['sale_price'] !=
                                                null
                                            ? producto['sale_price'].toDouble()
                                            : 0.0,
                                        productionPrice:
                                            producto['production_price'] != null
                                                ? producto['production_price']
                                                    .toDouble()
                                                : 0.0,
                                        presentationQuantity: producto[
                                                    'presentation_quantity'] !=
                                                null
                                            ? producto['presentation_quantity']
                                                as int
                                            : 0,
                                        categoryId:
                                            producto['category_id'] != null
                                                ? producto['category_id'] as int
                                                : 0,
                                        unitOfMeasureId:
                                            producto['unit_of_measure_id'] !=
                                                    null
                                                ? producto['unit_of_measure_id']
                                                    as int
                                                : 0,
                                        onProductoAgregado: (
                                          updatedProductName,
                                          updatedSalePrice,
                                          updatedProductionPrice,
                                          updatedPresentationQuantity,
                                          updatedCategoryId,
                                          updatedUnitOfMeasureId,
                                        ) =>
                                            _updateProducto(
                                          index,
                                          updatedProductName,
                                          updatedSalePrice,
                                          updatedProductionPrice,
                                          updatedPresentationQuantity,
                                          updatedCategoryId,
                                          updatedUnitOfMeasureId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteProducto(index);
                                  },
                                ),
                                IconButton(
                                    icon: const Icon(Icons.qr_code_scanner),
                                    onPressed: () {
                                      _scanBarcodeAndAssign(index);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ProductoForm(
                          onProductoAgregado: _addProducto,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Agregar Producto'),
                  ),
                ),
              ],
            ),
    );
  }
}
