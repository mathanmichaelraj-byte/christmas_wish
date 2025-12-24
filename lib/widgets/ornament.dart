import 'dart:ui';

enum OrnamentType { redBall, blueBall, star, candy, bell, snowflake, gift }

class Ornament {
  final Offset position;
  final OrnamentType type;
  final int id;
  final bool isCorrect;

  Ornament({
    required this.position,
    required this.type,
    required this.id,
    this.isCorrect = false,
  });
}

class TargetOrnament {
  final Offset position;
  final OrnamentType type;
  bool isMatched;

  TargetOrnament({
    required this.position,
    required this.type,
    this.isMatched = false,
  });
}
