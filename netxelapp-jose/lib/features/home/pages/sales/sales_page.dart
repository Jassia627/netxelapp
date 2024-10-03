// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/Entities/client.dart';
import 'package:netxelapp/features/home/Entities/sales.dart';
import 'package:netxelapp/features/home/pages/sales/invoice_screen.dart';
import 'package:netxelapp/features/home/pages/sales/sales_service.dart';
import 'package:netxelapp/main.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SalesService _salesService = SalesService();
  List<Product> _products = [];
  final List<Product> _productSales = [];
  final Map<int, int> _selectedProducts = {}; // {productId: quantity}
  final Map<int, TextEditingController> _quantityControllers = {};
  double _totalSale = 0.0;
  String _searchText = '';
  Client? _selectedClient;
  List<Client> _clients = [];
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _clientSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadClients();
  }

  @override
  void dispose() {
    _quantityControllers.values.forEach((controller) => controller.dispose());
    _invoiceNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    _products = await _salesService.getProducts();
    setState(() {});
  }

  void _addProductToSale(Product product, int quantity) {
    setState(() {
      int currentQuantity = _selectedProducts[product.id] ?? 0;
      int newQuantity = currentQuantity + quantity;
      _selectedProducts[product.id!] = newQuantity;
      _quantityControllers[product.id!]?.text = newQuantity.toString();
      _productSales.add(product);
      _totalSale += product.salePrice! * quantity;
    });
  }

  void _removeProductFromSale(int productId) {
    setState(() {
      Product product = _products.firstWhere((p) => p.id == productId);
      int currentQuantity = _selectedProducts[productId]!;
      if (currentQuantity > 1) {
        int newQuantity = currentQuantity - 1;
        _selectedProducts[productId] = newQuantity;
        _quantityControllers[productId]?.text = newQuantity.toString();
        _totalSale -= product.salePrice!;
      } else {
        _selectedProducts.remove(productId);
        _quantityControllers[productId]?.text = '0';
        _totalSale -= product.salePrice! * currentQuantity;
      }
    });
  }

  void _updateProductQuantity(int productId, int newQuantity) {
    setState(() {
      if (newQuantity > 0) {
        Product product = _products.firstWhere((p) => p.id == productId);
        int oldQuantity = _selectedProducts[productId] ?? 0;
        _selectedProducts[productId] = newQuantity;
        _totalSale += product.salePrice! * (newQuantity - oldQuantity);
        _quantityControllers[productId]?.text = newQuantity.toString();
      } else {
        _removeProductFromSale(productId);
      }
    });
  }

  void _showQuantityDialog(Product product, int currentQuantity) {
    TextEditingController dialogController =
        TextEditingController(text: currentQuantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cantidad para ${product.name}'),
          content: TextField(
            controller: dialogController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nueva cantidad'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                int? newQuantity = int.tryParse(dialogController.text);
                if (newQuantity != null) {
                  _updateProductQuantity(product.id!, newQuantity);
                }
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadClients() async {
    _clients = await _salesService.getClients();
    setState(() {});
  }

  Future<void> _processSale() async {
    for (var entry in _selectedProducts.entries) {
      int productId = entry.key;
      int quantity = entry.value;

      bool isAvailable =
          await _salesService.checkProductAvailability(productId, quantity);

      if (!isAvailable) {
        Product product = _products.firstWhere((p) => p.id == productId);
        String productName = product.name!;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Productos insuficientes'),
            content: Text(
                'No hay suficientes unidades del producto "$productName" en stock. ¿Desea continuar con la venta de todos modos?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _proceedWithSale();
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );

        return;
      }
    }

    _proceedWithSale();
  }

  Future<void> _proceedWithSale() async {
    if (_selectedProducts.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sin productos seleccionados'),
            content: const Text(
                'Debe seleccionar al menos un producto para realizar la venta.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_invoiceNumberController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Número de factura faltante'),
            content: const Text('Por favor, ingrese un número de factura.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      late final Sale sale;

      if (_selectedClient != null && _selectedClient!.id != null) {
        sale = (await _salesService.createSale(
          _totalSale,
          clientId: _selectedClient!.id,
          invoiceNumber: _invoiceNumberController.text,
        ))!;
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('No se ha seleccionado el cliente'),
              content: const Text('Seleccione uno'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (sale.id != null) {
        final saleDetails = await _createSaleDetails(sale.id!);
        final saleDetailsFiltered =
            saleDetails.whereType<SaleDetail>().toList();

        setState(() {
          _selectedProducts.clear();
          _totalSale = 0.0;
          _selectedClient = null;
          _quantityControllers.clear();
          _invoiceNumberController.clear();
          _clientSearchController.clear();
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceScreen(
              sale: sale,
              saleDetails: saleDetailsFiltered,
              products: _productSales,
            ),
          ),
        );
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<List<SaleDetail?>> _createSaleDetails(int saleId) async {
    List<SaleDetail?> saleDetails = [];
    for (var entry in _selectedProducts.entries) {
      int productId = entry.key;
      int quantity = entry.value;

      final detail = await _salesService.createSaleDetail(
        soldProductId: productId,
        quantity: quantity,
        saleId: saleId,
        userId: supabase.auth.currentSession!.user.id,
      );
      saleDetails.add(detail);
    }
    return saleDetails;
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = _products
        .where((product) =>
            product.name!.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar producto',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                int selectedQuantity = _selectedProducts[product.id] ?? 0;

                _quantityControllers.putIfAbsent(
                  product.id!,
                  () =>
                      TextEditingController(text: selectedQuantity.toString()),
                );

                return Card(
                  color: AppPallete.gradient2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            image: const DecorationImage(
                              image: AssetImage('assets/Ejemplo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 80,
                          height: 80,
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(product.name!),
                          subtitle: Text(
                            'Stock: ${product.stockQuantity}, Precio: \$${product.salePrice}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: selectedQuantity > 0
                                    ? () => _removeProductFromSale(product.id!)
                                    : null,
                              ),
                              GestureDetector(
                                onTap: () => _showQuantityDialog(
                                    product, selectedQuantity),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    selectedQuantity.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _addProductToSale(product, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            color: AppPallete.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Total: \$${_totalSale.toStringAsFixed(2)}'),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownSearch<Client>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        menuProps: const MenuProps(
                            backgroundColor: AppPallete.backgroundColor),
                        searchFieldProps: TextFieldProps(
                          controller: _clientSearchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar cliente',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      items: _clients,
                      itemAsString: (client) => client.name ?? '',
                      onChanged: (client) {
                        setState(() {
                          _selectedClient = client;
                        });
                      },
                      selectedItem: _selectedClient,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Cliente',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      filterFn: (client, filter) {
                        return client.name
                                ?.toLowerCase()
                                .contains(filter.toLowerCase()) ??
                            false;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Factura',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _processSale,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Procesar Venta'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
