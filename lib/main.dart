import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/finished_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Task Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF7F9),
        primaryColor: const Color(0xFFF4B6C2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4B6C2),
          foregroundColor: Color(0xFF4A4A4A),
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4B6C2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFADADD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const GetStartedScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/todo': (context) => const TodoScreen(),
        '/add': (context) => const AddTaskScreen(),
        '/finished': (context) => const FinishedScreen(),
      },
    );
  }
}