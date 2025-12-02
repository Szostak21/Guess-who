// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lobby.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lobby _$LobbyFromJson(Map<String, dynamic> json) => Lobby(
      code: json['code'] as String,
      hostId: json['hostId'] as String,
      guestId: json['guestId'] as String?,
      status: $enumDecode(_$LobbyStatusEnumMap, json['status']),
      deck: Deck.fromJson(json['deck'] as Map<String, dynamic>),
      hostName: json['hostName'] as String,
      guestName: json['guestName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LobbyToJson(Lobby instance) => <String, dynamic>{
      'code': instance.code,
      'hostId': instance.hostId,
      'guestId': instance.guestId,
      'status': _$LobbyStatusEnumMap[instance.status]!,
      'deck': instance.deck,
      'hostName': instance.hostName,
      'guestName': instance.guestName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LobbyStatusEnumMap = {
  LobbyStatus.waiting: 'waiting',
  LobbyStatus.ready: 'ready',
  LobbyStatus.playing: 'playing',
  LobbyStatus.finished: 'finished',
};
