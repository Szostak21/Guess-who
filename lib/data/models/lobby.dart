import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'deck.dart';

part 'lobby.g.dart';

/// Status of a game lobby
enum LobbyStatus {
  waiting, // Waiting for second player
  ready, // Both players connected
  playing, // Game in progress
  finished, // Game completed
}

/// Represents a game lobby for online multiplayer
@JsonSerializable()
class Lobby extends Equatable {
  /// Unique lobby code for joining
  final String code;

  /// Host player's ID
  final String hostId;

  /// Guest player's ID (null if waiting)
  final String? guestId;

  /// Current lobby status
  final LobbyStatus status;

  /// The deck being used for this game
  final Deck deck;

  /// Host player's name
  final String hostName;

  /// Guest player's name (null if waiting)
  final String? guestName;

  /// Timestamp when lobby was created
  final DateTime createdAt;

  const Lobby({
    required this.code,
    required this.hostId,
    this.guestId,
    required this.status,
    required this.deck,
    required this.hostName,
    this.guestName,
    required this.createdAt,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) => _$LobbyFromJson(json);
  Map<String, dynamic> toJson() => _$LobbyToJson(this);

  Lobby copyWith({
    String? code,
    String? hostId,
    String? guestId,
    LobbyStatus? status,
    Deck? deck,
    String? hostName,
    String? guestName,
    DateTime? createdAt,
  }) {
    return Lobby(
      code: code ?? this.code,
      hostId: hostId ?? this.hostId,
      guestId: guestId ?? this.guestId,
      status: status ?? this.status,
      deck: deck ?? this.deck,
      hostName: hostName ?? this.hostName,
      guestName: guestName ?? this.guestName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        code,
        hostId,
        guestId,
        status,
        deck,
        hostName,
        guestName,
        createdAt,
      ];
}
