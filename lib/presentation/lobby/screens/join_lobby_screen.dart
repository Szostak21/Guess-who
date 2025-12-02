import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/lobby_cubit.dart';
import '../../../data/models/game_enums.dart';
import '../../game/cubit/game_cubit.dart';
import '../../game/screens/game_screen.dart';

/// Screen for joining an existing lobby via code
class JoinLobbyScreen extends StatefulWidget {
  final String playerName;

  const JoinLobbyScreen({
    super.key,
    required this.playerName,
  });

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
  final _codeController = TextEditingController();
  final _ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Lobby', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: BlocConsumer<LobbyCubit, LobbyState>(
        listener: (context, state) {
          if (state.status == LobbyStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to join lobby'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == LobbyStateStatus.ready) {
            // Show success message but don't navigate yet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Successfully joined! Waiting for host to start...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state.status == LobbyStateStatus.playing) {
            // Host started game, navigate now
            print('Guest: Navigating to game screen, status is playing');
            _startGame(context, state);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == LobbyStateStatus.joining;
          final lobby = state.lobby;

          // Show waiting screen if successfully joined
          if (state.status == LobbyStateStatus.ready && lobby != null) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Joined Successfully!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lobby Code: ${lobby.code}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              ),
                              const SizedBox(height: 8),
                              _PlayerTile(
                                name: widget.playerName,
                                isHost: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Waiting for host to start game...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // Icon
                      const Icon(
                        Icons.login,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Join Game',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the host IP address and lobby code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // IP Address input
                      TextFormField(
                        controller: _ipController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Host IP Address',
                          hintText: '192.168.1.100',
                          prefixIcon: const Icon(Icons.wifi),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter host IP address';
                          }
                          // Basic IP validation
                          final ipRegex =
                              RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
                          if (!ipRegex.hasMatch(value)) {
                            return 'Invalid IP address format';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Code input
                      TextFormField(
                        controller: _codeController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Lobby Code',
                          hintText: 'ABC123',
                          prefixIcon: const Icon(Icons.vpn_key),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontFamily: 'monospace',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a lobby code';
                          }
                          if (value.length != 6) {
                            return 'Code must be 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Join button
                      ElevatedButton(
                        onPressed: isLoading ? null : _joinLobby,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blue,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'JOIN LOBBY',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),

                      const SizedBox(height: 32),

                      // Info card
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Make sure you and your friend are on the same WiFi network',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _joinLobby() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeController.text.trim().toUpperCase();
    final hostIp = _ipController.text.trim();

    context.read<LobbyCubit>().joinLobby(
          lobbyCode: code,
          playerName: widget.playerName,
          hostIp: hostIp,
        );
  }

  void _startGame(BuildContext context, LobbyState lobbyState) {
    final lobbyCubit = context.read<LobbyCubit>();

    // Create a new GameCubit with the WebSocket service
    final gameCubit = GameCubit(wsService: lobbyCubit.wsService);
    gameCubit.startGame(
      deck: lobbyState.lobby!.deck,
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

  const _PlayerTile({
    required this.name,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHost ? Icons.stars : Icons.person,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isHost ? 'Host' : 'Guest',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
