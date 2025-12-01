part of 'game_cubit.dart';

/// Base class for game events (reserved for future event-based architecture)
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Events for future network implementation
class OpponentMadeMove extends GameEvent {
  final String characterId;
  final bool isGuess;

  const OpponentMadeMove({
    required this.characterId,
    required this.isGuess,
  });

  @override
  List<Object?> get props => [characterId, isGuess];
}
