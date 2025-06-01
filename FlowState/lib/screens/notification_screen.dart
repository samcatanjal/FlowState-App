import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/category.dart';

class NotificationScreen extends StatefulWidget {
  final List<Task> tasks;
  final Map<String, Category> categories;

  const NotificationScreen({
    super.key,
    required this.tasks,
    required this.categories,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Timer _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Tasks are already filtered when passed to this screen
    final todayTasks = widget.tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate == today;
    }).toList();

    final tomorrowTasks = widget.tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate == tomorrow;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Today', todayTasks.length),
            ..._buildTaskList(todayTasks, context),
            _buildSectionHeader('Tomorrow', tomorrowTasks.length),
            ..._buildTaskList(tomorrowTasks, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count Tasks',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C757D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList(List<Task> tasks, BuildContext context) {
    if (tasks.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'No tasks for this day',
            style: GoogleFonts.poppins(
              color: const Color(0xFF6C757D),
              fontSize: 14,
            ),
          ),
        ),
      ];
    }

    return tasks.map((task) {
      final category = widget.categories[task.categoryId];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category?.color.withOpacity(0.1) ?? const Color(0xFFE9ECEF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category?.icon ?? Icons.category,
              color: category?.color ?? const Color(0xFF6C757D),
              size: 20,
            ),
          ),
          title: Text(
            task.title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                task.description ?? '',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6C757D),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(task.dueDate ?? DateTime.now()),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6C757D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE9ECEF),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: task.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF198754),
                  )
                : null,
          ),
          onTap: () {
            // Handle task tap
          },
        ),
      );
    }).toList();
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}
