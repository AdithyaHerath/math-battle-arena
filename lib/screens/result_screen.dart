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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Result data securely unloaded.'),
              const SizedBox(height: 16),
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

    Color topColor = isDraw ? const Color(0xFFF59E0B) : (didIWin ? const Color(0xFF10B981) : const Color(0xFFF43F5E));
    IconData topIcon = isDraw ? Icons.handshake : (didIWin ? Icons.emoji_events : Icons.sentiment_very_dissatisfied);

    return Scaffold(
      backgroundColor: topColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _AnimatedResultIcon(iconData: topIcon),
                   const SizedBox(height: 24),
                   Text(
                    isDraw
                        ? "IT'S A DRAW!"
                        : (didIWin ? 'VICTORY!' : 'DEFEAT!'),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('FINAL SCORE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                    const SizedBox(height: 32),
                    if (myPlayer != null && opponent != null) ...[
                      _ResultRow(name: 'YOU', hp: myPlayer.hp, isMe: true),
                      const SizedBox(height: 16),
                      _ResultRow(name: opponent.username.toUpperCase(), hp: opponent.hp, isMe: false),
                    ],
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        await gameProvider.leaveRoom(me.uid);
                        if (context.mounted) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                      child: const Text('Return Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String name;
  final int hp;
  final bool isMe;

  const _ResultRow({required this.name, required this.hp, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isMe ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFF43F5E).withOpacity(0.1),
                child: Icon(Icons.person, color: isMe ? const Color(0xFF6366F1) : const Color(0xFFF43F5E)),
              ),
              const SizedBox(width: 16),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Text(
            '$hp HP',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: hp > 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedResultIcon extends StatefulWidget {
  final IconData iconData;
  const _AnimatedResultIcon({required this.iconData});

  @override
  State<_AnimatedResultIcon> createState() => _AnimatedResultIconState();
}

class _AnimatedResultIconState extends State<_AnimatedResultIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(widget.iconData, size: 120, color: Colors.white),
    );
  }
}
