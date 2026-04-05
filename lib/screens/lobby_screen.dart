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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Handle game started
    if (room.status == 'playing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameScreen()));
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isHost = room.hostId == user.uid;
    final players = room.players.values.toList();
    final amIReady = room.players[user.uid]?.isReady ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${room.roomId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await gameProvider.leaveRoom(user.uid);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Players (Max 2)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (ctx, idx) {
                  final player = players[idx];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: player.uid == room.hostId ? Colors.amber : Colors.blue,
                      ),
                      title: Text(player.username),
                      subtitle: Text(player.uid == room.hostId ? 'Host' : 'Challenger'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (player.isReady)
                            const Icon(Icons.check_circle, color: Colors.green)
                          else
                            const Icon(Icons.hourglass_empty, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            player.isReady ? 'Ready' : 'Waiting',
                            style: TextStyle(
                              color: player.isReady ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Ready up button
            ElevatedButton(
              onPressed: () => gameProvider.toggleReady(user.uid),
              style: ElevatedButton.styleFrom(
                backgroundColor: amIReady ? Colors.orange : Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                amIReady ? 'Cancel Ready' : 'Ready Up!',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Host start button
            if (isHost)
              ElevatedButton(
                onPressed: room.allPlayersReady
                    ? () => gameProvider.startGame()
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}
