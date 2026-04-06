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
        if (!context.mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (room.status == 'finished') {
       WidgetsBinding.instance.addPostFrameCallback((_) {
           if (!context.mounted) return;
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Health Bars
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOU', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Image.asset('assets/animations/chaA.gif', height: 80, width: 80),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (myPlayer.hp / 100).clamp(0.0, 1.0),
                              minHeight: 16,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${myPlayer.hp} / 100 HP', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(opponent.username.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Image.asset('assets/animations/chaB.gif', height: 80, width: 80),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (opponent.hp / 100).clamp(0.0, 1.0),
                              minHeight: 16,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFFF43F5E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${opponent.hp} / 100 HP', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Timer
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: gameProvider.timeLeft <= 3 ? const Color(0xFFF43F5E).withOpacity(0.1) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: gameProvider.timeLeft <= 3 ? const Color(0xFFF43F5E) : Colors.grey.shade300,
                      width: 4,
                    ),
                    boxShadow: [
                      if (gameProvider.timeLeft <= 3) 
                        BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.2), blurRadius: 20)
                    ]
                  ),
                  child: Text(
                    '${gameProvider.timeLeft}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: gameProvider.timeLeft <= 3 ? const Color(0xFFF43F5E) : const Color(0xFF1E293B),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Question Card
                Card(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Text(
                      currentQuestion.text,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Answers Grid
                if (myPlayer.hasAnsweredCurrent)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
                        SizedBox(height: 16),
                        Text('Answer Locked!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        Text('Waiting for opponent...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: currentQuestion.options.map((option) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E293B),
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: Colors.grey.shade300, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )
                        ),
                        onPressed: () => gameProvider.submitAnswer(option),
                        child: Text('$option', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                  
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
