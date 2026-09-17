import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/vibration_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: Color(0xFFF4B6C2),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final title = _controller.text.trim();

    try {
      // 1️⃣ Save task and use the returned id for the reminder
      final taskId = await DatabaseHelper.instance.insertTask({
        'title': title,
        'dueDate': _selectedDate!.toIso8601String(),
        'isDone': 0,
        'feeling': null,
      });

      // 2️⃣ Schedule notification 1 day before due date
      await NotificationService.scheduleTaskReminder(
        id: taskId,
        taskTitle: title,
        dueDate: _selectedDate!,
      );

      // 3️⃣ Vibrate to confirm save
      await VibrationService.onSave();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task saved! Reminder set for 1 day before 💗'),
          backgroundColor: Color(0xFFF4B6C2),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save task. Please try again.'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentDate = DateFormat('EEEE, MMMM d yyyy').format(now);
    final currentTime = DateFormat('hh:mm a').format(now);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Task 💗")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current date & time
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(currentTime,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A))),
                    const SizedBox(height: 2),
                    Text(currentDate,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF888888))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Task name
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Enter task name",
                  prefixIcon: Icon(Icons.task_alt_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task name cannot be empty';
                  }
                  if (value.trim().length < 3) {
                    return 'Task name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Due date picker
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _selectedDate == null
                        ? "Select Due Date"
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFFF4B6C2)),
                    foregroundColor: const Color(0xFF4A4A4A),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: const [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFF4B6C2)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Your phone will vibrate on save & send a reminder 1 day before due date.",
                      style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveTask,
                  child: _saving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text("Save Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}