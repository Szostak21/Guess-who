import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/lobby.dart';
import '../models/deck.dart';
import '../models/websocket_message.dart';
import 'image_transfer_helper.dart';

/// Peer-to-peer WebSocket server that runs on the host's phone
/// Allows direct device-to-device communication without cloud servers
class P2PWebSocketServer {
  HttpServer? _server;
  WebSocketChannel? _hostChannel;
  WebSocketChannel? _guestChannel;

  Lobby? _lobby;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<String> get status => _statusController.stream;

  bool get isRunning => _server != null;
  String? get lobbyCode => _lobby?.code;

  /// Start the WebSocket server on the host's phone
  Future<String> start({
    required String hostId,
    required String hostName,
    required Deck deck,
  }) async {
    if (_server != null) {
      print('Server already running, stopping it first');
      await stop();
    }

    try {
      // Create lobby
      _lobby = Lobby(
        code: _generateLobbyCode(),
        hostId: hostId,
        hostName: hostName,
        status: LobbyStatus.waiting,
        deck: deck,
        createdAt: DateTime.now(),
      );

      // Create WebSocket handler
      final handler = webSocketHandler((WebSocketChannel channel) {
        print('New WebSocket connection');
        print('Host channel is null: ${_hostChannel == null}');
        print('Guest channel is null: ${_guestChannel == null}');

        // First connection is the host (always)
        if (_hostChannel == null) {
          _hostChannel = channel;
          print('Assigned as HOST');
          _statusController.add('Host connected');
          _setupHostChannel();
        }
        // Second connection is the guest
        else if (_guestChannel == null) {
          _guestChannel = channel;
          print('Assigned as GUEST');
          _statusController.add('Guest connected');
          _setupGuestChannel();
        } else {
          // Reject additional connections
          print('REJECTING connection - lobby full');
          channel.sink.add(
            jsonEncode({
              'type': 'error',
              'message': 'Lobby is full',
            }),
          );
          channel.sink.close();
        }
      });

      // Start server on port 8080 with shared: true to allow hot restart
      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        8080,
        shared: true,
      );
      print('WebSocket server started on port ${_server!.port}');

      return _lobby!.code;
    } catch (e) {
      print('Failed to start server: $e');
      rethrow;
    }
  }

  void _setupHostChannel() {
    _hostChannel!.stream.listen(
      (message) {
        _handleMessage(message as String, isHost: true);
      },
      onDone: () {
        print('Host disconnected');
        _statusController.add('Host disconnected');
        stop();
      },
      onError: (error) {
        print('Host error: $error');
      },
    );

    // Send lobby created message to host
    _sendToHost({
      'type': MessageType.lobbyCreated.name,
      'data': _lobby!.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _setupGuestChannel() {
    _guestChannel!.stream.listen(
      (message) {
        _handleMessage(message as String, isHost: false);
      },
      onDone: () {
        print('Guest disconnected');
        _statusController.add('Guest disconnected');
        // Notify host that guest left
        _sendToHost({
          'type': MessageType.playerLeft.name,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
      onError: (error) {
        print('Guest error: $error');
      },
    );
  }

  void _handleMessage(String message, {required bool isHost}) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String?;

      print('Received message from ${isHost ? "host" : "guest"}: $type');

      switch (type) {
        case 'joinLobby':
          _handleJoinLobby(data);
          break;
        case 'startGame':
          print(
            'Server relaying startGame message from ${isHost ? "host" : "guest"}',
          );
          _relayToOther(data, isHost: isHost);
          break;
        case 'gameStateUpdate':
          _handleGameStateUpdate(data, isHost: isHost);
          break;
        case 'characterToggled':
          _relayToOther(data, isHost: isHost);
          break;
        case 'guessMade':
          _relayToOther(data, isHost: isHost);
          break;
        case 'turnEnded':
          _relayToOther(data, isHost: isHost);
          break;
        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void _handleJoinLobby(Map<String, dynamic> data) async {
    try {
      if (_lobby == null) {
        _sendToGuest({
          'type': MessageType.error.name,
          'error': 'Lobby not found',
          'timestamp': DateTime.now().toIso8601String(),
        });
        return;
      }

      final requestData = data['data'] as Map<String, dynamic>;
      final guestId = requestData['playerId'] as String;
      final guestName = requestData['playerName'] as String;

      // Update lobby with guest info
      _lobby = _lobby!.copyWith(
        guestId: guestId,
        guestName: guestName,
        status: LobbyStatus.ready,
      );

      // Convert deck with images to base64 for transfer
      final deckWithImages =
          await ImageTransferHelper.deckToJsonWithImages(_lobby!.deck);

      // Build lobby JSON manually to ensure proper structure
      final lobbyJson = {
        'code': _lobby!.code,
        'hostId': _lobby!.hostId,
        'guestId': _lobby!.guestId,
        'status': _lobby!.status.name,
        'deck': deckWithImages,
        'hostName': _lobby!.hostName,
        'guestName': _lobby!.guestName,
        'createdAt': _lobby!.createdAt.toIso8601String(),
      };

      // Send lobby info with deck to guest
      _sendToGuest({
        'type': MessageType.lobbyJoined.name,
        'data': lobbyJson,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Notify host that player joined
      _sendToHost({
        'type': MessageType.playerJoined.name,
        'data': {
          'playerId': guestId,
          'playerName': guestName,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });

      _statusController.add('Player joined: $guestName');
    } catch (e, stackTrace) {
      print('Error in _handleJoinLobby: $e');
      print('Stack trace: $stackTrace');
      _sendToGuest({
        'type': MessageType.error.name,
        'error': 'Failed to join lobby: $e',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void _handleGameStateUpdate(
    Map<String, dynamic> data, {
    required bool isHost,
  }) {
    // Store game state and relay to other player
    final stateData = data['data'] as Map<String, dynamic>?;
    if (stateData != null) {
      _relayToOther(data, isHost: isHost);
    }
  }

  void _relayToOther(Map<String, dynamic> data, {required bool isHost}) {
    if (isHost) {
      _sendToGuest(data);
    } else {
      _sendToHost(data);
    }
  }

  void _sendToHost(Map<String, dynamic> data) {
    if (_hostChannel != null) {
      _hostChannel!.sink.add(jsonEncode(data));
    }
  }

  void _sendToGuest(Map<String, dynamic> data) {
    if (_guestChannel != null) {
      _guestChannel!.sink.add(jsonEncode(data));
    }
  }

  String _generateLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(random >> (i * 4)) % chars.length])
        .join();
  }

  /// Stop the server and close all connections
  Future<void> stop() async {
    await _hostChannel?.sink.close();
    await _guestChannel?.sink.close();
    await _server?.close(force: true);

    _hostChannel = null;
    _guestChannel = null;
    _server = null;
    _lobby = null;

    _statusController.add('Server stopped');
  }

  void dispose() {
    stop();
    _messageController.close();
    _statusController.close();
  }
}
