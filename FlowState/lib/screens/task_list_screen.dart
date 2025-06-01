import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../providers/theme_provider.dart';
import 'create_category_screen.dart';
import 'category_tasks_screen.dart';

class TaskListScreen extends StatefulWidget {
  final VoidCallback? onTaskUpdated;

  const TaskListScreen({super.key, this.onTaskUpdated});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  final Map<String, bool> _tappedCards = {};
  final Map<String, List<Color>> _gradientCache = {};

  List<Color> _getCachedGradient(Color baseColor) {
    if (!_gradientCache.containsKey(baseColor.toARGB32().toString())) {
      _gradientCache[baseColor.toARGB32().toString()] = [
        baseColor.withAlpha(128),
        baseColor.withAlpha(128),
      ];
    }
    return _gradientCache[baseColor.toARGB32().toString()]!;
  }

  Future<void> _vibrate() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: themeProvider.vibrationDuration);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTasks();
    _filteredTasks = _tasks;
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks =
          _tasks.where((task) {
            return task.title.toLowerCase().contains(query) ||
                (task.description?.toLowerCase().contains(query) ?? false);
          }).toList();
    });
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList('categories') ?? [];
    final loadedCategories =
        categoriesJson.map((e) => Category.fromJson(jsonDecode(e))).toList();
    setState(() {
      _categories = loadedCategories;
      _filteredCategories = loadedCategories;
    });
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
        final List<dynamic> tasksList = jsonDecode(tasksJson);
        loadedTasks.addAll(tasksList.map<Task>((task) => Task.fromJson(task)));
      }
    }
    setState(() {
      _tasks = loadedTasks;
      _filteredTasks = loadedTasks;
    });
  }

  void _addCategory(Category newCategory) async {
    setState(() {
      _categories.add(newCategory);
      _filteredCategories = _categories;
    });
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson =
        _categories.map((cat) => jsonEncode(cat.toJson())).toList();
    prefs.setStringList('categories', categoriesJson);
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories =
          _categories
              .where(
                (cat) => cat.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Category category, {
    Key? key,
  }) {
    final taskCount =
        _filteredTasks.where((task) => task.categoryId == category.id).length;
    final completedTasks =
        _filteredTasks
            .where((task) => task.categoryId == category.id && task.isCompleted)
            .length;

    final progress = taskCount > 0 ? completedTasks / taskCount : 0.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth / 2) -
        24; // Two cards per row with 16px spacing and 8px margin

    _tappedCards.putIfAbsent(category.id, () => false);

    return GestureDetector(
      onTapDown: (_) => setState(() => _tappedCards[category.id] = true),
      onTapUp: (_) => setState(() => _tappedCards[category.id] = false),
      onTapCancel: () => setState(() => _tappedCards[category.id] = false),
      onTap: () async {
        await _vibrate();
        final categoryTasks =
            _filteredTasks.where((t) => t.categoryId == category.id).toList();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CategoryTasksScreen(
                  category: category,
                  tasks: categoryTasks,
                ),
          ),
        );
        await _vibrate(); // Feedback when returning
        await _loadTasks();
        await _loadCategories();
      },
      child: AnimatedContainer(
        key: key,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: cardWidth,
        transform:
            Matrix4.identity()..scale(_tappedCards[category.id]! ? 0.95 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getCachedGradient(category.color),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Semantics(
                      label: 'View ${category.name} tasks',
                      child: AnimatedBuilder(
                        animation: AlwaysStoppedAnimation(2),
                        builder: (context, child) {
                          final scale =
                              1.0 +
                              (0.1 *
                                  sin(
                                    DateTime.now().millisecondsSinceEpoch / 500,
                                  ));
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: 'Category ${category.name}',
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                  semanticsLabel:
                      'Progress ${(progress * 100).toStringAsFixed(0)}%',
                ),
                const SizedBox(height: 8),
                Text(
                  taskCount == 0
                      ? 'No tasks yet'
                      : '$completedTasks of $taskCount completed',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  semanticsLabel:
                      taskCount == 0
                          ? 'No tasks in this category'
                          : '$completedTasks out of $taskCount tasks completed',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _filterCategories(query);
                  _filterTasks();
                },
                decoration: InputDecoration(
                  hintText: 'Search Categories...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterCategories('');
                              _filterTasks();
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  constraints: const BoxConstraints(maxHeight: 50),
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    setState(() {});
                  }
                  return true;
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _filteredCategories.isEmpty
                          ? Center(
                            key: const ValueKey('empty'),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 72,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Categories Found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ReorderableWrap(
                            spacing: 16,
                            runSpacing: 16,
                            padding: const EdgeInsets.all(16),
                            children:
                                _filteredCategories
                                    .map(
                                      (category) => _buildCategoryCard(
                                        context,
                                        category,
                                        key: ValueKey(category.id),
                                      ),
                                    )
                                    .toList(),
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                final item = _filteredCategories.removeAt(
                                  oldIndex,
                                );
                                _filteredCategories.insert(newIndex, item);
                                HapticFeedback.lightImpact();
                              });
                            },
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _vibrate();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      CreateCategoryScreen(onCategoryCreated: _addCategory),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 10,
        highlightElevation: 15,
        splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
