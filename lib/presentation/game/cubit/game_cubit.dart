import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/game_state.dart';
import '../../../data/models/game_enums.dart';
import '../../../data/models/deck.dart';

part 'game_event.dart';

/// Game Cubit manages all game logic in a network-agnostic way.
/// It can be used for both Pass & Play and Online multiplayer.
class GameCubit extends Cubit<GameState> {
  GameCubit() : super(_initialState());

  static GameState _initialState() {
    final now = DateTime.now();
    // This will be replaced when a real game is started
    return GameState.initial(
      gameId: 'temp',
      deck: Deck(
        id: 'temp',
        name: 'Temp',
        characters: const [],
        createdAt: now,
        updatedAt: now,
      ),
      mode: GameMode.passAndPlay,
    );
  }

  /// Start a new game with a specific deck
  void startGame({
    required Deck deck,
    required GameMode mode,
  }) {
    final gameId = DateTime.now().millisecondsSinceEpoch.toString();
    emit(GameState.initial(
      gameId: gameId,
      deck: deck,
      mode: mode,
    ));
  }

  /// Transition from setup to player 1 character selection
  void beginCharacterSelection() {
    if (state.phase != GamePhase.setup) return;

    emit(state.copyWith(phase: GamePhase.player1Selection));
  }

  /// Player 1 selects their secret character
  void player1SelectCharacter(String characterId) {
    if (state.phase != GamePhase.player1Selection) return;

    final updatedBoard = state.player1Board.copyWith(
      secretCharacterId: characterId,
    );

    emit(state.copyWith(
      player1Board: updatedBoard,
      phase: GamePhase.player2Selection,
    ));
  }

  /// Player 2 selects their secret character
  void player2SelectCharacter(String characterId) {
    if (state.phase != GamePhase.player2Selection) return;

    final updatedBoard = state.player2Board.copyWith(
      secretCharacterId: characterId,
    );

    // Both players ready, start the game
    emit(state.copyWith(
      player2Board: updatedBoard,
      phase: GamePhase.playing,
      currentPlayer: 1,
      currentAction: TurnAction.asking,
    ));
  }

  /// Start a player's turn (called after curtain screen)
  void startTurn(int player) {
    if (state.phase != GamePhase.playing) return;
    if (state.currentPlayer != player) return;

    // Reset flipped state for new turn
    emit(state.copyWith(
      currentPlayer: player,
      currentAction: TurnAction.asking,
      hasFlippedThisTurn: false,
    ));
  }

  /// Toggle between asking and guessing mode
  void toggleGuessMode() {
    if (state.phase != GamePhase.playing) return;

    final newAction = state.currentAction == TurnAction.asking
        ? TurnAction.guessing
        : TurnAction.asking;

    emit(state.copyWith(currentAction: newAction));
  }

  /// Eliminate/restore a character on the current player's board
  void toggleCharacter(String characterId) {
    if (state.phase != GamePhase.playing) return;
    if (state.currentAction != TurnAction.asking) return;

    final currentBoard = state.getBoardForPlayer(state.currentPlayer);
    final updatedBoard = currentBoard.toggleCharacter(characterId);

    if (state.currentPlayer == 1) {
      emit(state.copyWith(
        player1Board: updatedBoard,
        hasFlippedThisTurn: true,
      ));
    } else {
      emit(state.copyWith(
        player2Board: updatedBoard,
        hasFlippedThisTurn: true,
      ));
    }
  }

  /// Make a guess (player taps on a character in guess mode)
  void makeGuess(String guessedCharacterId) {
    if (state.phase != GamePhase.playing) return;
    if (state.currentAction != TurnAction.guessing) return;

    final opponentBoard = state.getOpponentBoard(state.currentPlayer);
    final isCorrect = opponentBoard.secretCharacterId == guessedCharacterId;

    if (isCorrect) {
      // Player guessed correctly - they win!
      _endGame(winner: state.currentPlayer);
    } else {
      // Wrong guess - eliminate the guessed character and end turn
      final currentBoard = state.getBoardForPlayer(state.currentPlayer);
      final updatedBoard = currentBoard.eliminateCharacter(guessedCharacterId);

      if (state.currentPlayer == 1) {
        emit(state.copyWith(
          player1Board: updatedBoard,
          currentPlayer: state.nextPlayer,
          currentAction: TurnAction.asking,
        ));
      } else {
        emit(state.copyWith(
          player2Board: updatedBoard,
          currentPlayer: state.nextPlayer,
          currentAction: TurnAction.asking,
        ));
      }
    }
  }

  /// End the current player's turn (after asking questions)
  void endTurn() {
    if (state.phase != GamePhase.playing) return;
    if (state.currentAction != TurnAction.asking) return;

    final opponentBoard = state.getOpponentBoard(state.currentPlayer);

    // Check if opponent has only 1 character left
    // If so, the current player MUST guess on their next turn
    // But for now, we just switch turns

    emit(state.copyWith(
      currentPlayer: state.nextPlayer,
      currentAction: TurnAction.asking,
      hasFlippedThisTurn: false,
    ));
  }

  /// End the game with a winner
  void _endGame({required int winner}) {
    final result = winner == 1 ? GameResult.player1Won : GameResult.player2Won;

    emit(state.copyWith(
      phase: GamePhase.finished,
      winner: winner,
      result: result,
      finishedAt: DateTime.now(),
    ));
  }

  /// Reset the game (return to menu)
  void resetGame() {
    emit(_initialState());
  }

  /// Load a saved game state (for future persistence feature)
  void loadGame(GameState savedState) {
    emit(savedState);
  }
}
