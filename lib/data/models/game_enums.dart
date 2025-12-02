/// Represents different phases of the game session
enum GamePhase {
  /// Initial state before character selection
  setup,

  /// Both players selecting their secret characters simultaneously
  characterSelection,

  /// Player 1 is selecting their secret character
  player1Selection,

  /// Player 2 is selecting their secret character
  player2Selection,

  /// Active gameplay (asking questions and eliminating)
  playing,

  /// Game has ended with a winner
  finished,
}

/// Represents different game modes
enum GameMode {
  /// Local pass-and-play mode
  passAndPlay,

  /// Online multiplayer (future implementation)
  online,
}

/// Represents the turn action type
enum TurnAction {
  /// Player is asking a question (and can eliminate characters)
  asking,

  /// Player is making a guess
  guessing,
}

/// Represents the game result
enum GameResult {
  player1Won,
  player2Won,
  draw, // In case of unexpected scenarios
}
