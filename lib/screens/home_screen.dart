import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import 'lobby_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showJoinRoomDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final authProvider = context.read<AppAuthProvider>();
    final user = authProvider.appUser!;
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Room'),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter 6-digit Room ID',
          ),
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.length != 6) return;
              
              Navigator.pop(ctx); // Close dialog
              final success = await gameProvider.joinRoom(codeController.text, user);
              if (success && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LobbyScreen()),
                );
              } else if (gameProvider.errorMessage != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(gameProvider.errorMessage!)),
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final gameProvider = context.watch<GameProvider>();
    final user = authProvider.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Battle Arena'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              authProvider.signInAnonymously();
            },
          ),
        ],
      ),
      body: authProvider.isLoading || user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${user.username}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Wins: ${user.wins} | Matches: ${user.matchesPlayed}'),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: gameProvider.isLoading
                        ? null
                        : () async {
                            final success = await gameProvider.createAndJoinRoom(user);
                            if (success && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LobbyScreen()),
                              );
                            } else if (gameProvider.errorMessage != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(gameProvider.errorMessage!)),
                                );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: gameProvider.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Room', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: gameProvider.isLoading
                        ? null
                        : () => _showJoinRoomDialog(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Join Room', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Leaderboard', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }
}
