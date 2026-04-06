import 'package:flutter/material.dart';
import 'dart:async';
import '../services/game_service.dart';
import '../models/question_model.dart';

enum GameStatus { loading, playing, finished }

class GameViewModel extends ChangeNotifier {
  final GameService _gameService = GameService();

  GameStatus _status = GameStatus.loading;
  Map<String, dynamic>? _gameData;
  List<QuestionModel> _questions = [];

  // Local per player — not synced via Firebase
  int _localQuestionIndex = 0;
  bool _answerSubmitted = false;
  int _timeLeft = 15;
  int _localCombo = 0;
  int _localScore = 0;

  // Stat tracking
  int _totalAnswers = 0;
  int _correctAnswers = 0;

  // Player names
  String _myName = 'You';
  String _opponentName = 'Opponent';

  Timer? _questionTimer;
  Timer? _gameTimer;
  int _gameTimeLeft = 120;
  StreamSubscription? _gameSubscription;

  String _roomId = '';
  String _playerId = '';
  bool _isPlayer1 = false;
  String _difficulty = 'easy';

  // Getters
  GameStatus get status => _status;
  int get timeLeft => _timeLeft;
  int get gameTimeLeft => _gameTimeLeft;
  bool get answerSubmitted => _answerSubmitted;
  bool get isPlayer1 => _isPlayer1;
  String? get winnerId => _gameData?['winnerId'];
  int get totalAnswers => _totalAnswers;
  int get correctAnswers => _correctAnswers;
  String get myName => _myName;
  String get opponentName => _opponentName;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _localQuestionIndex < _questions.length
      ? _questions[_localQuestionIndex]
      : null;

  // HP is still read from Firebase (shared state)
  int get myHp => _isPlayer1
      ? (_gameData?['player1Hp'] ?? 100)
      : (_gameData?['player2Hp'] ?? 100);

  int get opponentHp => _isPlayer1
      ? (_gameData?['player2Hp'] ?? 100)
      : (_gameData?['player1Hp'] ?? 100);

  // Score and combo are local
  int get myScore => _localScore;
  int get myCombo => _localCombo;

  double get comboMultiplier {
    if (_localCombo >= 6) return 3.0;
    if (_localCombo >= 3) return 2.0;
    return 1.0;
  }

  void initialize(
    String roomId,
    String playerId,
    String player1Id,
    String player2Id,
    String difficulty,
    String myDisplayName,
    String opponentDisplayName,
  ) async {
    _roomId = roomId;
    _playerId = playerId;
    _isPlayer1 = playerId == player1Id;
    _difficulty = difficulty;
    _myName = myDisplayName;
    _opponentName = opponentDisplayName;

    if (_isPlayer1) {
      await _gameService.initGameState(
        roomId,
        player1Id,
        player2Id,
        difficulty,
      );
    }

    _watchGame();
    _startGameTimer();
    _status = GameStatus.playing;
    notifyListeners();
  }

  void _watchGame() {
    _gameSubscription = _gameService.watchGame(_roomId).listen((data) {
      if (data == null) return;

      // Load questions from Firebase once
      if (_questions.isEmpty && data['questions'] != null) {
        final rawList = data['questions'] as List<dynamic>;
        _questions = rawList.asMap().entries.map((e) {
          return QuestionModel.fromMap(
            e.key.toString(),
            Map<String, dynamic>.from(e.value as Map),
          );
        }).toList();
        _difficulty = data['difficulty'] ?? 'easy';
        _startQuestionTimer();
      }

      _gameData = data;

      // Only Firebase decides when game is over
      if (data['status'] == 'finished') {
        _status = GameStatus.finished;
        _questionTimer?.cancel();
        _gameTimer?.cancel();
      }

      notifyListeners();
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _gameTimeLeft--;
      if (_gameTimeLeft <= 0) {
        timer.cancel();
        _gameService.endGameByTimeout(_roomId);
      }
      notifyListeners();
    });
  }

  void _startQuestionTimer() {
    _timeLeft = _getDurationForDifficulty();
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      if (_timeLeft <= 0) {
        timer.cancel();
        _onTimeUp();
      }
      notifyListeners();
    });
  }

  int _getDurationForDifficulty() {
    switch (_difficulty) {
      case 'hard':
        return 10;
      case 'medium':
        return 12;
      default:
        return 15;
    }
  }

  void _onTimeUp() {
    if (_answerSubmitted) return;
    _totalAnswers++;
    _localCombo = 0;
    _answerSubmitted = true;
    notifyListeners();

    _gameService.submitAnswer(
      roomId: _roomId,
      playerId: _playerId,
      isCorrect: false,
      remainingSeconds: 0,
      comboCount: 0,
      isPlayer1: _isPlayer1,
      damage: 0,
      points: 0,
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      _moveToNextQuestion();
    });
  }

  Future<void> submitAnswer(int answer) async {
    if (_answerSubmitted || currentQuestion == null) return;
    _answerSubmitted = true;
    _questionTimer?.cancel();

    final isCorrect = answer == currentQuestion!.correctAnswer;

    // Track stats
    _totalAnswers++;
    if (isCorrect) _correctAnswers++;

    int damage = 0;
    int points = 0;

    if (isCorrect) {
      _localCombo++;
      double multiplier = comboMultiplier;
      damage = (10 * multiplier).round();
      points = 100 + (_timeLeft * 5) + (_localCombo * 10);
      _localScore += points;
    } else {
      _localCombo = 0;
    }

    notifyListeners();

    await _gameService.submitAnswer(
      roomId: _roomId,
      playerId: _playerId,
      isCorrect: isCorrect,
      remainingSeconds: _timeLeft,
      comboCount: _localCombo,
      isPlayer1: _isPlayer1,
      damage: damage,
      points: points,
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    if (_status == GameStatus.finished) return;
    _localQuestionIndex++;
    _answerSubmitted = false;
    if (mounted) {
      _startQuestionTimer();
      notifyListeners();
    }
  }

  bool get mounted => _gameSubscription != null;

  Future<void> cleanup() async {
    _questionTimer?.cancel();
    _gameTimer?.cancel();
    _gameSubscription?.cancel();
    _gameSubscription = null;
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}
