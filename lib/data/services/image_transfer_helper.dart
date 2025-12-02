import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/deck.dart';

/// Helper for transferring images via WebSocket
class ImageTransferHelper {
  /// Convert deck with images to JSON with base64-encoded images
  static Future<Map<String, dynamic>> deckToJsonWithImages(Deck deck) async {
    final deckJson = deck.toJson();
    final charactersWithImages = <Map<String, dynamic>>[];

    for (final character in deck.characters) {
      final characterJson = character.toJson();

      if (character.imagePath != null) {
        try {
          final file = File(character.imagePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final base64Image = base64Encode(bytes);
            characterJson['imageData'] = base64Image;
            // Remove local path as it's not valid on guest device
            characterJson.remove('imagePath');
          }
        } catch (e) {
          print('Error encoding image for ${character.name}: $e');
        }
      }

      charactersWithImages.add(characterJson);
    }

    deckJson['characters'] = charactersWithImages;
    return deckJson;
  }

  /// Convert JSON with base64 images to deck with local image files
  /// Modifies the deckJson in place
  static Future<void> deckFromJsonWithImages(Map<String, dynamic> json) async {
    final charactersJson = json['characters'] as List;
    final processedCharacters = <Map<String, dynamic>>[];

    for (final characterJson in charactersJson) {
      final characterMap =
          Map<String, dynamic>.from(characterJson as Map<String, dynamic>);
      final imageData = characterMap['imageData'] as String?;

      if (imageData != null) {
        try {
          // Decode base64 to bytes
          final bytes = base64Decode(imageData);

          // Save to local file
          final appDir = await getApplicationDocumentsDirectory();
          final characterId = characterMap['id'] as String;
          final fileName =
              'online_${characterId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final file = File('${appDir.path}/$fileName');
          await file.writeAsBytes(bytes);

          // Update character JSON with local path
          characterMap['imagePath'] = file.path;
          characterMap.remove('imageData');
        } catch (e) {
          print('Error decoding image: $e');
        }
      }

      processedCharacters.add(characterMap);
    }

    // Update json with processed character maps in place
    json['characters'] = processedCharacters;
  }
}
