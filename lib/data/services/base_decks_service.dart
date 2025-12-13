import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/deck.dart';
import '../models/character.dart';

/// Service for loading base decks bundled with the app
class BaseDecksService {
  static const String _baseDecksPath = 'assets/decks/base_decks.json';

  /// Load all base decks from assets
  Future<List<Deck>> loadBaseDecks() async {
    try {
      final jsonString = await rootBundle.loadString(_baseDecksPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final decksList = jsonData['decks'] as List<dynamic>;

      return decksList.map((deckJson) {
        final deckMap = deckJson as Map<String, dynamic>;
        final characters = (deckMap['characters'] as List<dynamic>)
            .map((charJson) => Character(
                  id: charJson['id'] as String,
                  name: charJson['name'] as String,
                  imagePath: charJson['imagePath'] as String?,
                ))
            .toList();

        return Deck(
          id: deckMap['id'] as String,
          name: deckMap['name'] as String,
          characters: characters,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isBaseDeck: true,
        );
      }).toList();
    } catch (e) {
      print('Error loading base decks: $e');
      return [];
    }
  }
}
