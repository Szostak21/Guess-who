import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'websocket_message.g.dart';

/// Types of WebSocket messages
enum MessageType {
  // Lobby operations
  createLobby,
  joinLobby,
  lobbyCreated,
  lobbyJoined,
  playerJoined,
  playerLeft,

  // Game operations
  gameStateUpdate,
  characterToggled,
  guessMade,
  turnEnded,
  gameOver,

  // Connection
  ping,
  pong,
  error,
}

/// WebSocket message wrapper
@JsonSerializable()
class WebSocketMessage extends Equatable {
  final MessageType type;
  final Map<String, dynamic>? data;
  final String? error;
  final DateTime timestamp;

  const WebSocketMessage({
    required this.type,
    this.data,
    this.error,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketMessageFromJson(json);

  Map<String, dynamic> toJson() => _$WebSocketMessageToJson(this);

  @override
  List<Object?> get props => [type, data, error, timestamp];
}

/// Request to create a new lobby
@JsonSerializable()
class CreateLobbyRequest extends Equatable {
  final String hostId;
  final String hostName;
  final Map<String, dynamic> deck;

  const CreateLobbyRequest({
    required this.hostId,
    required this.hostName,
    required this.deck,
  });

  factory CreateLobbyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLobbyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateLobbyRequestToJson(this);

  @override
  List<Object?> get props => [hostId, hostName, deck];
}

/// Request to join an existing lobby
@JsonSerializable()
class JoinLobbyRequest extends Equatable {
  final String lobbyCode;
  final String playerId;
  final String playerName;

  const JoinLobbyRequest({
    required this.lobbyCode,
    required this.playerId,
    required this.playerName,
  });

  factory JoinLobbyRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinLobbyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JoinLobbyRequestToJson(this);

  @override
  List<Object?> get props => [lobbyCode, playerId, playerName];
}

/// Game action message
@JsonSerializable()
class GameActionMessage extends Equatable {
  final String lobbyCode;
  final String playerId;
  final String action; // 'toggleCharacter', 'guess', 'endTurn'
  final Map<String, dynamic>? actionData;

  const GameActionMessage({
    required this.lobbyCode,
    required this.playerId,
    required this.action,
    this.actionData,
  });

  factory GameActionMessage.fromJson(Map<String, dynamic> json) =>
      _$GameActionMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GameActionMessageToJson(this);

  @override
  List<Object?> get props => [lobbyCode, playerId, action, actionData];
}
