import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/auth_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _legacyTasksKey = 'tasks';

  Future<String> _tasksKey() async {
    final email = await AuthHelper.currentEmail();
    if (email == null || email.isEmpty) return _legacyTasksKey;
    return 'tasks_$email';
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _tasksKey();
    String? data = prefs.getString(key);

    // Keep tasks saved before per-user storage was added
    if (data == null && key != _legacyTasksKey) {
      data = prefs.getString(_legacyTasksKey);
      if (data != null) {
        await prefs.setString(key, data);
        await prefs.remove(_legacyTasksKey);
      }
    }

    if (data == null) return [];
    final List<dynamic> list = json.decode(data);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    // Auto-increment id
    final int newId = tasks.isEmpty
        ? 1
        : (tasks.map((t) => _asInt(t['id'])).reduce((a, b) => a > b ? a : b) + 1);
    task['id'] = newId;
    tasks.add(task);
    await prefs.setString(await _tasksKey(), json.encode(tasks));
    return newId;
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => _asInt(t['id']) == id);
    if (index != -1) {
      tasks[index] = {...tasks[index], ...data};
      await prefs.setString(await _tasksKey(), json.encode(tasks));
    }
  }

  Future<void> deleteTask(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    tasks.removeWhere((t) => _asInt(t['id']) == id);
    await prefs.setString(await _tasksKey(), json.encode(tasks));
  }

  static bool isDone(Map<String, dynamic> task) {
    final value = task['isDone'];
    return value == 1 || value == true;
  }
}
