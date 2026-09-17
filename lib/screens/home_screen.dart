import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/auth_helper.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<String> _quoteFuture;
  List<Map<String, dynamic>> _upcomingTasks = [];

  @override
  void initState() {
    super.initState();
    _quoteFuture = ApiService.fetchQuote();
    _loadUpcomingTasks();
  }

  Future<void> _loadUpcomingTasks() async {
    final data = await DatabaseHelper.instance.getAllTasks();
    final now = DateTime.now();

    final upcoming = data
        .where((task) => !DatabaseHelper.isDone(task))
        .map((task) => {
      ...task,
      '_parsedDate': DateTime.tryParse(task['dueDate']?.toString() ?? '') ?? now,
    })
        .where((task) =>
    (task['_parsedDate'] as DateTime).isAfter(now) ||
        DateFormat('yyyy-MM-dd')
            .format(task['_parsedDate'] as DateTime) ==
            DateFormat('yyyy-MM-dd').format(now))
        .toList();

    upcoming.sort((a, b) => (a['_parsedDate'] as DateTime)
        .compareTo(b['_parsedDate'] as DateTime));

    if (mounted) {
      setState(() => _upcomingTasks = upcoming);
    }
  }

  void _refreshQuote() {
    setState(() {
      _quoteFuture = ApiService.fetchQuote();
    });
  }

  String _getDueLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    final diff = taskDay.difference(today).inDays;

    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Due Tomorrow';
    if (diff <= 7) return 'Due in $diff days';
    return 'Due ${DateFormat('MMM d').format(date)}';
  }

  Color _getDueColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    final diff = taskDay.difference(today).inDays;

    if (diff == 0) return const Color(0xFFE57373); // red - today
    if (diff <= 2) return const Color(0xFFFFB74D); // orange - very soon
    return const Color(0xFF81C784); // green - plenty of time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Planner 💗"),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthHelper.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshQuote();
          await _loadUpcomingTasks();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quote Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FutureBuilder<String>(
                future: _quoteFuture,
                builder: (context, snapshot) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("✨ ", style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: snapshot.connectionState ==
                            ConnectionState.waiting
                            ? const Text(
                          "Fetching your daily inspiration...",
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF888888),
                          ),
                        )
                            : Text(
                          snapshot.data ??
                              '"Stay productive today!" 💗',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _refreshQuote,
                        child: const Icon(Icons.refresh,
                            size: 18, color: Color(0xFFF4B6C2)),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Tasks",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _upcomingTasks.isEmpty
                ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFADADD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "No upcoming tasks 🎉\nYou're all caught up!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888)),
                ),
              ),
            )
                : Column(
              children: _upcomingTasks.map((task) {
                final date = task['_parsedDate'] as DateTime;
                final dueLabel = _getDueLabel(date);
                final dueColor = _getDueColor(date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFADADD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt_outlined,
                          color: Color(0xFFF4B6C2), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: dueColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: dueColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          dueLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: dueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Navigation Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/todo');
                  _loadUpcomingTasks();
                },
                child: const Text("View To-Do Tasks"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/finished');
                  _loadUpcomingTasks();
                },
                child: const Text("Finished Tasks"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}