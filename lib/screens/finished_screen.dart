import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({super.key});

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  List<Map<String, dynamic>> _finishedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadFinishedTasks();
  }

  Future<void> _loadFinishedTasks() async {
    final data = await DatabaseHelper.instance.getAllTasks();

    setState(() {
      _finishedTasks =
          data.where((task) => task['isDone'] == 1).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finished Tasks 💗")),
      body: _finishedTasks.isEmpty
          ? const Center(child: Text("No finished tasks yet"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _finishedTasks.length,
        itemBuilder: (context, index) {
          final task = _finishedTasks[index];
          DateTime dueDate =
          DateTime.parse(task['dueDate']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Due: ${DateFormat('yyyy-MM-dd').format(dueDate)}",
                ),
                const SizedBox(height: 6),
                Text(
                  "Feeling: ${task['feeling'] ?? '-'}",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
