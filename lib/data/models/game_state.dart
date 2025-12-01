import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'deck.dart';
import 'player_board.dart';
import 'game_enums.dart';

part 'game_state.g.dart';

/// Represents the complete state of a game session.
/// This is network-agnostic and can be used for both local and online play.
@JsonSerializable()
class GameState extends Equatable {
  final String gameId;
  final Deck deck;
  final GameMode mode;
  final GamePhase phase;

  /// Current player (1 or 2)
  final int currentPlayer;

  /// Current turn action (asking or guessing)
  final TurnAction? currentAction;

  /// Whether the current player has flipped any characters this turn
  final bool hasFlippedThisTurn;

  /// Set of character IDs flipped this turn (for tracking unflips)
  final Set<String> flippedThisTurn;

  final PlayerBoard player1Board;
  final PlayerBoard player2Board;

  /// Winner (1 or 2, null if game not finished)
  final int? winner;

  /// Game result details
  final GameResult? result;

  final DateTime createdAt;
  final DateTime? finishedAt;

  const GameState({
    required this.gameId,
    required this.deck,
    required this.mode,
    required this.phase,
    required this.currentPlayer,
    this.currentAction,
    this.hasFlippedThisTurn = false,
    this.flippedThisTurn = const {},
    required this.player1Board,
    required this.player2Board,
    this.winner,
    this.result,
    required this.createdAt,
    this.finishedAt,
  });

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  /// Create initial game state during setup phase
  factory GameState.initial({
    required String gameId,
    required Deck deck,
    required GameMode mode,
  }) {
    final characterIds = deck.characters.map((c) => c.id).toList();
    final now = DateTime.now();

    return GameState(
      gameId: gameId,
      deck: deck,
      mode: mode,
      phase: GamePhase.setup,
      currentPlayer: 1,
      currentAction: null,
      player1Board: PlayerBoard.initial(
        playerId: 'player1',
        characterIds: characterIds,
      ),
      player2Board: PlayerBoard.initial(
        playerId: 'player2',
        characterIds: characterIds,
      ),
      createdAt: now,
    );
  }

  @override
  List<Object?> get props => [
        gameId,
        deck,
        mode,
        phase,
        currentPlayer,
        currentAction,
        hasFlippedThisTurn,
        flippedThisTurn,
        player1Board,
        player2Board,
        winner,
        result,
        createdAt,
        finishedAt,
      ];

  /// Get the board for a specific player
  PlayerBoard getBoardForPlayer(int player) {
    return player == 1 ? player1Board : player2Board;
  }

  /// Get the opponent's board
  PlayerBoard getOpponentBoard(int player) {
    return player == 1 ? player2Board : player1Board;
  }

  /// Check if both players have selected their characters
  bool get bothPlayersReady {
    return player1Board.secretCharacterId != null &&
        player2Board.secretCharacterId != null;
  }

  /// Get the other player number
  int get nextPlayer => currentPlayer == 1 ? 2 : 1;

  GameState copyWith({
    String? gameId,
    Deck? deck,
    GameMode? mode,
    GamePhase? phase,
    int? currentPlayer,
    TurnAction? currentAction,
    bool? hasFlippedThisTurn,
    Set<String>? flippedThisTurn,
    PlayerBoard? player1Board,
    PlayerBoard? player2Board,
    int? winner,
    GameResult? result,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      deck: deck ?? this.deck,
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentAction: currentAction ?? this.currentAction,
      hasFlippedThisTurn: hasFlippedThisTurn ?? this.hasFlippedThisTurn,
      flippedThisTurn: flippedThisTurn ?? this.flippedThisTurn,
      player1Board: player1Board ?? this.player1Board,
      player2Board: player2Board ?? this.player2Board,
      winner: winner ?? this.winner,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}
