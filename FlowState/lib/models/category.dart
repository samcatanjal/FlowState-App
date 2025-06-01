import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int taskCount;
  final int completedTasks;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.taskCount = 0,
    this.completedTasks = 0,
  });

  // Convert a Category into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'iconFontPackage': icon.fontPackage,
        'colorValue': color.value,
        'taskCount': taskCount,
        'completedTasks': completedTasks,
      };

  // Create a Category from a map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
      ),
      color: Color(json['colorValue']),
      taskCount: json['taskCount'],
      completedTasks: json['completedTasks'],
    );
  }
}
