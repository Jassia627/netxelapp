// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_element

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:netxelapp/features/home/Entities/produced_products.dart';
import 'package:netxelapp/features/home/pages/recipes/services/products_service.dart';

class ProductPickerDialog extends StatefulWidget {
  final List<ProducedProduct> selectedProducts;
  final Function(List<ProducedProduct>) onProductsSelected;

  const ProductPickerDialog({
    super.key,
    required this.selectedProducts,
    required this.onProductsSelected,
  });

  @override
  _ProductPickerDialogState createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<ProductPickerDialog> {
  late List<ProducedProduct> _selectedProducts;
  List<Map<String, dynamic>> _availableProducts = [];
  final ProductRepository productRepository = ProductRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProducts = widget.selectedProducts;
    _fetchAvailableProducts();
  }

  Future<void> _fetchAvailableProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await productRepository.getAllProducts();
      setState(() {
        _availableProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener los productos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateProductQuantity(int productIndex, int newQuantity) {
    setState(() {
      _selectedProducts[productIndex].quantity = newQuantity;
    });
  }

  void _addProduct(Map<String, dynamic> productData) {
    setState(() {
      _selectedProducts.add(ProducedProduct(
        productId: productData['id'],
        quantity: 1,
        recipeId: 1,
        userId: '',
        name: productData['name'],
      ));
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar productos'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<String>.multiSelection(
                    items: _availableProducts
                        .map((product) => product['name'] as String)
                        .toList(),
                    popupProps: const PopupPropsMultiSelection.menu(
                      showSelectedItems: true,
                    ),
                    onChanged: (selectedItems) {
                      setState(() {
                        _selectedProducts = selectedItems
                            .map((name) => _availableProducts.firstWhere(
                                (product) => product['name'] == name))
                            .map((productData) => ProducedProduct(
                                  productId: productData['id'],
                                  quantity: 1,
                                  recipeId: 1,
                                  userId: '',
                                  name: productData['name'],
                                ))
                            .toList();
                      });
                    },
                    selectedItems: _selectedProducts
                        .map((product) => product.name)
                        .toList(),
                  ),
                  const SizedBox(height: 16.0),
                  ..._selectedProducts.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: Text(product.name),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateProductQuantity(
                                  index, int.parse(value)),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cantidad',
                              ),
                              controller: TextEditingController(
                                  text: product.quantity.toString()),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeProduct(index),
                            icon: const Icon(Icons.remove_circle),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onProductsSelected(_selectedProducts);
            Navigator.pop(context);
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
