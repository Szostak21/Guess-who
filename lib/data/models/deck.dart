import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';
import 'character.dart';

export 'character.dart';

part 'deck.g.dart';

/// Represents a collection of characters that can be used in a game.
/// Deck size must form a rectangle (e.g., 9, 12, 15, 16, 20, 25).
@JsonSerializable()
class Deck extends Equatable {
  final String id;
  final String name;
  final List<Character> characters;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBaseDeck;

  const Deck({
    required this.id,
    required this.name,
    required this.characters,
    required this.createdAt,
    required this.updatedAt,
    this.isBaseDeck = false,
  });

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

  Map<String, dynamic> toJson() => _$DeckToJson(this);

  @override
  List<Object?> get props =>
      [id, name, characters, createdAt, updatedAt, isBaseDeck];

  /// Returns the number of characters in the deck
  int get size => characters.length;

  /// Returns the dimensions for grid display (rows, columns)
  /// Portrait mode: columns should always be >= rows, but as square as possible (cols - rows <= 1)
  /// For example: 6 -> (2, 3), 9 -> (3, 3), 12 -> (3, 4), 15 -> (4, 4) partial, 20 -> (4, 5)
  (int rows, int cols) get gridDimensions {
    final count = characters.length;

    // Find the most square-like dimensions where cols >= rows and cols - rows <= 1
    for (int rows = (count / 2).floor(); rows >= 1; rows--) {
      final cols = (count / rows).ceil();
      // Ensure cols >= rows and difference is at most 1
      if (cols >= rows && cols - rows <= 1 && rows * cols >= count) {
        return (rows, cols);
      }
    }

    // Fallback (should rarely happen)
    final sqrtVal = sqrt(count.toDouble()).floor();
    return (sqrtVal, (count / sqrtVal).ceil());
  }

  /// Validates if the deck size can form a rectangle
  bool get isValidSize {
    final count = characters.length;
    if (count < 9) return false;

    for (int i = 2; i <= (count / 2).ceil(); i++) {
      if (count % i == 0) return true;
    }
    return false;
  }

  Deck copyWith({
    String? id,
    String? name,
    List<Character>? characters,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBaseDeck,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      characters: characters ?? this.characters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBaseDeck: isBaseDeck ?? this.isBaseDeck,
    );
  }
}
