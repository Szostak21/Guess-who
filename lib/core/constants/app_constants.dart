/// Application-wide constants

class AppConstants {
  // Deck constraints
  static const int minDeckSize = 9;
  static const List<int> validDeckSizes = [9, 12, 15, 16, 20, 24, 25, 30];
  
  // Game settings
  static const String player1Id = 'player1';
  static const String player2Id = 'player2';
  
  // UI
  static const double characterCardAspectRatio = 0.75;
  static const double gridSpacing = 8.0;
  static const double defaultPadding = 16.0;
  
  // Storage keys
  static const String savedDecksKey = 'saved_decks';
  static const String savedGamesKey = 'saved_games';
  
  // Default values
  static const String defaultDeckId = 'default_deck';
  static const String defaultDeckName = 'Classic Characters';
  static const int defaultDeckCharacterCount = 20;
}

class AppStrings {
  // Game messages
  static const String gameTitle = 'Guess Who?';
  static const String passDevice = 'Pass the device to';
  static const String startTurn = 'START TURN';
  static const String endTurn = 'End Turn';
  static const String guess = 'Guess';
  static const String cancelGuess = 'Cancel Guess';
  
  // Warnings
  static const String curtainWarning = '⚠️ Make sure the other player isn\'t looking!';
  static const String confirmGuessTitle = 'Confirm Guess';
  
  // Menu
  static const String selectDeck = 'Select a deck to play';
  static const String noDeckFound = 'No decks found';
  static const String createFirstDeck = 'Create your first deck to start playing';
  static const String createDemoDeck = 'Create Demo Deck';
  static const String newDeck = 'New Deck';
  
  // Errors
  static const String errorPrefix = 'Error: ';
  
  // Coming soon
  static const String comingSoonTitle = 'Coming Soon';
  static String comingSoonMessage(String feature) =>
      '$feature will be available in the next update!';
}
