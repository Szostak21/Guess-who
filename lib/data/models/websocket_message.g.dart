// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebSocketMessage _$WebSocketMessageFromJson(Map<String, dynamic> json) =>
    WebSocketMessage(
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$WebSocketMessageToJson(WebSocketMessage instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'data': instance.data,
      'error': instance.error,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.createLobby: 'createLobby',
  MessageType.joinLobby: 'joinLobby',
  MessageType.lobbyCreated: 'lobbyCreated',
  MessageType.lobbyJoined: 'lobbyJoined',
  MessageType.playerJoined: 'playerJoined',
  MessageType.playerLeft: 'playerLeft',
  MessageType.startGame: 'startGame',
  MessageType.gameStateUpdate: 'gameStateUpdate',
  MessageType.characterToggled: 'characterToggled',
  MessageType.guessMade: 'guessMade',
  MessageType.turnEnded: 'turnEnded',
  MessageType.gameOver: 'gameOver',
  MessageType.ping: 'ping',
  MessageType.pong: 'pong',
  MessageType.error: 'error',
};

CreateLobbyRequest _$CreateLobbyRequestFromJson(Map<String, dynamic> json) =>
    CreateLobbyRequest(
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      deck: json['deck'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CreateLobbyRequestToJson(CreateLobbyRequest instance) =>
    <String, dynamic>{
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'deck': instance.deck,
    };

JoinLobbyRequest _$JoinLobbyRequestFromJson(Map<String, dynamic> json) =>
    JoinLobbyRequest(
      lobbyCode: json['lobbyCode'] as String,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
    );

Map<String, dynamic> _$JoinLobbyRequestToJson(JoinLobbyRequest instance) =>
    <String, dynamic>{
      'lobbyCode': instance.lobbyCode,
      'playerId': instance.playerId,
      'playerName': instance.playerName,
    };

GameActionMessage _$GameActionMessageFromJson(Map<String, dynamic> json) =>
    GameActionMessage(
      lobbyCode: json['lobbyCode'] as String,
      playerId: json['playerId'] as String,
      action: json['action'] as String,
      actionData: json['actionData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GameActionMessageToJson(GameActionMessage instance) =>
    <String, dynamic>{
      'lobbyCode': instance.lobbyCode,
      'playerId': instance.playerId,
      'action': instance.action,
      'actionData': instance.actionData,
    };
