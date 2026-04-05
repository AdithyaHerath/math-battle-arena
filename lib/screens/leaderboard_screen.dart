import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold))),
      body: FutureBuilder<List<AppUser>>(
        future: firestoreService.getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading leaderboard: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No players ranked yet!', style: TextStyle(fontSize: 18)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final user = users[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRankColor(index).withOpacity(0.1),
                      child: Text(
                        '${index + 1}', 
                        style: TextStyle(color: _getRankColor(index), fontWeight: FontWeight.w900)
                      ),
                    ),
                    title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
                    subtitle: Text('Matches played: ${user.matchesPlayed}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('WINS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text('${user.wins}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return const Color(0xFFF59E0B); // Amber/Gold
    if (index == 1) return const Color(0xFF94A3B8); // Silver
    if (index == 2) return const Color(0xFFD97706); // Bronze
    return const Color(0xFF6366F1); // Indigo default
  }
}
