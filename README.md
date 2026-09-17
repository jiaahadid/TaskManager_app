# Task Manager

A Flutter planner app for creating tasks, tracking what’s done, and reflecting on how each task felt. The UI uses a calm pink theme.

**Repo:** [https://github.com/jiaahadid/task-manager-app1](https://github.com/jiaahadid/task-manager-app1)

## Features

- Sign up, log in, and stay signed in until you log out
- Each account keeps its own tasks
- Add, edit, and delete to-do items with due dates
- Complete a task and save a short feeling note
- Home screen shows upcoming tasks and a daily quote
- Reminder notification 1 day before a task is due
- Phone vibration when you save, complete, or delete a task

## Screens

| Screen | What it does |
| --- | --- |
| Get Started | Welcome page |
| Sign Up / Login | Create an account or sign in |
| Home | Quote, upcoming tasks, and shortcuts |
| To-Do | Active tasks, add/edit/delete/complete |
| Add Task | Task name and due date |
| Finished | Completed tasks and feelings |

## Run the app

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Open this folder
3. Get packages and run:

```bash
flutter pub get
flutter run
```

Use a connected Android device or an emulator. Chrome also works for a web preview:

```bash
flutter run -d chrome
```

## Built with

- Flutter / Dart
- Shared Preferences for local accounts and tasks
- Flutter Local Notifications for due-date reminders
- ZenQuotes API for the home-screen quote
