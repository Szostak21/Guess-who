import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/game_cubit.dart';
import '../../../data/models/game_state.dart';
import '../../../data/models/game_enums.dart';
import '../widgets/character_card.dart';
import '../widgets/curtain_screen.dart';

/// Main game screen that handles all game phases
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showCurtain = false;
  bool _showPlayer2Curtain = false;
  int? _previousPlayer;

  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();
    final isOnlineMode = gameCubit.state.mode == GameMode.online;
    final myPlayerNumber = gameCubit.myPlayerNumber;

    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        // In Pass & Play mode, show curtains between phases and turns
        if (!isOnlineMode) {
          // Show curtain after Player 1 selects, before Player 2 selects
          if (state.phase == GamePhase.player2Selection &&
              !_showPlayer2Curtain) {
            setState(() {
              _showPlayer2Curtain = true;
            });
          }

          // Show curtain after wrong guess (player switched)
          if (state.phase == GamePhase.playing &&
              _previousPlayer != null &&
              _previousPlayer != state.currentPlayer) {
            setState(() {
              _showCurtain = true;
            });
          }
        }

        _previousPlayer = state.currentPlayer;
      },
      builder: (context, state) {
        // In Pass & Play mode, show curtains
        if (!isOnlineMode) {
          // Show curtain before Player 2 selection
          if (_showPlayer2Curtain &&
              state.phase == GamePhase.player2Selection) {
            return CurtainScreen(
              nextPlayer: 2,
              onContinue: () {
                setState(() {
                  _showPlayer2Curtain = false;
                });
              },
              title: 'Player 2 Turn',
              message: 'Now Player 2 will choose their person',
            );
          }

          // Show curtain screen between turns
          if (_showCurtain) {
            return CurtainScreen(
              nextPlayer: state.currentPlayer,
              onContinue: () {
                setState(() {
                  _showCurtain = false;
                });
                context.read<GameCubit>().startTurn(state.currentPlayer);
              },
            );
          }
        }

        // Game phase routing
        switch (state.phase) {
          case GamePhase.setup:
            return _buildSetupScreen(
              context,
              state,
              isOnlineMode,
              myPlayerNumber,
            );
          case GamePhase.player1Selection:
            // In online mode, show selection for appropriate player
            if (isOnlineMode && myPlayerNumber != null) {
              return _buildCharacterSelectionScreen(
                context,
                state,
                myPlayerNumber,
              );
            }
            return _buildCharacterSelectionScreen(context, state, 1);
          case GamePhase.player2Selection:
            // In online mode, player 2 also sees their own selection screen
            if (isOnlineMode && myPlayerNumber != null) {
              if (myPlayerNumber == 2) {
                return _buildCharacterSelectionScreen(context, state, 2);
              }
              // Player 1 waits for player 2
              return _buildWaitingScreen(
                context,
                state,
                'Waiting for opponent to choose...',
              );
            }
            return _buildCharacterSelectionScreen(context, state, 2);
          case GamePhase.playing:
            return _buildPlayingScreen(
              context,
              state,
              isOnlineMode,
              myPlayerNumber,
            );
          case GamePhase.finished:
            return _buildFinishedScreen(context, state);
        }
      },
    );
  }

  Widget _buildWaitingScreen(
    BuildContext context,
    GameState state,
    String message,
  ) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Waiting...'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupScreen(
    BuildContext context,
    GameState state,
    bool isOnlineMode,
    int? myPlayerNumber,
  ) {
    // In online mode, no setup curtain needed - go straight to selection
    if (isOnlineMode) {
      // Automatically start character selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GameCubit>().beginCharacterSelection();
      });
      return _buildWaitingScreen(context, state, 'Starting game...');
    }

    return CurtainScreen(
      nextPlayer: 1,
      onContinue: () {
        context.read<GameCubit>().beginCharacterSelection();
      },
      title: 'Ready to Start',
      message: 'Player 1 will choose their person first',
    );
  }

  Widget _buildCharacterSelectionScreen(
    BuildContext context,
    GameState state,
    int player,
  ) {
    final playerBoard = state.getBoardForPlayer(player);
    final (rows, cols) = state.deck.gridDimensions;

    return Scaffold(
      backgroundColor: player == 1 ? Colors.blue.shade50 : Colors.red.shade50,
      appBar: AppBar(
        title: Text('Player $player: Choose Your Person'),
        backgroundColor: player == 1 ? Colors.blue : Colors.red,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Tap to select the person for opponent to guess',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: state.deck.characters.length,
                  itemBuilder: (context, index) {
                    final character = state.deck.characters[index];
                    final characterState = playerBoard.characterStates[index];

                    return CharacterCard(
                      character: character,
                      state: characterState,
                      isSelectionMode: true,
                      isSelected: false,
                      onTap: () {
                        if (player == 1) {
                          context
                              .read<GameCubit>()
                              .player1SelectCharacter(character.id);
                        } else {
                          context
                              .read<GameCubit>()
                              .player2SelectCharacter(character.id);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayingScreen(
    BuildContext context,
    GameState state,
    bool isOnlineMode,
    int? myPlayerNumber,
  ) {
    // In online mode, determine whose board to show
    final displayPlayer = isOnlineMode && myPlayerNumber != null
        ? myPlayerNumber
        : state.currentPlayer;

    final currentBoard = state.getBoardForPlayer(displayPlayer);
    final opponentBoard = state.getOpponentBoard(displayPlayer);
    final (rows, cols) = state.deck.gridDimensions;

    // In online mode, check if it's this player's turn
    final isMyTurn = !isOnlineMode || (myPlayerNumber == state.currentPlayer);
    final isGuessMode = isMyTurn && state.currentAction == TurnAction.guessing;

    return Scaffold(
      backgroundColor:
          displayPlayer == 1 ? Colors.blue.shade50 : Colors.red.shade50,
      appBar: AppBar(
        title: Text(
          isOnlineMode
              ? (isMyTurn ? 'Your Turn' : 'Opponent\'s Turn')
              : 'Player ${state.currentPlayer} Turn',
        ),
        backgroundColor: displayPlayer == 1 ? Colors.blue : Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showGameInfo(context, state);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.all(16),
              color: isGuessMode ? Colors.blue.shade50 : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Opponent has ${opponentBoard.activeCharacterCount} characters left',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isGuessMode)
                    const Icon(Icons.help_outline, color: Colors.blue),
                  if (!isMyTurn && isOnlineMode)
                    Icon(Icons.hourglass_empty, color: Colors.grey.shade600),
                ],
              ),
            ),

            // Waiting message for online mode when it's not player's turn
            if (!isMyTurn && isOnlineMode)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Waiting for opponent to finish their turn...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Character grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: state.deck.characters.length,
                  itemBuilder: (context, index) {
                    final character = state.deck.characters[index];
                    final characterState = currentBoard.characterStates[index];

                    return CharacterCard(
                      character: character,
                      state: characterState,
                      onTap: () {
                        if (!isMyTurn) {
                          return; // Ignore taps when not player's turn
                        }

                        if (isGuessMode) {
                          _confirmGuess(context, character.name, () {
                            context.read<GameCubit>().makeGuess(character.id);
                          });
                        } else {
                          context
                              .read<GameCubit>()
                              .toggleCharacter(character.id);
                        }
                      },
                    );
                  },
                ),
              ),
            ),

            // Control buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isMyTurn && !state.hasFlippedThisTurn)
                          ? () {
                              context.read<GameCubit>().toggleGuessMode();
                            }
                          : null,
                      icon:
                          Icon(isGuessMode ? Icons.cancel : Icons.help_outline),
                      label: Text(isGuessMode ? 'Cancel Guess' : 'Guess'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isGuessMode ? Colors.grey : Colors.blue,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isMyTurn && !isGuessMode)
                          ? () {
                              if (isOnlineMode) {
                                // In online mode, just end turn without curtain
                                context.read<GameCubit>().endTurn();
                              } else {
                                // In Pass & Play mode, show curtain
                                setState(() {
                                  _showCurtain = true;
                                });
                                context.read<GameCubit>().endTurn();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.navigate_next),
                      label: const Text('End Turn'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedScreen(BuildContext context, GameState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 120,
              color: state.winner == 1 ? Colors.blue : Colors.red,
            ),
            const SizedBox(height: 32),
            Text(
              'Player ${state.winner} Wins!',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.read<GameCubit>().resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameInfo(BuildContext context, GameState state) {
    final currentBoard = state.getBoardForPlayer(state.currentPlayer);
    final secretChar = state.deck.characters.firstWhere(
      (c) => c.id == currentBoard.secretCharacterId,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Secret Character'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 64),
            const SizedBox(height: 16),
            Text(
              secretChar.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmGuess(
    BuildContext context,
    String characterName,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Guess'),
        content: Text(
          'Are you sure you want to guess "$characterName"?\n\nIf you\'re wrong, this character will be eliminated and your turn will end.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Guess'),
          ),
        ],
      ),
    );
  }
}
