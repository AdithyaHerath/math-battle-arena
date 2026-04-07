import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/audio_provider.dart';
import 'lobby_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AudioProvider>().playBackgroundMusic();
      }
    });
  }

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
    final audioProvider = context.watch<AudioProvider>();
    final user = authProvider.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Battle', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(audioProvider.isPlaying ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              audioProvider.toggleMusic();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              audioProvider.stopMusic();
              authProvider.signOut();
              authProvider.signInAnonymously();
            },
          ),
        ],
      ),
      body: authProvider.isLoading || user == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.7,
                  child: Image.asset('assets/animations/fireflies.gif', fit: BoxFit.cover),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.calculate, size: 60, color: Color(0xFFF59E0B)),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            children: [
                              Text(
                                'Welcome,\n${user.username}!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26, 
                                  fontWeight: FontWeight.bold, 
                                  color: Color(0xFF1E293B)
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _StatBadge(title: 'Wins', value: user.wins, color: const Color(0xFF10B981)),
                                  const SizedBox(width: 16),
                                  _StatBadge(title: 'Played', value: user.matchesPlayed, color: const Color(0xFF6366F1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
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
                          minimumSize: const Size(double.infinity, 60),
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
                          minimumSize: const Size(double.infinity, 60),
                          backgroundColor: const Color(0xFF3B82F6), // Secondary blue
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
                          minimumSize: const Size(double.infinity, 60),
                          side: const BorderSide(color: Color(0xFF1E293B), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                          ),
                          foregroundColor: const Color(0xFF1E293B)
                        ),
                        child: const Text('Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
              ],
            ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatBadge({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
