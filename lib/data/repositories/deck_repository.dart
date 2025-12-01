import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';

/// Repository for managing deck persistence (local storage)
/// Future: Can be extended to support cloud sync
class DeckRepository {
  static const String _decksKey = 'saved_decks';
  final SharedPreferences _prefs;

  DeckRepository(this._prefs);

  /// Get all saved decks
  Future<List<Deck>> getAllDecks() async {
    final decksJson = _prefs.getStringList(_decksKey) ?? [];
    return decksJson
        .map((jsonStr) => Deck.fromJson(json.decode(jsonStr)))
        .toList();
  }

  /// Get a specific deck by ID
  Future<Deck?> getDeckById(String id) async {
    final decks = await getAllDecks();
    try {
      return decks.firstWhere((deck) => deck.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save a new deck or update existing one
  Future<void> saveDeck(Deck deck) async {
    final decks = await getAllDecks();
    
    // Remove existing deck with same ID if it exists
    decks.removeWhere((d) => d.id == deck.id);
    
    // Add the new/updated deck
    decks.add(deck);
    
    // Save to preferences
    final decksJson = decks.map((d) => json.encode(d.toJson())).toList();
    await _prefs.setStringList(_decksKey, decksJson);
  }

  /// Delete a deck
  Future<void> deleteDeck(String id) async {
    final decks = await getAllDecks();
    decks.removeWhere((deck) => deck.id == id);
    
    final decksJson = decks.map((d) => json.encode(d.toJson())).toList();
    await _prefs.setStringList(_decksKey, decksJson);
  }

  /// Create a default demo deck for testing
  Future<Deck> createDefaultDeck() async {
    final deck = Deck(
      id: 'default_deck',
      name: 'Classic Characters',
      characters: List.generate(
        20,
        (i) => Character(
          id: 'char_$i',
          name: 'Character ${i + 1}',
          imagePath: null,
        ),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await saveDeck(deck);
    return deck;
  }
}
