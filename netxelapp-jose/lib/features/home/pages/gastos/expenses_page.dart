import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'expenses_service.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final ExpensesService _expensesService = ExpensesService();
  final _descriptionController = TextEditingController();
  final MoneyMaskedTextController _valueController = MoneyMaskedTextController(
      decimalSeparator: '',
      thousandSeparator: '.',
      leftSymbol: '\$ ',
      precision: 0);
  final numberFormat = NumberFormat("#,##0", "es_ES");

  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await _expensesService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addExpense,
              child: const Text('Agregar Gasto'),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _expensesService.getExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay gastos registrados'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final expense = snapshot.data![index];
                        return Card(
                          color: AppPallete.gradient2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 4),
                          child: ListTile(
                            title: Text(expense['description']),
                            subtitle: Text(
                                'Categoría: ${_getCategoryName(expense['expense_category_id'])}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${(expense['value'] as num?) != null ? numberFormat.format(expense['value']) : 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(expense),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteExpense(expense['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() async {
    final description = _descriptionController.text;
    final value = _valueController.numberValue;

    if (description.isNotEmpty && value > 0 && _selectedCategoryId != null) {
      await _expensesService.addExpense(
          description, value, _selectedCategoryId!);
      _clearFields();
      setState(() {});
    } else {
      _showErrorMessage('Por favor, complete todos los campos correctamente');
    }
  }

  void _showEditDialog(Map<String, dynamic> expense) {
    final editDescriptionController =
        TextEditingController(text: expense['description']);
    final editValueController = MoneyMaskedTextController(
      initialValue: expense['value'],
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: '€ ',
      precision: 2,
    );
    int? editCategoryId = expense['expense_category_id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Gasto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editDescriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: editValueController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<int>(
                  value: editCategoryId,
                  onChanged: (value) {
                    editCategoryId = value;
                  },
                  items: _categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final newDescription = editDescriptionController.text;
                final newValue = editValueController.numberValue;
                if (newDescription.isNotEmpty &&
                    newValue > 0 &&
                    editCategoryId != null) {
                  await _expensesService.updateExpense(
                    expense['id'],
                    newDescription,
                    newValue,
                    editCategoryId!,
                  );
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  _showErrorMessage(
                      'Por favor, complete todos los campos correctamente');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int id) async {
    await _expensesService.deleteExpense(id);
    setState(() {});
  }

  void _clearFields() {
    _descriptionController.clear();
    _valueController.updateValue(0);
    _selectedCategoryId = null;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getCategoryName(int categoryId) {
    final category = _categories.firstWhere((c) => c['id'] == categoryId,
        orElse: () => {'name': 'Desconocida'});
    return category['name'];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
