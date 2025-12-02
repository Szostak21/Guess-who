import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/lobby_cubit.dart';
import '../../../data/models/deck.dart';
import '../../../data/models/game_enums.dart';
import '../../game/cubit/game_cubit.dart';
import '../../game/screens/game_screen.dart';

/// Screen for creating and waiting in a lobby
class CreateLobbyScreen extends StatefulWidget {
  final Deck deck;
  final String playerName;

  const CreateLobbyScreen({
    super.key,
    required this.deck,
    required this.playerName,
  });

  @override
  State<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Create lobby when screen loads
    context.read<LobbyCubit>().createLobby(
          playerName: widget.playerName,
          deck: widget.deck,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Lobby'),
        centerTitle: true,
      ),
      body: BlocConsumer<LobbyCubit, LobbyState>(
        listener: (context, state) {
          if (state.status == LobbyStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == LobbyStateStatus.ready) {
            // Both players ready, show start button
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Player joined! Ready to start!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == LobbyStateStatus.creating) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final lobby = state.lobby;
          if (lobby == null) {
            return const Center(
              child: Text('Failed to create lobby'),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lobby code card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.vpn_key,
                              size: 48,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Share this with your friend:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // IP Address
                            if (state.serverIp != null) ...[
                              Text(
                                'Server IP:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.serverIp!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: state.serverIp!),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('IP copied!'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 18),
                                    tooltip: 'Copy IP',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                            ],
                            // Lobby Code
                            Text(
                              'Lobby Code:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lobby.code,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: lobby.code),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Code copied to clipboard!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy code',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Deck info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.style, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.deck.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.deck.characters.length} characters',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Players section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Players',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PlayerTile(
                              name: lobby.hostName,
                              isHost: true,
                              isReady: true,
                            ),
                            const SizedBox(height: 8),
                            lobby.guestName != null
                                ? _PlayerTile(
                                    name: lobby.guestName!,
                                    isHost: false,
                                    isReady: true,
                                  )
                                : _WaitingPlayerTile(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Start game button (only when both players ready)
                    if (state.status == LobbyStateStatus.ready)
                      ElevatedButton(
                        onPressed: () => _startGame(context, state),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'START GAME',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    if (state.status != LobbyStateStatus.ready)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Waiting for player...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startGame(BuildContext context, LobbyState lobbyState) {
    final lobbyCubit = context.read<LobbyCubit>();
    lobbyCubit.startGame();

    // Create a new GameCubit with the WebSocket service
    final gameCubit = GameCubit(wsService: lobbyCubit.wsService);
    gameCubit.startGame(
      deck: widget.deck,
      mode: GameMode.online,
      lobbyCode: lobbyState.lobby!.code,
      playerId: lobbyState.playerId!,
      isHost: lobbyState.isHost,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: lobbyCubit),
            BlocProvider.value(value: gameCubit),
          ],
          child: const GameScreen(),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final String name;
  final bool isHost;
  final bool isReady;

  const _PlayerTile({
    required this.name,
    required this.isHost,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isHost ? Icons.star : Icons.person,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isReady)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}

class _WaitingPlayerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Waiting for player...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
