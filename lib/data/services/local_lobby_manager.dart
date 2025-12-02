import 'dart:async';
import 'dart:math';
import '../models/lobby.dart';
import '../models/deck.dart';

/// Simple in-memory lobby manager for local/peer-to-peer play
///
/// In production, this would be replaced with a real backend server
/// For now, this allows local network play via WiFi
class LocalLobbyManager {
  static final LocalLobbyManager _instance = LocalLobbyManager._internal();
  factory LocalLobbyManager() => _instance;
  LocalLobbyManager._internal();

  final Map<String, Lobby> _lobbies = {};
  final _lobbyUpdateController = StreamController<Lobby>.broadcast();

  Stream<Lobby> get lobbyUpdates => _lobbyUpdateController.stream;

  /// Generate a random 6-character lobby code
  String _generateLobbyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new lobby
  Lobby createLobby({
    required String hostId,
    required String hostName,
    required Deck deck,
  }) {
    final code = _generateLobbyCode();

    final lobby = Lobby(
      code: code,
      hostId: hostId,
      hostName: hostName,
      status: LobbyStatus.waiting,
      deck: deck,
      createdAt: DateTime.now(),
    );

    _lobbies[code] = lobby;
    _lobbyUpdateController.add(lobby);

    return lobby;
  }

  /// Join an existing lobby
  Lobby? joinLobby({
    required String lobbyCode,
    required String playerId,
    required String playerName,
  }) {
    final lobby = _lobbies[lobbyCode];

    if (lobby == null) {
      return null; // Lobby not found
    }

    if (lobby.guestId != null) {
      return null; // Lobby already full
    }

    final updatedLobby = lobby.copyWith(
      guestId: playerId,
      guestName: playerName,
      status: LobbyStatus.ready,
    );

    _lobbies[lobbyCode] = updatedLobby;
    _lobbyUpdateController.add(updatedLobby);

    return updatedLobby;
  }

  /// Get lobby by code
  Lobby? getLobby(String code) {
    return _lobbies[code];
  }

  /// Update lobby status
  void updateLobbyStatus(String code, LobbyStatus status) {
    final lobby = _lobbies[code];
    if (lobby != null) {
      final updated = lobby.copyWith(status: status);
      _lobbies[code] = updated;
      _lobbyUpdateController.add(updated);
    }
  }

  /// Remove a lobby
  void removeLobby(String code) {
    _lobbies.remove(code);
  }

  /// Clean up old lobbies (older than 1 hour)
  void cleanupOldLobbies() {
    final now = DateTime.now();
    _lobbies.removeWhere((code, lobby) {
      final age = now.difference(lobby.createdAt);
      return age.inHours >= 1;
    });
  }

  void dispose() {
    _lobbyUpdateController.close();
    _lobbies.clear();
  }
}
