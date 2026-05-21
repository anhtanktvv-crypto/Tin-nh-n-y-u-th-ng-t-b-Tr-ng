import 'dart:math';
import 'dart:ui';

class MochiPattern {
  final List<String> keywords;
  final List<String> answers;
  const MochiPattern({required this.keywords, required this.answers});
  String getRandomAnswer(Random rand) => answers[rand.nextInt(answers.length)];
}

class Bubble {
  final int id;
  final Offset position;
  final String emoji;
  Bubble({required this.id, required this.position, required this.emoji});
}

class ActionItem {
  final String name;
  final String image;
  final String emoji;
  final String sound;
  final String category;

  const ActionItem({
    required this.name,
    required this.image,
    required this.emoji,
    required this.sound,
    required this.category,
  });

  Map<String, String> toMap() => {
        'n': name,
        'i': image,
        'e': emoji,
        's': sound,
        'c': category,
      };
}

class Category {
  final String key;
  final String title;

  const Category({required this.key, required this.title});
}

class FoodItem {
  final String name;
  final String emoji;
  final String category;

  const FoodItem({
    required this.name,
    required this.emoji,
    required this.category,
  });
}

class Song {
  final String name;
  final String file;

  const Song({required this.name, required this.file});
}

class QuickFlirt {
  final String emoji;
  final String text;

  const QuickFlirt({required this.emoji, required this.text});
}

class TodoItem {
  final String text;
  final bool done;
  final String createdBy;
  final String timestamp;

  TodoItem({
    required this.text,
    this.done = false,
    required this.createdBy,
    String? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toIso8601String();

  TodoItem copyWith({bool? done}) =>
      TodoItem(text: text, done: done ?? this.done, createdBy: createdBy, timestamp: timestamp);

  Map<String, dynamic> toJson() => {
        'text': text,
        'done': done,
        'createdBy': createdBy,
        'timestamp': timestamp,
      };
}

extension StringExtension on String {
  bool containsAny(List<String> keywords) =>
      keywords.any((kw) => toLowerCase().contains(kw.toLowerCase()));
}