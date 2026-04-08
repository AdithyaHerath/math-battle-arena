class MathQuestion {
  final String text;
  final int correctAnswer;
  final List<int> options;

  const MathQuestion({
    required this.text,
    required this.correctAnswer,
    required this.options,
  });

  static const Map<String, List<MathQuestion>> levelPools = {
    'Beginner': [
      MathQuestion(text: "7 + 8", correctAnswer: 15, options: [14, 15, 16, 12]),
      MathQuestion(text: "12 - 5", correctAnswer: 7, options: [6, 7, 8, 9]),
      MathQuestion(text: "6 * 4", correctAnswer: 24, options: [18, 20, 24, 28]),
      MathQuestion(text: "15 + 9", correctAnswer: 24, options: [22, 23, 24, 25]),
      MathQuestion(text: "20 - 11", correctAnswer: 9, options: [8, 9, 10, 11]),
    ],
    'Intermediate': [
      MathQuestion(text: "(5 + 3) * 2", correctAnswer: 16, options: [12, 14, 16, 18]),
      MathQuestion(text: "45 / 5 + 4", correctAnswer: 13, options: [11, 13, 15, 17]),
      MathQuestion(text: "12 * (3 - 1)", correctAnswer: 24, options: [18, 20, 22, 24]),
      MathQuestion(text: "100 - (15 * 4)", correctAnswer: 40, options: [20, 30, 40, 50]),
      MathQuestion(text: "(8 + 6) / 2 * 3", correctAnswer: 21, options: [14, 18, 21, 24]),
    ],
    'Advanced': [
      MathQuestion(text: "x + 5 = 12", correctAnswer: 7, options: [5, 6, 7, 8]),
      MathQuestion(text: "2x - 4 = 10", correctAnswer: 7, options: [5, 6, 7, 8]),
      MathQuestion(text: "3y + 9 = 0", correctAnswer: -3, options: [-2, -3, -4, 3]),
      MathQuestion(text: "5x = -25", correctAnswer: -5, options: [5, -5, 20, -20]),
      MathQuestion(text: "(x / 2) + 4 = 8", correctAnswer: 8, options: [6, 8, 10, 12]),
    ],
  };
}
