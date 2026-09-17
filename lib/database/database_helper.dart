import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _tasksKey = 'tasks';

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_tasksKey);
    if (data == null) return [];
    final List<dynamic> list = json.decode(data);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    // Auto-increment id
    final int newId = tasks.isEmpty
        ? 1
        : (tasks.map((t) => t['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    task['id'] = newId;
    tasks.add(task);
    await prefs.setString(_tasksKey, json.encode(tasks));
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      tasks[index] = {...tasks[index], ...data};
      await prefs.setString(_tasksKey, json.encode(tasks));
    }
  }

  Future<void> deleteTask(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    tasks.removeWhere((t) => t['id'] == id);
    await prefs.setString(_tasksKey, json.encode(tasks));
  }
}