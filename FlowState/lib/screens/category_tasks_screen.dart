import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/theme_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

class CategoryTasksScreen extends StatefulWidget {
  final Category category;
  final List<Task> tasks;

  const CategoryTasksScreen({
    super.key,
    required this.category,
    required this.tasks,
  });

  @override
  State<CategoryTasksScreen> createState() => _CategoryTasksScreenState();
}

class _CategoryTasksScreenState extends State<CategoryTasksScreen> {
  late ConfettiController _confettiController;

  List<Alignment> _getRandomAlignments() {
    // Use fixed positions that cover screen nicely
    return [
      Alignment(0, -0.8), // Top center
      Alignment(-0.8, 0), // Left center
      Alignment(0.8, 0), // Right center
    ];
  }

  List<double> _getRandomBlastDirections() {
    // Use fixed directions pointing downward
    return [
      -pi / 2, // Straight down
      -pi / 2.5, // Slightly left
      -pi / 1.8, // Slightly right
    ];
  }

  final List<Color> _confettiColors = const [
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.yellow,
  ];

  Future<void> _addNewTask() async {
    await _vibrate();
    final TextEditingController taskController = TextEditingController();
    DateTime? dueDate;
    TimeOfDay? dueTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'What needs to be done?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                datePickerTheme: DatePickerThemeData(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) setState(() => dueDate = date);
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dueDate == null
                                ? 'Add Due Date'
                                : DateFormat('MMM d, yyyy').format(dueDate!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) setState(() => dueTime = time);
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dueTime == null
                                  ? 'Add Time'
                                  : dueTime!.format(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (taskController.text.trim().isNotEmpty) {
                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: taskController.text.trim(),
                      categoryId: widget.category.id,
                      createdAt: DateTime.now(),
                      dueDate:
                          dueDate != null
                              ? dueTime != null
                                  ? DateTime(
                                    dueDate!.year,
                                    dueDate!.month,
                                    dueDate!.day,
                                    dueTime!.hour,
                                    dueTime!.minute,
                                  )
                                  : DateTime(
                                    dueDate!.year,
                                    dueDate!.month,
                                    dueDate!.day,
                                  )
                              : null,
                    );
                    Navigator.pop(context, newTask);
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Task',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ).then((newTask) async {
      if (newTask != null) {
        setState(() {
          widget.tasks.add(newTask);
        });
        await _saveTasks();
      }
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(
      widget.tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString('tasks_${widget.category.id}', tasksJson);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks_${widget.category.id}');
    if (tasksJson != null) {
      final List<dynamic> tasksList = jsonDecode(tasksJson);
      setState(() {
        widget.tasks.clear();
        widget.tasks.addAll(tasksList.map<Task>((task) => Task.fromJson(task)));
      });
    }
  }

  Color _getCategoryColor() {
    if (widget.category.color is int) {
      return Color(widget.category.color as int);
    } else {
      return widget.category.color;
    }
  
    // Default color if type is unexpected
    return Colors.blue;
  }

  Future<void> _vibrate() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: themeProvider.vibrationDuration);
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    await _vibrate();
    setState(() {
      final index = widget.tasks.indexOf(task);
      widget.tasks[index] = Task(
        id: task.id,
        title: task.title,
        categoryId: task.categoryId,
        createdAt: task.createdAt,
        dueDate: task.dueDate,
        isCompleted: !task.isCompleted,
      );
    });
    await _saveTasks();

    if (widget.tasks.firstWhere((t) => t.id == task.id).isCompleted) {
      Fluttertoast.showToast(
        msg: 'Task Completed!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      _confettiController.play();
    }
  }

  Future<void> _editTask(Task task) async {
    await _vibrate();
    final TextEditingController taskController = TextEditingController(
      text: task.title,
    );
    DateTime? dueDate = task.dueDate;
    TimeOfDay? dueTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'What needs to be done?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                datePickerTheme: DatePickerThemeData(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) setState(() => dueDate = date);
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dueDate == null
                                ? 'Add Due Date'
                                : DateFormat('MMM d, yyyy').format(dueDate!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: dueTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) setState(() => dueTime = time);
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dueTime == null
                                  ? 'Add Time'
                                  : dueTime!.format(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (taskController.text.trim().isNotEmpty) {
                    final editedTask = Task(
                      id: task.id,
                      title: taskController.text.trim(),
                      categoryId: task.categoryId,
                      createdAt: task.createdAt,
                      dueDate:
                          dueDate != null
                              ? dueTime != null
                                  ? DateTime(
                                    dueDate!.year,
                                    dueDate!.month,
                                    dueDate!.day,
                                    dueTime!.hour,
                                    dueTime!.minute,
                                  )
                                  : DateTime(
                                    dueDate!.year,
                                    dueDate!.month,
                                    dueDate!.day,
                                  )
                              : null,
                    );
                    setState(() {
                      final index = widget.tasks.indexOf(task);
                      widget.tasks[index] = editedTask;
                    });
                    Navigator.pop(context);
                    _saveTasks();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    await _vibrate();
    setState(() {
      widget.tasks.remove(task);
    });
    await _saveTasks();
    Fluttertoast.showToast(
      msg: 'Task Deleted!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [categoryColor, categoryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks in this category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: widget.tasks.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex--;
                        final task = widget.tasks.removeAt(oldIndex);
                        widget.tasks.insert(newIndex, task);
                        _saveTasks();
                      });
                    },
                    itemBuilder: (context, index) {
                      final task = widget.tasks[index];
                      return AnimatedContainer(
                        key: Key(task.id),
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? Colors.green.withOpacity(0.05)
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.5),
                              border: task.isCompleted
                                  ? Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 1.5,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: task.isCompleted
                                      ? Colors.green.withOpacity(0.2)
                                      : categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : categoryColor,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _toggleTaskCompletion(task);
                                  },
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? Colors.grey[600]
                                      : null,
                                ),
                              ),
                              subtitle: task.dueDate != null
                                  ? Text(
                                      'Due: ${DateFormat('MMM d, yyyy${task.dueDate!.hour != 0 || task.dueDate!.minute != 0 ? ' h:mm a' : ''}').format(task.dueDate!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: task.isCompleted
                                            ? Colors.grey[500]
                                            : Colors.grey[600],
                                      ),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color:
                                          task.isCompleted
                                              ? Colors.grey[400]
                                              : categoryColor,
                                    ),
                                    onPressed: () {
                                      _editTask(task);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: task.isCompleted
                                          ? Colors.grey[400]
                                          : Colors.red,
                                    ),
                                    onPressed: () {
                                      _deleteTask(task);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                for (final alignment in _getRandomAlignments())
                  Positioned.fill(
                    child: Align(
                      alignment: alignment,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection:
                            _getRandomBlastDirections()[_getRandomAlignments()
                                .indexOf(alignment)],
                        emissionFrequency: 0.03,
                        numberOfParticles: 25,
                        shouldLoop: false,
                        gravity: 0.1,
                        colors: _confettiColors,
                        blastDirectionality: BlastDirectionality.explosive,
                        particleDrag: 0.05,
                        minimumSize: const Size(5, 5),
                        maximumSize: const Size(10, 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: categoryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
