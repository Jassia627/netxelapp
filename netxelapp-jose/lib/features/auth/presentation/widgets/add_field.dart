import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';

class AddItemWidget<T> extends StatefulWidget {
  final String title;
  final List<Widget> inputFields;
  final T Function(List<TextEditingController>) buildItem;

  const AddItemWidget({
    super.key,
    required this.title,
    required this.inputFields,
    required this.buildItem,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddItemWidgetState<T> createState() => _AddItemWidgetState<T>();
}

class _AddItemWidgetState<T> extends State<AddItemWidget<T>> {
  final List<T> _items = [];
  final List<TextEditingController> _controllers = [];

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddDialog() {
    _controllers.clear();
    _controllers
        .addAll(widget.inputFields.map((field) => TextEditingController()));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar ${widget.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...widget.inputFields.asMap().entries.map(
                (entry) {
                  final field = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: field,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final item = widget.buildItem(_controllers);
                setState(() {
                  _items.add(item);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _showAddDialog,
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(400, 50),
            backgroundColor: AppPallete.gradient2,
          ),
          child: Text('Agregar ${widget.title}'),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                color: AppPallete.gradient2,
                child: ListTile(
                  title: Text(item.toString()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
