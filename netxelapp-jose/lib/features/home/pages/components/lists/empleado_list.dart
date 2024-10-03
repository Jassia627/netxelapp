// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/components/forms/empleado_form.dart';
import 'package:netxelapp/main.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({super.key});

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  final _client = supabase;
  List<Map<String, dynamic>> _employees = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _client
            .from('employees')
            .select('*')
            .eq('active', true)
            .order('name');

        setState(() {
          _employees = response;
          _isLoading = false;
        });
      } else {
        // Manejar caso cuando no hay una sesión de usuario válida
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar error
    }
  }

  Future<void> _addEmployee(
      String name, String lastname, String identification, String phone) async {
    try {
      await supabase.from('employees').insert({
        'name': name,
        'lastname': lastname,
        'identification': identification,
        'phone': phone,
        'user_id': supabase.auth.currentUser?.id,
      });
      _fetchEmployees();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // Manejar error
    }
  }

  Future<void> _updateEmployee(int index, String name, String lastname,
      String identification, String phone) async {
    try {
      final employeeId = _employees[index]['id'];
      await _client.from('employees').update({
        'name': name,
        'lastname': lastname,
        'identification': identification,
        'phone': phone,
        'user_id': supabase.auth.currentUser?.id,
      }).eq('id', employeeId);
      _fetchEmployees();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _deleteEmployee(int index) async {
    try {
      final employeeId = _employees[index]['id'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar empleado'),
            content: Text(
                '¿Estás seguro de eliminar al empleado "${_employees[index]['name']} ${_employees[index]['lastname']}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _client
                      .from('employees')
                      .update({'active': false}).eq('id', employeeId);
                  Navigator.of(context).pop();
                  _fetchEmployees();
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

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = _employees.where((employee) {
      final employeeName =
          '${employee['name']} ${employee['lastname']}'.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return employeeName.contains(query);
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
                      labelText: 'Buscar empleado',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: ListTile(
                          title: Text(
                              '${employee['name']} ${employee['lastname']}'),
                          subtitle: Text(
                              'Identificación: ${employee['identification']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EmployeeForm(
                                      employee: employee,
                                      onEmployeeUpdated: (name, lastname,
                                              identification, phone) =>
                                          _updateEmployee(index, name, lastname,
                                              identification, phone),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteEmployee(index),
                              ),
                            ],
                          ),
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
                        builder: (context) => EmployeeForm(
                          onEmployeeAdded: _addEmployee,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Agregar Empleado'),
                  ),
                ),
              ],
            ),
    );
  }
}
