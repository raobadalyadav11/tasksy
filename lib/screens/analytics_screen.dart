import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  List<Task> tasks = [];
  List<Habit> habits = [];
  bool isLoading = true;
  String selectedPeriod = 'Week';
  late TabController _tabController;

  final List<String> periods = ['Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedTasks = await StorageService.getTasks();
    final loadedHabits = await StorageService.getHabits();
    setState(() {
      tasks = loadedTasks;
      habits = loadedHabits;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tasks'),
            Tab(text: 'Habits'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedPeriod,
            onSelected: (value) => setState(() => selectedPeriod = value),
            itemBuilder: (context) => periods
                .map(
                  (period) => PopupMenuItem(value: period, child: Text(period)),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildTasksTab(), _buildHabitsTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final activeHabits = habits.length;
    final totalStreak = habits.fold(0, (sum, habit) => sum + habit.streak);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildSummaryCard(
                'Total Tasks',
                totalTasks.toString(),
                Icons.task_alt,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Completed',
                completedTasks.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildSummaryCard(
                'Active Habits',
                activeHabits.toString(),
                Icons.track_changes,
                Colors.orange,
              ),
              _buildSummaryCard(
                'Total Streaks',
                totalStreak.toString(),
                Icons.local_fire_department,
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Productivity Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productivity Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: _buildProductivityChart()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.length - completedTasks;
    final categoryData = _getTaskCategoryData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Task Completion Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Completion',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: completedTasks.toDouble(),
                            title: 'Completed\n$completedTasks',
                            color: Colors.green,
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            value: pendingTasks.toDouble(),
                            title: 'Pending\n$pendingTasks',
                            color: Colors.orange,
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...categoryData.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsTab() {
    final totalHabits = habits.length;
    final completedToday = habits.where((h) => h.isCompletedToday).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Habit Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total Habits',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$totalHabits',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Completed Today',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$completedToday',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Habit Progress
          if (habits.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habit Streaks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...habits
                        .map(
                          (habit) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      habit.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${habit.streak} days',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value:
                                      habit.streak /
                                      30, // Assuming 30 days as max for visualization
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.orange,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No habits to analyze yet. Create some habits to see progress!',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityChart() {
    final last7Days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayTasks = tasks
          .where(
            (task) =>
                task.createdAt.year == date.year &&
                task.createdAt.month == date.month &&
                task.createdAt.day == date.day,
          )
          .length;
      return FlSpot(index.toDouble(), dayTasks.toDouble());
    });

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[value.toInt() % 7]);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: last7Days,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getTaskCategoryData() {
    final categoryCount = <String, int>{};
    for (final task in tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }
    return categoryCount;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
