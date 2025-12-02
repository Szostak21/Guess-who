// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
      gameId: json['gameId'] as String,
      deck: Deck.fromJson(json['deck'] as Map<String, dynamic>),
      mode: $enumDecode(_$GameModeEnumMap, json['mode']),
      phase: $enumDecode(_$GamePhaseEnumMap, json['phase']),
      currentPlayer: (json['currentPlayer'] as num).toInt(),
      currentAction:
          $enumDecodeNullable(_$TurnActionEnumMap, json['currentAction']),
      hasFlippedThisTurn: json['hasFlippedThisTurn'] as bool? ?? false,
      flippedThisTurn: (json['flippedThisTurn'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      player1Board:
          PlayerBoard.fromJson(json['player1Board'] as Map<String, dynamic>),
      player2Board:
          PlayerBoard.fromJson(json['player2Board'] as Map<String, dynamic>),
      winner: (json['winner'] as num?)?.toInt(),
      result: $enumDecodeNullable(_$GameResultEnumMap, json['result']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
    );

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'gameId': instance.gameId,
      'deck': instance.deck,
      'mode': _$GameModeEnumMap[instance.mode]!,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'currentPlayer': instance.currentPlayer,
      'currentAction': _$TurnActionEnumMap[instance.currentAction],
      'hasFlippedThisTurn': instance.hasFlippedThisTurn,
      'flippedThisTurn': instance.flippedThisTurn.toList(),
      'player1Board': instance.player1Board,
      'player2Board': instance.player2Board,
      'winner': instance.winner,
      'result': _$GameResultEnumMap[instance.result],
      'createdAt': instance.createdAt.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
    };

const _$GameModeEnumMap = {
  GameMode.passAndPlay: 'passAndPlay',
  GameMode.online: 'online',
};

const _$GamePhaseEnumMap = {
  GamePhase.setup: 'setup',
  GamePhase.characterSelection: 'characterSelection',
  GamePhase.player1Selection: 'player1Selection',
  GamePhase.player2Selection: 'player2Selection',
  GamePhase.playing: 'playing',
  GamePhase.finished: 'finished',
};

const _$TurnActionEnumMap = {
  TurnAction.asking: 'asking',
  TurnAction.guessing: 'guessing',
};

const _$GameResultEnumMap = {
  GameResult.player1Won: 'player1Won',
  GameResult.player2Won: 'player2Won',
  GameResult.draw: 'draw',
};
