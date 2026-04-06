import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _statsSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveStats();
    });
  }

  Future<void> _saveStats() async {
    if (_statsSaved) return;
    _statsSaved = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final authVM = context.read<AuthViewModel>();
    final myUid = authVM.currentUser?.uid ?? '';
    final winnerId = args['winnerId'] as String?;
    final totalAnswers = args['totalAnswers'] as int;
    final correctAnswers = args['correctAnswers'] as int;

    await authVM.updateStatsAfterGame(
      didWin: winnerId == myUid,
      totalAnswers: totalAnswers,
      correctAnswers: correctAnswers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final authVM = context.watch<AuthViewModel>();

    final myUid = authVM.currentUser?.uid ?? '';
    final winnerId = args['winnerId'] as String?;
    final myHp = args['myHp'] as int;
    final opponentHp = args['opponentHp'] as int;
    final myScore = args['myScore'] as int;
    final myCombo = args['myCombo'] as int;
    final totalAnswers = args['totalAnswers'] as int;
    final correctAnswers = args['correctAnswers'] as int;

    final didWin = winnerId == myUid;
    final isDraw = winnerId == null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a237e), Color(0xFF004d40)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isDraw
                        ? 'Draw!'
                        : didWin
                        ? 'You Win!'
                        : 'You Lose!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDraw
                          ? Colors.white
                          : didWin
                          ? Colors.amber
                          : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        _statRow('Your HP', '$myHp'),
                        _statRow('Opponent HP', '$opponentHp'),
                        _statRow('Your Score', '$myScore'),
                        _statRow('Best Combo', '$myCombo'),
                        _statRow('Questions Answered', '$totalAnswers'),
                        _statRow('Correct Answers', '$correctAnswers'),
                        if (totalAnswers > 0)
                          _statRow(
                            'Accuracy',
                            '${((correctAnswers / totalAnswers) * 100).toStringAsFixed(0)}%',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
