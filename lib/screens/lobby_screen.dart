import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.read<AppAuthProvider>();
    final user = authProvider.appUser!;
    
    final room = gameProvider.currentRoom;

    // Handle being kicked / room deleted
    if (room == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only pop if we are actually still on the lobby screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room closed or you were removed.')),
          );
        }
      });
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle game started
    if (room.status == 'playing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameScreen()));
        }
      });
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isHost = room.hostId == user.uid;
    final players = room.players.values.toList();
    final amIReady = room.players[user.uid]?.isReady ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await gameProvider.leaveRoom(user.uid);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room Code Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    const Text('ROOM CODE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      room.roomId,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 12,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Players (Max 2)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.separated(
                  itemCount: players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final player = players[idx];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.uid == room.hostId 
                                ? const Color(0xFFF59E0B).withOpacity(0.2) // Amber 
                                : const Color(0xFF3B82F6).withOpacity(0.2), // Blue
                            child: Icon(
                              Icons.person,
                              color: player.uid == room.hostId ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                            ),
                          ),
                          title: Text(player.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(player.uid == room.hostId ? 'Host' : 'Challenger'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: player.isReady ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              player.isReady ? 'READY' : 'WAITING',
                              style: TextStyle(
                                color: player.isReady ? const Color(0xFF10B981) : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Ready up button
              ElevatedButton(
                onPressed: () => gameProvider.toggleReady(user.uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: amIReady ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: Text(
                  amIReady ? 'Cancel Ready' : 'Ready Up!',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              
              if (isHost) const SizedBox(height: 16),
              
              // Host start button
              if (isHost)
                ElevatedButton(
                  onPressed: room.allPlayersReady
                      ? () => gameProvider.startGame()
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Start Game', style: TextStyle(fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
