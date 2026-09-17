import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About App")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "This task manager app helps users plan tasks, track progress, and reflect emotionally on completed tasks using a calm, cute pink interface.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
