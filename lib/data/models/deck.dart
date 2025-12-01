import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
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

  const Deck({
    required this.id,
    required this.name,
    required this.characters,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

  Map<String, dynamic> toJson() => _$DeckToJson(this);

  @override
  List<Object?> get props => [id, name, characters, createdAt, updatedAt];

  /// Returns the number of characters in the deck
  int get size => characters.length;

  /// Returns the dimensions for grid display (rows, columns)
  /// Optimized for portrait mode: more rows than columns
  /// For example: 9 -> (3, 3), 12 -> (4, 3), 15 -> (5, 3), 20 -> (5, 4)
  (int rows, int cols) get gridDimensions {
    final count = characters.length;
    
    // Find optimal rectangle dimensions (prefer more rows for portrait)
    for (int cols = 3; cols <= (count / 2).ceil(); cols++) {
      if (count % cols == 0) {
        return (count ~/ cols, cols);
      }
    }
    
    // Fallback (should not happen with valid deck sizes)
    return ((count / 3).ceil(), 3);
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
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      characters: characters ?? this.characters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
