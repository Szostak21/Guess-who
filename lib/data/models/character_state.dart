import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character_state.g.dart';

/// Represents the state of a character on a player's board
@JsonSerializable()
class CharacterState extends Equatable {
  final String characterId;
  final bool isEliminated;

  const CharacterState({
    required this.characterId,
    required this.isEliminated,
  });

  factory CharacterState.fromJson(Map<String, dynamic> json) =>
      _$CharacterStateFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterStateToJson(this);

  @override
  List<Object?> get props => [characterId, isEliminated];

  CharacterState copyWith({
    String? characterId,
    bool? isEliminated,
  }) {
    return CharacterState(
      characterId: characterId ?? this.characterId,
      isEliminated: isEliminated ?? this.isEliminated,
    );
  }

  /// Toggle elimination status
  CharacterState toggle() {
    return copyWith(isEliminated: !isEliminated);
  }
}
