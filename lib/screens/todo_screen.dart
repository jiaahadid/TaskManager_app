import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/vibration_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _tasks = data.where((task) => task['isDone'] == 0).toList();
    });
  }

  Future<void> _goToAddTask() async {
    await Navigator.pushNamed(context, '/add');
    _loadTasks();
  }

  Future<void> _completeTask(Map<String, dynamic> task) async {
    String? feeling = await _askFeeling(context);
    if (feeling != null && feeling.isNotEmpty) {
      await DatabaseHelper.instance.updateTask(task['id'], {
        'isDone': 1,
        'feeling': feeling,
      });
      await NotificationService.cancelNotification(task['id'] as int);
      await VibrationService.onComplete(); // long satisfying buzz
      _loadTasks();
    }
  }

  Future<void> _editTask(Map<String, dynamic> task) async {
    final titleController = TextEditingController(text: task['title']);
    DateTime selectedDate = DateTime.parse(task['dueDate']);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Edit Task 💗"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Task name",
                      prefixIcon: Icon(Icons.task_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFF4B6C2)),
                        foregroundColor: const Color(0xFF4A4A4A),
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().length < 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task name must be at least 3 characters'),
                          backgroundColor: Color(0xFFF4B6C2),
                        ),
                      );
                      return;
                    }
                    await DatabaseHelper.instance.updateTask(task['id'], {
                      'title': titleController.text.trim(),
                      'dueDate': selectedDate.toIso8601String(),
                    });
                    // Reschedule notification with updated date
                    await NotificationService.cancelNotification(task['id'] as int);
                    await NotificationService.scheduleTaskReminder(
                      id: task['id'] as int,
                      taskTitle: titleController.text.trim(),
                      dueDate: selectedDate,
                    );
                    await VibrationService.onSave(); // buzz on edit save too
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadTasks();
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTask(Map<String, dynamic> task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Task?"),
        content: Text(
            'Are you sure you want to delete "${task['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationService.cancelNotification(task['id'] as int);
      await DatabaseHelper.instance.deleteTask(task['id']);
      await VibrationService.onDelete(); // double buzz on delete
      _loadTasks();
    }
  }

  Future<String?> _askFeeling(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How did you feel? 💗"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Happy, tired, proud...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do Tasks 💗")),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTask,
        backgroundColor: const Color(0xFFF4B6C2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text("No tasks yet"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final dueDate = DateTime.parse(task['dueDate']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFADADD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  activeColor: const Color(0xFFF4B6C2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (_) async => await _completeTask(task),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Due: ${DateFormat('yyyy-MM-dd').format(dueDate)}",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Color(0xFFF4B6C2), size: 20),
                  tooltip: "Edit",
                  onPressed: () => _editTask(task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFE57373), size: 20),
                  tooltip: "Delete",
                  onPressed: () => _deleteTask(task),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}