// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netxelapp/features/home/Entities/sales.dart';
import 'package:netxelapp/features/home/pages/sales/invoice_screen.dart';
import 'package:netxelapp/features/home/pages/sales/sales_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  _SalesHistoryScreenState createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final SalesService _salesService = SalesService();
  List<Sale> _confirmedSales = [];
  List<Sale> _unconfirmedSales = [];
  List<Sale> _filteredConfirmedSales = [];
  List<Sale> _filteredUnconfirmedSales = [];
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedClientName;
  List<String> _clientNames = [];

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    print('Iniciando carga de ventas');
    setState(() {
      _isLoading = true;
    });

    try {
      List<Sale> allSales = await _salesService.getSales();
      print('Ventas cargadas: ${allSales.length}');

      _confirmedSales =
          allSales.where((sale) => sale.confirmed == true).toList();
      _unconfirmedSales =
          allSales.where((sale) => sale.confirmed != true).toList();

      _filteredConfirmedSales = List.from(_confirmedSales);
      _filteredUnconfirmedSales = List.from(_unconfirmedSales);

      _clientNames = allSales
          .map((sale) => sale.client ?? 'Sin cliente')
          .where((client) => client.isNotEmpty)
          .toSet()
          .toList();

      print('Ventas confirmadas: ${_confirmedSales.length}');
      print('Ventas no confirmadas: ${_unconfirmedSales.length}');
      print('Clientes: ${_clientNames.length}');
    } catch (e, stackTrace) {
      print('Error al cargar ventas: $e');
      print('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('Carga de ventas finalizada');
    }
  }

  void _filterSales() {
    _filteredConfirmedSales = _filterSalesList(_confirmedSales);
    _filteredUnconfirmedSales = _filterSalesList(_unconfirmedSales);
    setState(() {});
  }

  List<Sale> _filterSalesList(List<Sale> sales) {
    return sales.where((sale) {
      final saleDate = sale.createdAt;
      final clientName = sale.client;

      bool dateFilter = true;
      if (_startDate != null) {
        dateFilter = dateFilter &&
            saleDate!.isAfter(_startDate!.subtract(const Duration(days: 1)));
      }
      if (_endDate != null) {
        dateFilter = dateFilter &&
            saleDate!.isBefore(_endDate!.add(const Duration(days: 1)));
      }

      bool clientFilter =
          _selectedClientName == null || clientName == _selectedClientName;

      return dateFilter && clientFilter;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
      _filterSales();
    }
  }

  Future<void> _confirmSale(Sale sale) async {
    setState(() {
      _isLoading = true;
    });

    bool success = await _salesService.confirmSale(sale.id!);

    if (success) {
      setState(() {
        _unconfirmedSales.remove(sale);
        _filteredUnconfirmedSales.remove(sale);
        sale.confirmed = true;
        _confirmedSales.add(sale);
        _filteredConfirmedSales.add(sale);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildSaleList(List<Sale> sales, bool isConfirmed) {
    return ListView.builder(
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return ListTile(
          title: Text('Factura #${sale.numeroFactura}   -   ${sale.client}'),
          subtitle: Text('Fecha: ${_dateFormat.format(sale.createdAt!)}'),
          trailing: Text(
            '\$${sale.total?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          onTap: () async {
            final saleDetails =
                await _salesService.getSaleDetailBySaleId(sale.id!);
            final productSales =
                await _salesService.getProductsBySaleId(sale.id!);

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceScreen(
                    sale: sale,
                    saleDetails: saleDetails,
                    products: productSales,
                    onConfirm: isConfirmed ? null : () => _confirmSale(sale),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(text: 'No Confirmadas'),
            Tab(text: 'Confirmadas'),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha inicio',
                          hintText: 'Seleccionar fecha',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _startDate != null
                              ? _dateFormat.format(_startDate!)
                              : '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha fin',
                          hintText: 'Seleccionar fecha',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _endDate != null ? _dateFormat.format(_endDate!) : '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedClientName,
                onChanged: (value) {
                  setState(() {
                    _selectedClientName = value;
                  });
                  _filterSales();
                },
                items: ['Todos', ..._clientNames]
                    .map((clientName) => DropdownMenuItem(
                          value: clientName == 'Todos' ? null : clientName,
                          child: Text(clientName),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildSaleList(_filteredUnconfirmedSales, false),
                        _buildSaleList(_filteredConfirmedSales, true),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
