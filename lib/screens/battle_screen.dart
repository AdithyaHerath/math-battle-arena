import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../viewmodels/game_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/lobby_viewmodel.dart';

class BattleScreen extends StatefulWidget {
  final bool isSinglePlayer;

  const BattleScreen({super.key, this.isSinglePlayer = false});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized && mounted) {
        _initialized = true;
        final gameVM = context.read<GameViewModel>();
        final authVM = context.read<AuthViewModel>();
        final lobbyVM = context.read<LobbyViewModel>();
        final room = lobbyVM.currentRoom;

        if (widget.isSinglePlayer) {
          gameVM.initializeSinglePlayer(
            lobbyVM.selectedDifficulty,
            authVM.currentUser?.displayName ?? 'Player',
          );
        } else if (room != null && authVM.currentUser != null) {
          final isPlayer1 = authVM.currentUser!.uid == room.player1Id;
          final myName = authVM.currentUser!.displayName;
          final opponentName = isPlayer1 ? room.player2Name : room.player1Name;

          gameVM.initialize(
            room.roomId,
            authVM.currentUser!.uid,
            room.player1Id,
            room.player2Id ?? '',
            lobbyVM.selectedDifficulty,
            myName,
            opponentName,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameVM = context.watch<GameViewModel>();

    if (gameVM.status == GameStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/results',
            arguments: {
              'isSinglePlayer': widget.isSinglePlayer,
              'myHp': gameVM.myHp,
              'opponentHp': gameVM.opponentHp,
              'myScore': gameVM.myScore,
              'myCombo': gameVM.myCombo,
              'winnerId': gameVM.winnerId,
              'totalAnswers': gameVM.totalAnswers,
              'correctAnswers': gameVM.correctAnswers,
              'myName': gameVM.myName,
              'opponentName': gameVM.opponentName,
            },
          );
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a237e), Color(0xFF004d40)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBar(gameVM),
                        const SizedBox(height: 16),
                        _buildHpBars(gameVM),
                        const SizedBox(height: 16),
                        _buildFightingAnimations(),
                        const SizedBox(height: 16),
                        if (gameVM.myCombo >= 3) _buildComboIndicator(gameVM),
                        const SizedBox(height: 16),
                        _buildQuestionCard(gameVM),
                        const SizedBox(height: 16),
                        _buildAnswerInput(gameVM),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameViewModel gameVM) {
    final minutes = gameVM.gameTimeLeft ~/ 60;
    final seconds = gameVM.gameTimeLeft % 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Battle Arena',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: gameVM.gameTimeLeft <= 30
                ? Colors.redAccent.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gameVM.gameTimeLeft <= 30
                  ? Colors.redAccent
                  : Colors.white24,
            ),
          ),
          child: Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: gameVM.gameTimeLeft <= 30
                  ? Colors.redAccent
                  : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHpBars(GameViewModel gameVM) {
    if (widget.isSinglePlayer) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gameVM.myName}  Score: ${gameVM.myScore}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gameVM.correctAnswers / max(gameVM.totalAnswers, 1),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${gameVM.opponentName}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gameVM.gameTimeLeft / 120,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.redAccent,
                    ),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${gameVM.myName}  ${gameVM.myHp} HP',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: gameVM.myHp / 100,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    gameVM.myHp > 50 ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'VS',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${gameVM.opponentName}  ${gameVM.opponentHp} HP',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: gameVM.opponentHp / 100,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    gameVM.opponentHp > 50
                        ? Colors.redAccent
                        : Colors.deepOrangeAccent,
                  ),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFightingAnimations() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // User's figure
        Image.asset(
          'assets/animations/fight.gif',
          height: 120,
          width: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 40),
        // Opponent's figure, flipped
        Transform.scale(
          scaleX: -1,
          child: Image.asset(
            'assets/animations/fight.gif',
            height: 120,
            width: 120,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildComboIndicator(GameViewModel gameVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber),
      ),
      child: Text(
        'COMBO x${gameVM.comboMultiplier.toStringAsFixed(0)}  🔥  ${gameVM.myCombo} streak',
        style: const TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(GameViewModel gameVM) {
    final question = gameVM.currentQuestion;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                '${gameVM.timeLeft}s',
                style: TextStyle(
                  color: gameVM.timeLeft <= 5
                      ? Colors.redAccent
                      : Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question?.questionText ?? 'Loading...',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${question?.difficulty ?? ''} • ${question?.category ?? ''}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          if (gameVM.answerSubmitted)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Answer submitted! Waiting for next question...',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(GameViewModel gameVM) {
    return Column(
      children: [
        Text(
          'Score: ${gameVM.myScore}',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                enabled: !gameVM.answerSubmitted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Your answer',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
                onSubmitted: (value) => _submitAnswer(gameVM),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: gameVM.answerSubmitted
                    ? null
                    : () => _submitAnswer(gameVM),
                child: const Icon(Icons.send, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitAnswer(GameViewModel gameVM) {
    final input = int.tryParse(_answerController.text.trim());
    if (input == null) return;
    _answerController.clear();
    gameVM.submitAnswer(input);
  }
}
