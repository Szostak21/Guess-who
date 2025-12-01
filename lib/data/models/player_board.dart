import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'character_state.dart';

part 'player_board.g.dart';

/// Represents a player's view of the game board.
/// Each player has independent elimination states for all characters.
@JsonSerializable()
class PlayerBoard extends Equatable {
  final String playerId;
  
  /// The character this player is defending (secret)
  final String? secretCharacterId;
  
  /// The state of all characters on this player's board
  final List<CharacterState> characterStates;

  const PlayerBoard({
    required this.playerId,
    this.secretCharacterId,
    required this.characterStates,
  });

  factory PlayerBoard.fromJson(Map<String, dynamic> json) =>
      _$PlayerBoardFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerBoardToJson(this);

  /// Create an initial board with all characters active
  factory PlayerBoard.initial({
    required String playerId,
    required List<String> characterIds,
    String? secretCharacterId,
  }) {
    return PlayerBoard(
      playerId: playerId,
      secretCharacterId: secretCharacterId,
      characterStates: characterIds
          .map((id) => CharacterState(characterId: id, isEliminated: false))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [playerId, secretCharacterId, characterStates];

  /// Get the number of active (non-eliminated) characters
  int get activeCharacterCount {
    return characterStates.where((state) => !state.isEliminated).length;
  }

  /// Check if a specific character is eliminated
  bool isCharacterEliminated(String characterId) {
    final state = characterStates.firstWhere(
      (s) => s.characterId == characterId,
      orElse: () => const CharacterState(characterId: '', isEliminated: false),
    );
    return state.isEliminated;
  }

  /// Toggle a character's elimination state
  PlayerBoard toggleCharacter(String characterId) {
    final updatedStates = characterStates.map((state) {
      if (state.characterId == characterId) {
        return state.toggle();
      }
      return state;
    }).toList();

    return copyWith(characterStates: updatedStates);
  }

  /// Eliminate a specific character
  PlayerBoard eliminateCharacter(String characterId) {
    final updatedStates = characterStates.map((state) {
      if (state.characterId == characterId) {
        return state.copyWith(isEliminated: true);
      }
      return state;
    }).toList();

    return copyWith(characterStates: updatedStates);
  }

  PlayerBoard copyWith({
    String? playerId,
    String? secretCharacterId,
    List<CharacterState>? characterStates,
  }) {
    return PlayerBoard(
      playerId: playerId ?? this.playerId,
      secretCharacterId: secretCharacterId ?? this.secretCharacterId,
      characterStates: characterStates ?? this.characterStates,
    );
  }
}
