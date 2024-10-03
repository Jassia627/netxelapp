import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/categorias%20de%20gastos/expenses_categories_service.dart';

class ExpenseCategoriesPage extends StatefulWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  _ExpenseCategoriesPageState createState() => _ExpenseCategoriesPageState();
}

class _ExpenseCategoriesPageState extends State<ExpenseCategoriesPage> {
  final ExpenseCategoriesService _categoriesService =
      ExpenseCategoriesService();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de la Categoría'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addCategory,
              child: const Text('Agregar Categoría'),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _categoriesService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay categorías registradas'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return Card(
                          color: AppPallete.gradient2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 4),
                          child: ListTile(
                            title: Text(
                              category['name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(category),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteCategory(category['id']),
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

  void _addCategory() async {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      await _categoriesService.addCategory(name);
      _nameController.clear();
      setState(() {});
    } else {
      _showErrorMessage('Por favor, ingrese un nombre para la categoría');
    }
  }

  void _showEditDialog(Map<String, dynamic> category) {
    final editController = TextEditingController(text: category['name']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Categoría'),
          content: TextField(
            controller: editController,
            decoration:
                const InputDecoration(labelText: 'Nombre de la Categoría'),
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
                if (editController.text.isNotEmpty) {
                  await _categoriesService.updateCategory(
                      category['id'], editController.text);
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  _showErrorMessage(
                      'Por favor, ingrese un nombre para la categoría');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int id) async {
    await _categoriesService.deleteCategory(id);
    setState(() {});
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
