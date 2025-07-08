import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../services/popup_service.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_card.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  bool isLoading = true;
  BannerAd? _bannerAd;
  String selectedFilter = 'All';
  String searchQuery = '';
  int completedTasksCount = 0;

  final List<String> filters = ['All', 'Today', 'Pending', 'Completed'];
  final List<String> categories = ['All', 'Personal', 'Work', 'Health', 'Shopping'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (_) => setState(() {}),
    );
    _bannerAd?.load();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await StorageService.getTasks();
    setState(() {
      tasks = loadedTasks;
      _filterTasks();
      isLoading = false;
    });
    
    // Check for overdue tasks and send notifications
    for (final task in loadedTasks) {
      if (!task.isCompleted && task.dueDate != null && task.dueDate!.isBefore(DateTime.now())) {
        await NotificationService.scheduleOverdueReminder(task);
      }
    }
  }

  void _filterTasks() {
    filteredTasks = tasks.where((task) {
      bool matchesFilter = true;
      bool matchesSearch = task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          task.description.toLowerCase().contains(searchQuery.toLowerCase());

      switch (selectedFilter) {
        case 'Today':
          final today = DateTime.now();
          matchesFilter = task.dueDate != null &&
              task.dueDate!.year == today.year &&
              task.dueDate!.month == today.month &&
              task.dueDate!.day == today.day;
          break;
        case 'Pending':
          matchesFilter = !task.isCompleted;
          break;
        case 'Completed':
          matchesFilter = task.isCompleted;
          break;
      }

      return matchesFilter && matchesSearch;
    }).toList();

    completedTasksCount = tasks.where((t) => t.isCompleted).length;
  }

  Future<void> _toggleTask(String taskId) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      setState(() {
        task.isCompleted = !task.isCompleted;
        _filterTasks();
      });
      await StorageService.updateTask(task);

      if (task.isCompleted) {
        PopupService.showTaskCompletionOverlay(task.title);
        // Show interstitial ad after every 3 completed tasks
        if (completedTasksCount % 3 == 0 && completedTasksCount > 0) {
          AdService.showInterstitialAd();
        }
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    final task = tasks.firstWhere((t) => t.id == taskId);
    await NotificationService.cancelTaskReminder(taskId);
    await StorageService.deleteTask(taskId);
    _loadTasks();
    PopupService.showToast('Task "${task.title}" deleted');
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              _filterTasks();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
                _filterTasks();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskCreateScreen()),
            ).then((_) => _loadTasks()),
          ),
        ],
      ),
      body: Column(
        children: [
          ProgressCard(
            completedTasks: completedTasksCount,
            totalTasks: tasks.length,
          ),
          
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                        _filterTasks();
                      });
                    },
                    selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
                  ),
                );
              },
            ),
          ),

          // Banner Ad
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: AdWidget(ad: _bannerAd!),
            ),

          // Tasks List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(
                              task: task,
                              onToggle: () => _toggleTask(task.id),
                              onDelete: () => _deleteTask(task.id),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(task: task),
                                ),
                              ).then((_) => _loadTasks()),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selectedFilter == 'Completed' ? Icons.check_circle : Icons.task_alt,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            selectedFilter == 'Completed' 
                ? 'No completed tasks yet'
                : searchQuery.isNotEmpty
                    ? 'No tasks found'
                    : 'No tasks yet',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            selectedFilter == 'Completed'
                ? 'Complete some tasks to see them here'
                : searchQuery.isNotEmpty
                    ? 'Try a different search term'
                    : 'Tap + to add your first task',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}