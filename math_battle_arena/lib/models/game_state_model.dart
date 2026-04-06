enum GamePhase { idle, countdown, playing, roundEnd, gameOver }

class GameStateModel {
  final GamePhase phase;
  final int myHp;
  final int opponentHp;
  final int comboCount;
  final double comboMultiplier;
  final int timeLeftSeconds;
  final String? winnerId;

  GameStateModel({
    this.phase = GamePhase.idle,
    this.myHp = 100,
    this.opponentHp = 100,
    this.comboCount = 0,
    this.comboMultiplier = 1.0,
    this.timeLeftSeconds = 30,
    this.winnerId,
  });

  // Combo multiplier logic: x1 → x2 → x3 based on consecutive correct answers
  double get calculatedMultiplier {
    if (comboCount >= 6) return 3.0;
    if (comboCount >= 3) return 2.0;
    return 1.0;
  }

  int get damagePerHit => (10 * calculatedMultiplier).round();

  GameStateModel copyWith({
    GamePhase? phase,
    int? myHp,
    int? opponentHp,
    int? comboCount,
    double? comboMultiplier,
    int? timeLeftSeconds,
    String? winnerId,
  }) {
    return GameStateModel(
      phase: phase ?? this.phase,
      myHp: myHp ?? this.myHp,
      opponentHp: opponentHp ?? this.opponentHp,
      comboCount: comboCount ?? this.comboCount,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}
