import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../models/math_question.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.read<AppAuthProvider>();
    final room = gameProvider.currentRoom;
    final me = authProvider.appUser!;

    if (room == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (room.status == 'finished') {
       WidgetsBinding.instance.addPostFrameCallback((_) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
       });
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myPlayer = room.players[me.uid];
    final opponentId = room.players.keys.firstWhere((k) => k != me.uid, orElse: () => '');
    final opponent = room.players[opponentId];

    if (myPlayer == null || opponent == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = MathQuestion.pool[room.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${room.currentQuestionIndex + 1} / ${MathQuestion.pool.length}'),
        automaticallyImplyLeading: false, // Prevent going back manually
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Health Bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('HP: ${myPlayer.hp}', style: const TextStyle(fontSize: 18, color: Colors.green)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(opponent.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('HP: ${opponent.hp}', style: const TextStyle(fontSize: 18, color: Colors.red)),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Timer
              Text(
                '${gameProvider.timeLeft}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: gameProvider.timeLeft <= 3 ? Colors.red : Colors.black,
                ),
              ),
              const Text('Seconds Left'),

              const Spacer(),

              // Question
              Text(
                currentQuestion.text,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              
              const Spacer(),

              // Answers Grid
              if (myPlayer.hasAnsweredCurrent)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Waiting for opponent...', style: TextStyle(fontSize: 18)),
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: currentQuestion.options.map((option) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        )
                      ),
                      onPressed: () => gameProvider.submitAnswer(option),
                      child: Text('$option', style: const TextStyle(fontSize: 24, color: Colors.white)),
                    );
                  }).toList(),
                ),
                
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
