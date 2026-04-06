import 'package:firebase_database/firebase_database.dart';
import '../models/question_model.dart';
import 'dart:math';

class GameService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final Random _random = Random();

  // Generate questions based on difficulty
  List<QuestionModel> generateQuestions(String difficulty, {int count = 20}) {
    List<QuestionModel> questions = [];
    final Set<String> used = {};

    while (questions.length < count) {
      final q = _generateQuestion(difficulty);
      if (!used.contains(q.questionText)) {
        used.add(q.questionText);
        questions.add(q);
      }
    }
    return questions;
  }

  QuestionModel _generateQuestion(String difficulty) {
    final ops = ['+', '-', '×', '÷'];
    final op = ops[_random.nextInt(ops.length)];

    int a, b, answer;

    switch (difficulty) {
      case 'hard':
        // Mix of single, double, triple digits
        final type = _random.nextInt(3);
        if (type == 0) {
          a = _random.nextInt(9) + 1;
          b = _random.nextInt(9) + 1;
        } else if (type == 1) {
          a = _random.nextInt(90) + 10;
          b = _random.nextInt(90) + 10;
        } else {
          a = _random.nextInt(900) + 100;
          b = _random.nextInt(90) + 10;
        }
      case 'medium':
        // Mix of single and double digits
        final type = _random.nextInt(2);
        if (type == 0) {
          a = _random.nextInt(9) + 1;
          b = _random.nextInt(9) + 1;
        } else {
          a = _random.nextInt(90) + 10;
          b = _random.nextInt(9) + 1;
        }
      default: // easy
        // Single digits only
        a = _random.nextInt(9) + 1;
        b = _random.nextInt(9) + 1;
    }

    // Fix division to always be clean
    if (op == '÷') {
      b = _random.nextInt(9) + 1;
      a = b * (_random.nextInt(9) + 1);
      answer = a ~/ b;
    } else if (op == '-') {
      // Avoid negative answers
      if (a < b) {
        final temp = a;
        a = b;
        b = temp;
      }
      answer = a - b;
    } else if (op == '×') {
      // Keep multiplication manageable
      if (difficulty == 'easy') {
        a = _random.nextInt(9) + 1;
        b = _random.nextInt(9) + 1;
      } else if (difficulty == 'medium') {
        a = _random.nextInt(9) + 1;
        b = _random.nextInt(19) + 1;
      } else {
        a = _random.nextInt(19) + 1;
        b = _random.nextInt(19) + 1;
      }
      answer = a * b;
    } else {
      answer = a + b;
    }

    return QuestionModel(
      id: '${a}_${op}_${b}',
      questionText: '$a $op $b = ?',
      correctAnswer: answer,
      difficulty: difficulty,
      category: _opToCategory(op),
    );
  }

  String _opToCategory(String op) {
    switch (op) {
      case '+':
        return 'addition';
      case '-':
        return 'subtraction';
      case '×':
        return 'multiplication';
      case '÷':
        return 'division';
      default:
        return 'addition';
    }
  }

  // Seed questions into Firebase so both players get the same set
  Future<void> initGameState(
    String roomId,
    String player1Id,
    String player2Id,
    String difficulty,
  ) async {
    final questions = generateQuestions(difficulty);
    final questionMaps = questions.map((q) => q.toMap()).toList();

    await _db.ref('games/$roomId').set({
      'player1Id': player1Id,
      'player2Id': player2Id,
      'player1Hp': 100,
      'player2Hp': 100,
      'player1Score': 0,
      'player2Score': 0,
      'player1Combo': 0,
      'player2Combo': 0,
      'questionIndex': 0,
      'difficulty': difficulty,
      'questions': questionMaps,
      'startTime': ServerValue.timestamp,
      'status': 'playing',
      'winnerId': null,
    });
  }

  Future<void> submitAnswer({
    required String roomId,
    required String playerId,
    required bool isCorrect,
    required int remainingSeconds,
    required int comboCount,
    required bool isPlayer1,
    required int damage,
    required int points,
  }) async {
    if (damage == 0 && points == 0) return;

    final ref = _db.ref('games/$roomId');

    await ref.runTransaction((data) {
      if (data == null) return Transaction.abort();
      final game = Map<String, dynamic>.from(data as Map);

      final String myScoreKey = isPlayer1 ? 'player1Score' : 'player2Score';
      final String opponentHpKey = isPlayer1 ? 'player2Hp' : 'player1Hp';

      if (isCorrect && damage > 0) {
        final currentHp = (game[opponentHpKey] ?? 100) as int;
        game[opponentHpKey] = (currentHp - damage).clamp(0, 100);
        game[myScoreKey] = (game[myScoreKey] ?? 0) + points;

        if (game[opponentHpKey] == 0) {
          game['status'] = 'finished';
          game['winnerId'] = playerId;
        }
      }

      return Transaction.success(game);
    });
  }

  Future<void> endGameByTimeout(String roomId) async {
    final ref = _db.ref('games/$roomId');
    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final game = Map<String, dynamic>.from(snapshot.value as Map);
    final p1Hp = game['player1Hp'] ?? 0;
    final p2Hp = game['player2Hp'] ?? 0;

    String? winnerId;
    if (p1Hp > p2Hp)
      winnerId = game['player1Id'];
    else if (p2Hp > p1Hp)
      winnerId = game['player2Id'];

    await ref.update({'status': 'finished', 'winnerId': winnerId});
  }

  Stream<Map<String, dynamic>?> watchGame(String roomId) {
    return _db.ref('games/$roomId').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  Future<void> deleteGame(String roomId) async {
    await _db.ref('games/$roomId').remove();
  }
}
