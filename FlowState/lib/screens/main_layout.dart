import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_bar.dart';
import '../models/task.dart';
import '../models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_list_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  List<Task> _tasks = [];
  List<Category> _categories = [];

  late final List<Widget> _screens;

  void _refreshTasks() async {
    await _loadTasks();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      TaskListScreen(
        onTaskUpdated: () {
          _refreshTasks();
          if (mounted) setState(() {});
        },
      ),
      const SettingsScreen(),
      const ProfileScreen(),
    ];
    _loadData();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final allTaskKeys = prefs.getKeys().where(
      (key) => key.startsWith('tasks_'),
    );
    List<Task> loadedTasks = [];
    for (final key in allTaskKeys) {
      final tasksJson = prefs.getString(key);
      if (tasksJson != null) {
        final tasksList = jsonDecode(tasksJson) as List;
        loadedTasks.addAll(tasksList.map<Task>((task) => Task.fromJson(task)));
      }
    }
    if (mounted) {
      setState(() {
        _tasks = loadedTasks;
      });
    }
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList('categories') ?? [];

    // Initialize default categories if none exist
    if (categoriesJson.isEmpty) {
      final defaultCategories = [
        Category(
          id: '1',
          name: 'Personal',
          icon: Icons.person,
          color: Colors.blue,
        ),
        Category(
          id: '2',
          name: 'Work',
          icon: Icons.work,
          color: Colors.green,
        ),
        Category(
          id: '3',
          name: 'Shopping',
          icon: Icons.shopping_cart,
          color: Colors.orange,
        ),
        Category(
          id: '4',
          name: 'Coding',
          icon: Icons.code,
          color: Colors.purple,
        ),
        Category(
          id: '5',
          name: 'Health',
          icon: Icons.medical_services,
          color: Colors.red,
        ),
        Category(
          id: '6',
          name: 'Fitness',
          icon: Icons.fitness_center,
          color: Colors.teal,
        ),
      ];

      // Save default categories to SharedPreferences
      final defaultCategoriesJson = defaultCategories
          .map((category) => jsonEncode(category.toJson()))
          .toList();
      await prefs.setStringList('categories', defaultCategoriesJson);

      setState(() {
        _categories = defaultCategories;
      });
      return;
    }

    final loadedCategories =
        categoriesJson.map((e) => Category.fromJson(jsonDecode(e))).toList();
    setState(() {
      _categories = loadedCategories;
    });
  }

  void _loadData() async {
    await _loadTasks();
    await _loadCategories();
  }

  List<Task> _getUpcomingTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tasks.where((task) {
      // Ensure task.isCompleted is not null and task.dueDate is not null
      if (task.dueDate == null) return false;

      // Get task date without time component
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      // Only include tasks due today or tomorrow and not completed
      return (taskDate == today || taskDate == tomorrow) &&
          !(task.isCompleted);
    }).toList();
  }

  void _showNotificationPanel() {
    if (_categories.isEmpty || _tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tasks or categories found')),
      );
      return;
    }

    final upcomingTasks = _getUpcomingTasks();
    final categoryMap = {for (var c in _categories) c.id: c};

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NotificationScreen(
              tasks: upcomingTasks,
              categories: categoryMap,
            ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get upcoming tasks
    final upcomingTasks = _getUpcomingTasks();

    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        actions: [
          if (_currentIndex == 0) // Only show on Task List screen
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: _showNotificationPanel,
                ),
                if (upcomingTasks.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        upcomingTasks.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16), // Add bottom padding
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'FlowState';
      case 1:
        return 'Settings';
      case 2:
        return 'Profile';
      default:
        return 'FlowState';
    }
  }
}
