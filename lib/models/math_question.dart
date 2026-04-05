class MathQuestion {
  final String text;
  final int correctAnswer;
  final List<int> options;

  const MathQuestion({
    required this.text,
    required this.correctAnswer,
    required this.options,
  });

  static const List<MathQuestion> pool = [
    MathQuestion(text: "7 + 8", correctAnswer: 15, options: [14, 15, 16, 12]),
    MathQuestion(text: "12 - 5", correctAnswer: 7, options: [6, 7, 8, 9]),
    MathQuestion(text: "6 * 4", correctAnswer: 24, options: [18, 20, 24, 28]),
    MathQuestion(text: "15 + 9", correctAnswer: 24, options: [22, 23, 24, 25]),
    MathQuestion(text: "20 - 11", correctAnswer: 9, options: [8, 9, 10, 11]),
  ];
}
