// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerBoard _$PlayerBoardFromJson(Map<String, dynamic> json) => PlayerBoard(
      playerId: json['playerId'] as String,
      secretCharacterId: json['secretCharacterId'] as String?,
      characterStates: (json['characterStates'] as List<dynamic>)
          .map((e) => CharacterState.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlayerBoardToJson(PlayerBoard instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'secretCharacterId': instance.secretCharacterId,
      'characterStates': instance.characterStates,
    };
