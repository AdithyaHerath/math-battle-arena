import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../services/background_audio_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsViewModel>();
    if (settings.isMusicEnabled) {
      BackgroundAudioService.playMenuMusic();
    }
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    BackgroundAudioService.stopMenuMusic();
    super.dispose();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      print('Leaderboard: Query snapshot size: ${querySnapshot.size}');
      final List<Map<String, dynamic>> users = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('Leaderboard: Processing user ${doc.id}: $data');
        users.add({
          'uid': doc.id,
          'displayName': data['displayName'] ?? 'Unknown',
          'wins': data['wins'] ?? 0,
          'totalMatches': data['totalMatches'] ?? 0,
          'accuracy': data['accuracy'] ?? 0.0,
        });
      }
      print('Leaderboard: Total users processed: ${users.length}');
      // Sort by wins descending
      users.sort((a, b) => (b['wins'] as int).compareTo(a['wins'] as int));
      setState(() {
        _leaderboard = users.take(10).toList(); // Top 10
        _isLoading = false;
      });
      print('Leaderboard: Final leaderboard length: ${_leaderboard.length}');
    } catch (e) {
      print('Leaderboard: Error fetching: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leaderboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBackground = theme.colorScheme.onBackground;
    final surfaceColor = theme.colorScheme.surface;
    final outlineColor = theme.colorScheme.outline.withOpacity(0.5);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        color: theme.colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: onBackground),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _leaderboard.isEmpty
                    ? Center(
                        child: Text(
                          'No leaderboard data available',
                          style: TextStyle(
                            color: onBackground.withOpacity(0.7),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _leaderboard.length,
                        itemBuilder: (context, index) {
                          final user = _leaderboard[index];
                          final rank = index + 1;
                          final isTopThree = rank <= 3;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: outlineColor),
                            ),
                            child: Row(
                              children: [
                                // Rank
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isTopThree
                                        ? Colors.amber.withOpacity(0.2)
                                        : onBackground.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        color: isTopThree
                                            ? Colors.amber
                                            : onBackground.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['displayName'],
                                        style: TextStyle(
                                          color: onBackground,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Wins: ${user['wins']} | Matches: ${user['totalMatches']} | Accuracy: ${(user['accuracy'] * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: onBackground.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Trophy for top 3
                                if (isTopThree)
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
