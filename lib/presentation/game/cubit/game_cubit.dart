import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/game_state.dart';
import '../../../data/models/game_enums.dart';
import '../../../data/models/deck.dart';
import '../../../data/services/local_lobby_manager.dart';
import '../../../data/services/game_websocket_service.dart';
import '../../../data/models/websocket_message.dart';

part 'game_event.dart';

/// Game Cubit manages all game logic in a network-agnostic way.
/// It can be used for both Pass & Play and Online multiplayer.
class GameCubit extends Cubit<GameState> {
  // ignore: unused_field
  final LocalLobbyManager? _lobbyManager;
  final GameWebSocketService? _wsService;
  StreamSubscription<WebSocketMessage>? _wsSubscription;

  // ignore: unused_field
  String? _lobbyCode;
  String? _playerId;
  bool _isHost = false;

  GameCubit({
    LocalLobbyManager? lobbyManager,
    GameWebSocketService? wsService,
  })  : _lobbyManager = lobbyManager,
        _wsService = wsService,
        super(_initialState()) {
    // Listen to WebSocket messages if in online mode
    if (_wsService != null) {
      _wsSubscription = _wsService.messages.listen(_handleWebSocketMessage);
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }

  /// Get the player number for this device (1 if host, 2 if guest)
  /// Returns null for Pass & Play mode
  int? get myPlayerNumber {
    if (state.mode == GameMode.passAndPlay) return null;
    return _isHost ? 1 : 2;
  }

  /// Check if this device is the host
  bool get isHost => _isHost;

  /// Get the player ID for this device
  String? get playerId => _playerId;

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(WebSocketMessage message) {
    final data = message.data;
    if (data == null) return;

    try {
      switch (message.type) {
        case MessageType.gameStateUpdate:
          // Partial game state update - preserve local deck with images
          final gameStateJson = data['gameState'] as Map<String, dynamic>;

          // Parse the incoming state (with the host's deck)
          final incomingState = GameState.fromJson(gameStateJson);

          // Apply the update but keep our local deck to preserve image paths
          emit(incomingState.copyWith(
            deck: state.deck, // Keep local deck with image paths
          ));
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  /// Send game state update to opponent via WebSocket
  void _sendStateUpdate() {
    if (state.mode != GameMode.online || _wsService == null) return;

    try {
      _wsService.sendMessage({
        'type': 'gameStateUpdate',
        'data': {
          'gameState': state.toJson(),
          'lobbyCode': _lobbyCode,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending state update: $e');
    }
  }

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
    String? lobbyCode,
    String? playerId,
    bool isHost = false,
  }) {
    final gameId = DateTime.now().millisecondsSinceEpoch.toString();

    // Store online mode info
    _lobbyCode = lobbyCode;
    _playerId = playerId;
    _isHost = isHost;

    emit(
      GameState.initial(
        gameId: gameId,
        deck: deck,
        mode: mode,
      ),
    );
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

    emit(
      state.copyWith(
        player1Board: updatedBoard,
        phase: GamePhase.player2Selection,
      ),
    );

    _sendStateUpdate();
  }

  /// Player 2 selects their secret character
  void player2SelectCharacter(String characterId) {
    if (state.phase != GamePhase.player2Selection) return;

    final updatedBoard = state.player2Board.copyWith(
      secretCharacterId: characterId,
    );

    // Both players ready, start the game
    emit(
      state.copyWith(
        player2Board: updatedBoard,
        phase: GamePhase.playing,
        currentPlayer: 1,
        currentAction: TurnAction.asking,
      ),
    );

    _sendStateUpdate();
  }

  /// Start a player's turn (called after curtain screen)
  void startTurn(int player) {
    if (state.phase != GamePhase.playing) return;
    if (state.currentPlayer != player) return;

    // Reset flipped state for new turn
    emit(
      state.copyWith(
        currentPlayer: player,
        currentAction: TurnAction.asking,
        hasFlippedThisTurn: false,
        flippedThisTurn: {},
      ),
    );
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
    final characterState = currentBoard.characterStates
        .firstWhere((s) => s.characterId == characterId);
    final updatedBoard = currentBoard.toggleCharacter(characterId);

    // Track flipped characters this turn
    final newFlippedSet = Set<String>.from(state.flippedThisTurn);

    if (!characterState.isEliminated) {
      // Character is being flipped to eliminated - add to set
      newFlippedSet.add(characterId);
    } else {
      // Character is being unflipped - remove from set
      newFlippedSet.remove(characterId);
    }

    // hasFlippedThisTurn is true only if there are characters in the set
    final hasFlipped = newFlippedSet.isNotEmpty;

    if (state.currentPlayer == 1) {
      emit(
        state.copyWith(
          player1Board: updatedBoard,
          hasFlippedThisTurn: hasFlipped,
          flippedThisTurn: newFlippedSet,
        ),
      );
    } else {
      emit(
        state.copyWith(
          player2Board: updatedBoard,
          hasFlippedThisTurn: hasFlipped,
          flippedThisTurn: newFlippedSet,
        ),
      );
    }

    _sendStateUpdate();
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
        emit(
          state.copyWith(
            player1Board: updatedBoard,
            currentPlayer: state.nextPlayer,
            currentAction: TurnAction.asking,
          ),
        );
      } else {
        emit(
          state.copyWith(
            player2Board: updatedBoard,
            currentPlayer: state.nextPlayer,
            currentAction: TurnAction.asking,
          ),
        );
      }
    }

    _sendStateUpdate();
  }

  /// End the current player's turn (after asking questions)
  void endTurn() {
    if (state.phase != GamePhase.playing) return;
    if (state.currentAction != TurnAction.asking) return;

    emit(
      state.copyWith(
        currentPlayer: state.nextPlayer,
        currentAction: TurnAction.asking,
        hasFlippedThisTurn: false,
        flippedThisTurn: {},
      ),
    );

    _sendStateUpdate();
  }

  /// End the game with a winner
  void _endGame({required int winner}) {
    final result = winner == 1 ? GameResult.player1Won : GameResult.player2Won;

    emit(
      state.copyWith(
        phase: GamePhase.finished,
        winner: winner,
        result: result,
        finishedAt: DateTime.now(),
      ),
    );

    _sendStateUpdate();
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
