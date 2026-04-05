import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.read<AppAuthProvider>();
    final me = authProvider.appUser!;
    final room = gameProvider.currentRoom;

    if (room == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Result data securely unloaded.'),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    final bool isDraw = room.winnerId == null;
    final bool didIWin = room.winnerId == me.uid;

    final myPlayer = room.players[me.uid];
    final opponentId = room.players.keys.firstWhere((k) => k != me.uid, orElse: () => '');
    final opponent = room.players[opponentId];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isDraw
                  ? "It's a Draw!"
                  : (didIWin ? 'You Won! 🎉' : 'You Lost! 💀'),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDraw ? Colors.orange : (didIWin ? Colors.green : Colors.red),
              ),
            ),
            const SizedBox(height: 30),
            if (myPlayer != null && opponent != null) ...[
              Text(
                'Your HP: ${myPlayer.hp}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                '${opponent.username} HP: ${opponent.hp}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                await gameProvider.leaveRoom(me.uid);
                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Return to Home', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
