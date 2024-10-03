// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/puchases/puchase_dialog.dart';
import 'package:netxelapp/features/home/pages/puchases/puchases_services.dart';

class RawMaterialPurchasesPage extends StatefulWidget {
  @override
  _RawMaterialPurchasesPageState createState() =>
      _RawMaterialPurchasesPageState();
}

class _RawMaterialPurchasesPageState extends State<RawMaterialPurchasesPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _purchases = [];
  List<Map<String, dynamic>> _filteredPurchases = [];

  // Filtros
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProvider;
  String? _selectedRawMaterial;

  // Listas para los dropdowns
  List<String> _providers = [];
  List<String> _rawMaterials = [];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final purchases = await _supabaseService.getRawMaterialPuchases();
    setState(() {
      _purchases = purchases;
      _filteredPurchases = purchases;
      _updateFilterLists();
    });
  }

  void _updateFilterLists() {
    _providers = _purchases
        .map((p) => p['provider_name']?.toString() ?? '')
        .toSet()
        .toList();
    _rawMaterials = _purchases
        .map((p) => p['raw_material_name']?.toString() ?? '')
        .toSet()
        .toList();
  }

  void _applyFilters() {
    setState(() {
      _filteredPurchases = _purchases.where((purchase) {
        final purchaseDate =
            DateTime.tryParse(purchase['created_at'].toString());

        // Filtro de fecha
        bool dateFilter = true;
        if (purchaseDate != null) {
          if (_startDate != null && _endDate != null) {
            dateFilter = purchaseDate
                    .isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                purchaseDate.isBefore(_endDate!.add(const Duration(days: 1)));
          } else if (_startDate != null) {
            dateFilter = purchaseDate
                .isAfter(_startDate!.subtract(const Duration(days: 1)));
          } else if (_endDate != null) {
            dateFilter =
                purchaseDate.isBefore(_endDate!.add(const Duration(days: 1)));
          }
        }

        final providerFilter = _selectedProvider == null ||
            purchase['provider_name'] == _selectedProvider;
        final rawMaterialFilter = _selectedRawMaterial == null ||
            purchase['raw_material_name'] == _selectedRawMaterial;

        return dateFilter && providerFilter && rawMaterialFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0.00", "es_ES");
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total de compras: ${_filteredPurchases.length}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterDialog,
                    tooltip: 'Filtrar compras',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredPurchases.length,
                itemBuilder: (context, index) {
                  final purchase = _filteredPurchases[index];
                  final date = purchase['created_at'] != null
                      ? DateTime.tryParse(purchase['created_at'].toString())
                      : null;
                  final formattedDate = date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Fecha no disponible';

                  return Card(
                    color: AppPallete.gradient2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  purchase['raw_material_name']?.toString() ??
                                      'Insumo desconocido',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Text('Fecha: $formattedDate'),
                                const SizedBox(height: 4),
                                Text(
                                    'Proveedor: ${purchase['provider_name']?.toString() ?? 'Desconocido'}'),
                                const SizedBox(height: 4),
                                Text(
                                    'Cantidad: ${purchase['quantity']?.toString() ?? 'N/A'}'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${(purchase['total'] as num?) != null ? numberFormat.format(purchase['total']) : 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: AppPallete.whiteColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Total',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPallete.gradient2,
        onPressed: () => _showAddPurchaseDialog(context),
        tooltip: 'Agregar Compra',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPurchaseDialog(
          onPurchaseAdded: () {
            _loadPurchases();
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtrar Compras'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Fecha Inicio'),
                      subtitle: Text(_startDate == null
                          ? 'No seleccionada'
                          : DateFormat('dd/MM/yyyy').format(_startDate!)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Fecha Fin'),
                      subtitle: Text(_endDate == null
                          ? 'No seleccionada'
                          : DateFormat('dd/MM/yyyy').format(_endDate!)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedProvider,
                      hint: const Text('Seleccionar Proveedor'),
                      items: [
                        const DropdownMenuItem(
                            child: Text('Todos'), value: null),
                        ..._providers
                            .map((provider) => DropdownMenuItem(
                                value: provider, child: Text(provider)))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedProvider = value);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedRawMaterial,
                      hint: Text('Seleccionar Insumo'),
                      items: [
                        DropdownMenuItem(child: Text('Todos'), value: null),
                        ..._rawMaterials
                            .map((material) => DropdownMenuItem(
                                child: Text(material), value: material))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRawMaterial = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.white)),
                    backgroundColor:
                        MaterialStateProperty.all(AppPallete.gradient2),
                  ),
                  onPressed: () {
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
