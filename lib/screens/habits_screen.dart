import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../widgets/habit_card.dart';
import 'habit_create_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> habits = [];
  bool isLoading = true;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd(onAdLoaded: (_) => setState(() {}));
    _bannerAd?.load();
  }

  Future<void> _loadHabits() async {
    final loadedHabits = await StorageService.getHabits();
    setState(() {
      habits = loadedHabits;
      isLoading = false;
    });
  }

  Future<void> _markHabitComplete(String habitId) async {
    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      final habit = habits[habitIndex];
      final today = DateTime.now();
      
      if (!habit.isCompletedToday) {
        habit.completedDates.add(today);
        habit.streak++;
        habit.lastCompleted = today;
        
        await StorageService.updateHabit(habit);
        setState(() {});
        
        // Show rewarded ad for streak milestones
        if (habit.streak % 7 == 0) {
          _showStreakReward(habit.streak);
        }
      }
    }
  }

  void _showStreakReward(int streak) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Streak Milestone!'),
        content: Text('Congratulations! You\'ve reached a $streak-day streak!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AdService.showRewardedAd(onUserEarnedReward: (ad, reward) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium theme unlocked!')),
                );
              });
            },
            child: const Text('Watch Ad for Reward'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHabit(String habitId) async {
    await StorageService.deleteHabit(habitId);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HabitCreateScreen()),
            ).then((_) => _loadHabits()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedToday of ${habits.length} habits completed',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: habits.isNotEmpty ? completedToday / habits.length : 0,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
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

          // Habits List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : habits.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.track_changes, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No habits yet', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
                            Text('Tap + to add your first habit', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHabits,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return HabitCard(
                              habit: habit,
                              onComplete: () => _markHabitComplete(habit.id),
                              onDelete: () => _deleteHabit(habit.id),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
                              ).then((_) => _loadHabits()),
                            );
                          },
                        ),
                      ),
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