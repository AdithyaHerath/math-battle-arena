class QuestionModel {
  final String id;
  final String questionText;
  final int correctAnswer;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String
  category; // 'addition', 'subtraction', 'multiplication', 'division'

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.correctAnswer,
    required this.difficulty,
    required this.category,
  });

  factory QuestionModel.fromMap(String id, Map<String, dynamic> map) {
    return QuestionModel(
      id: id,
      questionText: map['questionText'] ?? '',
      correctAnswer: map['correctAnswer'] ?? 0,
      difficulty: map['difficulty'] ?? 'easy',
      category: map['category'] ?? 'addition',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'category': category,
    };
  }
}
