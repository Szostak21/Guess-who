part of 'lobby_cubit.dart';

/// Status of lobby operations
enum LobbyStateStatus {
  initial,
  creating,
  joining,
  waiting,
  ready,
  playing,
  error,
}

/// State for lobby management
class LobbyState extends Equatable {
  final Lobby? lobby;
  final String? playerId;
  final bool isHost;
  final LobbyStateStatus status;
  final String? errorMessage;
  final String? serverIp; // Host's IP address for guests to connect to

  const LobbyState({
    this.lobby,
    this.playerId,
    this.isHost = false,
    this.status = LobbyStateStatus.initial,
    this.errorMessage,
    this.serverIp,
  });

  LobbyState copyWith({
    Lobby? lobby,
    String? playerId,
    bool? isHost,
    LobbyStateStatus? status,
    String? errorMessage,
    String? serverIp,
  }) {
    return LobbyState(
      lobby: lobby ?? this.lobby,
      playerId: playerId ?? this.playerId,
      isHost: isHost ?? this.isHost,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      serverIp: serverIp ?? this.serverIp,
    );
  }

  @override
  List<Object?> get props => [
        lobby,
        playerId,
        isHost,
        status,
        errorMessage,
        serverIp,
      ];
}
