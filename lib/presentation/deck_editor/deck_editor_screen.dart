import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../data/models/character.dart';
import '../../data/models/deck.dart';
import '../../data/repositories/deck_repository.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for creating and editing character decks
class DeckEditorScreen extends StatefulWidget {
  final Deck? existingDeck;

  const DeckEditorScreen({Key? key, this.existingDeck}) : super(key: key);

  @override
  State<DeckEditorScreen> createState() => _DeckEditorScreenState();
}

class _DeckEditorScreenState extends State<DeckEditorScreen> {
  late List<Character> _characters;
  late TextEditingController _deckNameController;
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxCharacters = 30;
  static const int _minCharacters = 6;

  @override
  void initState() {
    super.initState();
    _characters = widget.existingDeck?.characters.toList() ?? [];
    _deckNameController = TextEditingController(
      text: widget.existingDeck?.name ?? 'New Deck',
    );
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }

  /// Calculate optimal grid dimensions for portrait mode
  /// Ensures columns >= rows and as square as possible (cols - rows <= 1)
  (int rows, int cols) _calculateGridDimensions(int count) {
    if (count == 0) return (0, 0);

    // Find the most square-like dimensions where cols >= rows and cols - rows <= 1
    for (int rows = (count / 2).floor(); rows >= 1; rows--) {
      final cols = (count / rows).ceil();
      // Ensure cols >= rows and difference is at most 1
      if (cols >= rows && cols - rows <= 1 && rows * cols >= count) {
        return (rows, cols);
      }
    }

    // Fallback
    final sqrtVal = sqrt(count.toDouble()).floor();
    return (sqrtVal, (count / sqrtVal).ceil());
  }

  void _showAddCharacterDialog() async {
    final nameController = TextEditingController();
    String? imagePath;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Character'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Character Name',
                  hintText: 'Enter name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (image != null) {
                    setState(() {
                      imagePath = image.path;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: Text(
                  imagePath == null ? 'Add Photo (Optional)' : 'Photo Selected',
                ),
              ),
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    imagePath!.split('/').last,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      setState(() {
        _characters.add(Character(
          id: 'char_${DateTime.now().millisecondsSinceEpoch}',
          name: nameController.text.trim(),
          imagePath: imagePath,
        ));
      });
    }
  }

  void _removeCharacter(int index) {
    setState(() {
      _characters.removeAt(index);
    });
  }

  Future<void> _saveDeck() async {
    if (_characters.length < _minCharacters) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add at least $_minCharacters characters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_deckNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deck name cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final deck = Deck(
      id: widget.existingDeck?.id ??
          'deck_${DateTime.now().millisecondsSinceEpoch}',
      name: _deckNameController.text.trim(),
      characters: _characters,
      createdAt: widget.existingDeck?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await context.read<DeckRepository>().saveDeck(deck);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (rows, cols) = _calculateGridDimensions(_characters.length);
    final canAddMore = _characters.length < _maxCharacters;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _deckNameController,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: const InputDecoration(
            hintText: 'Deck Name',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton.icon(
            onPressed: _saveDeck,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info bar
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.deepPurple.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_characters.length}/$_maxCharacters characters',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _characters.length < _minCharacters
                        ? 'Min: $_minCharacters'
                        : '✓ Ready to save',
                    style: TextStyle(
                      color: _characters.length < _minCharacters
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Character grid
            Expanded(
              child: _characters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No characters yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add characters',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate card size that fits all items without scrolling
                        final availableHeight =
                            constraints.maxHeight - 16; // padding
                        final availableWidth = constraints.maxWidth - 16;

                        final cardWidth =
                            (availableWidth - (cols - 1) * 4) / cols;
                        final cardHeight = cardWidth / 0.7;
                        final totalHeight = rows * cardHeight + (rows - 1) * 4;

                        final aspectRatio = totalHeight <= availableHeight
                            ? 0.7
                            : (cardWidth /
                                ((availableHeight - (rows - 1) * 4) / rows));

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              childAspectRatio: aspectRatio,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: _characters.length,
                            itemBuilder: (context, index) {
                              final character = _characters[index];
                              return _CharacterEditorCard(
                                character: character,
                                onDelete: () => _removeCharacter(index),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),

            // Add button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canAddMore ? _showAddCharacterDialog : null,
                  icon: const Icon(Icons.add),
                  label: Text(
                    canAddMore
                        ? 'Add Character'
                        : 'Maximum $_maxCharacters reached',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.all(12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying characters in editor mode
class _CharacterEditorCard extends StatelessWidget {
  final Character character;
  final VoidCallback onDelete;

  const _CharacterEditorCard({
    required this.character,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                  child: character.imagePath != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: Image.network(
                            character.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  size: 48, color: Colors.grey);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 48, color: Colors.grey),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
