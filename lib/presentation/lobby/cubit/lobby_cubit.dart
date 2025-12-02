import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../../data/models/lobby.dart';
import '../../../data/models/deck.dart';
import '../../../data/models/websocket_message.dart';
import '../../../data/services/p2p_websocket_server.dart';
import '../../../data/services/game_websocket_service.dart';
import 'dart:math';

part 'lobby_state.dart';

/// Cubit for managing online game lobbies with P2P WebSocket connections
class LobbyCubit extends Cubit<LobbyState> {
  final P2PWebSocketServer _server;
  final GameWebSocketService _wsService;
  Lobby? _lobby;
  bool _gameInProgress = false;

  LobbyCubit({
    P2PWebSocketServer? server,
    GameWebSocketService? wsService,
  })  : _server = server ?? P2PWebSocketServer(),
        _wsService = wsService ?? GameWebSocketService(),
        super(const LobbyState());

  /// Get the WebSocket service for game communication
  GameWebSocketService get wsService => _wsService;

  /// Generate a unique player ID
  String _generatePlayerId() {
    final random = Random();
    return 'player_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}';
  }

  /// Create a new lobby as host (starts P2P server on this phone)
  Future<void> createLobby({
    required String playerName,
    required Deck deck,
  }) async {
    try {
      emit(state.copyWith(status: LobbyStateStatus.creating));

      final playerId = _generatePlayerId();

      // Start P2P WebSocket server on this phone
      final lobbyCode = await _server.start(
        hostId: playerId,
        hostName: playerName,
        deck: deck,
      );

      // Get local IP address for the connection
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();

      if (wifiIP == null) {
        emit(
          state.copyWith(
            status: LobbyStateStatus.error,
            errorMessage: 'Please connect to WiFi network',
          ),
        );
        return;
      }

      // Connect host to own server
      await _wsService.connect('ws://localhost:8080');

      // Listen for lobby updates from server
      _server.status.listen((status) {
        print('Server status: $status');
      });

      // Listen for player joined messages
      _wsService.messages.listen((message) {
        if (message.type.name == 'playerJoined') {
          final data = message.data!;
          final guestName = data['playerName'] as String;
          final guestId = data['playerId'] as String;

          final updatedLobby = state.lobby!.copyWith(
            guestId: guestId,
            guestName: guestName,
            status: LobbyStatus.ready,
          );

          emit(
            state.copyWith(
              lobby: updatedLobby,
              status: LobbyStateStatus.ready,
            ),
          );
        }
      });

      final lobby = Lobby(
        code: lobbyCode,
        hostId: playerId,
        hostName: playerName,
        status: LobbyStatus.waiting,
        deck: deck,
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          lobby: lobby,
          playerId: playerId,
          isHost: true,
          status: LobbyStateStatus.waiting,
          serverIp: wifiIP,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LobbyStateStatus.error,
          errorMessage: 'Failed to create lobby: $e',
        ),
      );
    }
  }

  /// Join an existing lobby (connect to host's phone)
  Future<void> joinLobby({
    required String lobbyCode,
    required String playerName,
    required String hostIp,
  }) async {
    try {
      emit(state.copyWith(status: LobbyStateStatus.joining));

      final playerId = _generatePlayerId();

      // Connect to host's P2P server
      await _wsService.connect('ws://$hostIp:8080');

      // Listen for start_game message from host BEFORE joining
      _wsService.messages.listen((message) {
        print('Guest received WebSocket message: ${message.type}');
        if (message.type == MessageType.startGame) {
          print('Guest: Received startGame message, updating state to playing');
          final updatedLobby =
              state.lobby!.copyWith(status: LobbyStatus.playing);
          emit(
            state.copyWith(
              lobby: updatedLobby,
              status: LobbyStateStatus.playing,
            ),
          );
        }
      });

      // Send join request
      final lobby = await _wsService.joinLobby(
        lobbyCode: lobbyCode,
        playerId: playerId,
        playerName: playerName,
      );

      print('Guest joined lobby successfully, WebSocket connected');

      emit(
        state.copyWith(
          lobby: lobby,
          playerId: playerId,
          isHost: false,
          status: LobbyStateStatus.ready,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LobbyStateStatus.error,
          errorMessage: 'Failed to join lobby: $e',
        ),
      );
    }
  }

  /// Start the game
  void startGame() {
    if (state.lobby == null) return;

    _gameInProgress = true;
    final updatedLobby = state.lobby!.copyWith(status: LobbyStatus.playing);
    emit(
      state.copyWith(
        lobby: updatedLobby,
        status: LobbyStateStatus.playing,
      ),
    );

    // Send startGame message to guest if host
    if (state.isHost) {
      print('Host sending startGame message to guest');
      _wsService.sendMessage({
        'type': MessageType.startGame.name,
        'lobbyCode': updatedLobby.code,
      });
    }
  }

  /// Leave the current lobby
  void leaveLobby() {
    _wsService.disconnect();
    if (state.isHost) {
      _server.stop();
    }
    emit(const LobbyState());
  }

  @override
  Future<void> close() {
    // Don't disconnect if game is in progress - GameCubit will handle cleanup
    if (!_gameInProgress) {
      leaveLobby();
    }
    return super.close();
  }

  /// End game and cleanup (called when returning to menu)
  void endGame() {
    _gameInProgress = false;
    leaveLobby();
  }
}
