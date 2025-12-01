import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character.g.dart';

/// Represents a single character in the game deck.
/// Contains the character's identity and optional image path.
@JsonSerializable()
class Character extends Equatable {
  final String id;
  final String name;
  
  /// Path to the character image (local file path or asset path)
  final String? imagePath;

  const Character({
    required this.id,
    required this.name,
    this.imagePath,
  });

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);

  @override
  List<Object?> get props => [id, name, imagePath];

  Character copyWith({
    String? id,
    String? name,
    String? imagePath,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
