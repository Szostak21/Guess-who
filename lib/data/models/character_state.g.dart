// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterState _$CharacterStateFromJson(Map<String, dynamic> json) =>
    CharacterState(
      characterId: json['characterId'] as String,
      isEliminated: json['isEliminated'] as bool,
    );

Map<String, dynamic> _$CharacterStateToJson(CharacterState instance) =>
    <String, dynamic>{
      'characterId': instance.characterId,
      'isEliminated': instance.isEliminated,
    };
