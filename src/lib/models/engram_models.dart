enum EngramType { mcq, flashcard, shortQuestion, longQuestion, unknown }

EngramType _parseEngramType(String raw) {
  switch (raw) {
    case 'mcq':
      return EngramType.mcq;
    case 'flashcard':
      return EngramType.flashcard;
    case 'short_question':
      return EngramType.shortQuestion;
    case 'long_question':
      return EngramType.longQuestion;
    default:
      return EngramType.unknown;
  }
}

abstract class EngramContent {}

class McqContent extends EngramContent {
  final int findingIndex;
  final int questionNumber;
  final String stem;
  final Map<String, String> options; // {"A": "...", "B": "...", ...}
  final String severity;

  McqContent({
    required this.findingIndex,
    required this.questionNumber,
    required this.stem,
    required this.options,
    required this.severity,
  });

  factory McqContent.fromJson(Map<String, dynamic> json) => McqContent(
    findingIndex: json['finding_index'] as int,
    questionNumber: json['question_number'] as int,
    stem: json['stem'] as String,
    options: Map<String, String>.from(json['options'] as Map),
    severity: json['severity'] as String,
  );
}

class FlashcardContent extends EngramContent {
  final int findingIndex;
  final int cardNumber;
  final String front;
  final String back;
  final String? bridgeConcept;
  final String severity;
  final String? diagnosticNote;

  FlashcardContent({
    required this.findingIndex,
    required this.cardNumber,
    required this.front,
    required this.back,
    this.bridgeConcept,
    required this.severity,
    this.diagnosticNote,
  });

  factory FlashcardContent.fromJson(Map<String, dynamic> json) =>
      FlashcardContent(
        findingIndex: json['finding_index'] as int,
        cardNumber: json['card_number'] as int,
        front: json['front'] as String,
        back: json['back'] as String,
        bridgeConcept: json['bridge_concept'] as String?,
        severity: json['severity'] as String,
        diagnosticNote: json['diagnostic_note'] as String?,
      );
}

class ShortQuestionItem {
  final int findingIndex;
  final int questionNumber;
  final String level;
  final String stem;
  final String? hint;
  final bool contextAnchored;
  final String severity;

  ShortQuestionItem({
    required this.findingIndex,
    required this.questionNumber,
    required this.level,
    required this.stem,
    this.hint,
    required this.contextAnchored,
    required this.severity,
  });

  factory ShortQuestionItem.fromJson(Map<String, dynamic> json) =>
      ShortQuestionItem(
        findingIndex: json['finding_index'] as int,
        questionNumber: json['question_number'] as int,
        level: json['level'] as String,
        stem: json['stem'] as String,
        hint: json['hint'] as String?,
        contextAnchored: json['context_anchored'] as bool,
        severity: json['severity'] as String,
      );
}

class ShortQuestionContent extends EngramContent {
  final List<ShortQuestionItem> questions;

  ShortQuestionContent({required this.questions});

  factory ShortQuestionContent.fromJson(Map<String, dynamic> json) =>
      ShortQuestionContent(
        questions:
            (json['questions'] as List)
                .map(
                  (q) => ShortQuestionItem.fromJson(q as Map<String, dynamic>),
                )
                .toList(),
      );
}

class LongQuestionPart {
  final String part;
  final String level;
  final String question;
  final int marks;
  final String? note;

  LongQuestionPart({
    required this.part,
    required this.level,
    required this.question,
    required this.marks,
    this.note,
  });

  factory LongQuestionPart.fromJson(Map<String, dynamic> json) =>
      LongQuestionPart(
        part: json['part'] as String,
        level: json['level'] as String,
        question: json['question'] as String,
        marks: json['marks'] as int,
        note: json['note'] as String?,
      );
}

class LongQuestionContent extends EngramContent {
  final String questionStem;
  final List<LongQuestionPart> parts;
  final String severity;
  final int totalMarks;

  LongQuestionContent({
    required this.questionStem,
    required this.parts,
    required this.severity,
    required this.totalMarks,
  });

  factory LongQuestionContent.fromJson(Map<String, dynamic> json) =>
      LongQuestionContent(
        questionStem: json['question_stem'] as String,
        parts:
            (json['parts'] as List)
                .map(
                  (p) => LongQuestionPart.fromJson(p as Map<String, dynamic>),
                )
                .toList(),
        severity: json['severity'] as String,
        totalMarks: json['total_marks'] as int,
      );
}

class Engram {
  final String id;
  final String noteId;
  final EngramType type;
  final int targetCognitiveLevel;
  final List<String> tags;
  final EngramContent content;

  Engram({
    required this.id,
    required this.noteId,
    required this.type,
    required this.targetCognitiveLevel,
    required this.tags,
    required this.content,
  });

  factory Engram.fromJson(Map<String, dynamic> json) {
    final type = _parseEngramType(json['type'] as String);
    final rawContent = json['content'] as Map<String, dynamic>;

    late final EngramContent content;
    switch (type) {
      case EngramType.mcq:
        content = McqContent.fromJson(rawContent);
        break;
      case EngramType.flashcard:
        content = FlashcardContent.fromJson(rawContent);
        break;
      case EngramType.shortQuestion:
        content = ShortQuestionContent.fromJson(rawContent);
        break;
      case EngramType.longQuestion:
        content = LongQuestionContent.fromJson(rawContent);
        break;
      case EngramType.unknown:
        throw FormatException('Unknown engram type: ${json['type']}');
    }

    return Engram(
      id: json['id'] as String,
      noteId: json['note_id'] as String,
      type: type,
      targetCognitiveLevel: json['target_cognitive_level'] as int,
      tags: List<String>.from(json['tags'] as List),
      content: content,
    );
  }
}

class EngramListResponse {
  final String? bubbleId;
  final String? noteId;
  final int count;
  final List<Engram> engrams;

  EngramListResponse({
    this.bubbleId,
    this.noteId,
    required this.count,
    required this.engrams,
  });

  factory EngramListResponse.fromJson(Map<String, dynamic> json) =>
      EngramListResponse(
        bubbleId: json['bubble_id'] as String?,
        noteId: json['note_id'] as String?,
        count: json['count'] as int,
        engrams:
            (json['engrams'] as List)
                .map((e) => Engram.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
}
