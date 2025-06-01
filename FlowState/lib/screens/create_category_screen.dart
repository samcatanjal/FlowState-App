import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CreateCategoryScreen extends StatefulWidget {
  final Function(Category) onCategoryCreated;

  const CreateCategoryScreen({super.key, required this.onCategoryCreated});

  @override
  _CreateCategoryScreenState createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  final List<IconData> _icons = [
    Icons.work,
    Icons.shopping_cart,
    Icons.home,
    Icons.fitness_center,
    Icons.school,
    Icons.local_dining,
    Icons.directions_car,
    Icons.medical_services,
  ];

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Select Icon:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _icons.map((icon) {
                  return IconButton(
                    icon: Icon(icon, size: 30),
                    color: _selectedIcon == icon ? _selectedColor : Colors.grey,
                    onPressed: () => setState(() => _selectedIcon = icon),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Select Color:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveCategory,
                child: const Text('Create Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getStringList('categories') ?? [];
      categoriesJson.add(jsonEncode(newCategory.toJson()));
      prefs.setStringList('categories', categoriesJson);

      widget.onCategoryCreated(newCategory);
      Navigator.pop(context);
    }
  }
}
