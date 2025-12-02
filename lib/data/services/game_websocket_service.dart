import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/websocket_message.dart';
import '../models/lobby.dart';
import 'image_transfer_helper.dart';

/// Service for managing WebSocket connections for peer-to-peer multiplayer
/// Connects to host's phone WebSocket server (no cloud needed)
class GameWebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  String? _currentLobbyCode;
  String? _playerId;

  /// Stream of incoming WebSocket messages
  Stream<WebSocketMessage> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<bool> get connectionState => _connectionStateController.stream;

  /// Current lobby code
  String? get currentLobbyCode => _currentLobbyCode;

  /// Current player ID
  String? get playerId => _playerId;

  /// Check if currently connected
  bool get isConnected => _channel != null;

  /// Connect to WebSocket server (host's phone)
  ///
  /// For guest: url is ws://HOST_IP:8080
  /// For host: url is ws://localhost:8080 (connects to own server)
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final type = json['type'] as String;

            // Convert to WebSocketMessage
            final message = WebSocketMessage(
              type: MessageType.values.firstWhere(
                (e) => e.name == type,
                orElse: () => MessageType.error,
              ),
              data: json['data'] as Map<String, dynamic>?,
              error: json['error'] as String?,
              timestamp: DateTime.parse(
                json['timestamp'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
            );

            _messageController.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _connectionStateController.add(false);
          disconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          print('Stack trace: ${StackTrace.current}');
          _connectionStateController.add(false);
          disconnect();
        },
      );

      _connectionStateController.add(true);
    } catch (e) {
      print('Failed to connect: $e');
      _connectionStateController.add(false);
      rethrow;
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    print('GameWebSocketService: disconnect() called');
    print('Stack trace: ${StackTrace.current}');
    _channel?.sink.close();
    _channel = null;
    _currentLobbyCode = null;
    _playerId = null;
    _connectionStateController.add(false);
  }

  /// Send a WebSocket message
  void sendMessage(Map<String, dynamic> data) {
    if (_channel == null) {
      throw Exception('Not connected to server');
    }

    final json = jsonEncode(data);
    _channel!.sink.add(json);
  }

  /// Join an existing lobby (for guest player)
  Future<Lobby> joinLobby({
    required String lobbyCode,
    required String playerId,
    required String playerName,
  }) async {
    _playerId = playerId;
    _currentLobbyCode = lobbyCode;

    final data = {
      'type': MessageType.joinLobby.name,
      'data': {
        'lobbyCode': lobbyCode,
        'playerId': playerId,
        'playerName': playerName,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    sendMessage(data);

    // Wait for lobbyJoined response or error
    final response = await messages.firstWhere(
      (msg) =>
          msg.type == MessageType.lobbyJoined || msg.type == MessageType.error,
      orElse: () => throw Exception('Failed to join lobby'),
    );

    if (response.type == MessageType.error || response.error != null) {
      final errorMsg = response.error ??
          response.data?['message'] ??
          'Unknown error joining lobby';
      throw Exception(errorMsg);
    }

    try {
      // Decode images from base64 and save locally
      final lobbyData = Map<String, dynamic>.from(response.data!);
      print('Received lobby data keys: ${lobbyData.keys}');

      if (lobbyData['deck'] != null) {
        print('Deck data type: ${lobbyData['deck'].runtimeType}');

        // Get the deck data - it should be a Map from JSON
        final deckData = lobbyData['deck'];
        Map<String, dynamic> deckJson;

        // Check if it's already a Map or needs conversion
        if (deckData is Map<String, dynamic>) {
          deckJson = deckData;
        } else if (deckData is Map) {
          deckJson = Map<String, dynamic>.from(deckData);
        } else {
          throw Exception('Invalid deck data type: ${deckData.runtimeType}');
        }

        print('Deck characters type: ${deckJson['characters'].runtimeType}');
        if (deckJson['characters'] is List &&
            (deckJson['characters'] as List).isNotEmpty) {
          print(
            'First character type: ${(deckJson['characters'] as List).first.runtimeType}',
          );
        }

        // Process images and update the deckJson in place
        await ImageTransferHelper.deckFromJsonWithImages(deckJson);
        // deckJson is already modified by the helper, keep it as is
        lobbyData['deck'] = deckJson;
      }

      final lobby = Lobby.fromJson(lobbyData);
      return lobby;
    } catch (e, stackTrace) {
      print('Error processing lobby data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Send a game action
  void sendGameAction({
    required String action,
    Map<String, dynamic>? actionData,
  }) {
    if (_currentLobbyCode == null || _playerId == null) {
      throw Exception('Not in a lobby');
    }

    final data = {
      'type': action,
      'data': actionData ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    sendMessage(data);
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStateController.close();
  }
}
