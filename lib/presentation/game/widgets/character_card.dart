import 'package:flutter/material.dart';
import '../../../data/models/character.dart';
import '../../../data/models/character_state.dart';

/// Widget to display a single character card in the grid
class CharacterCard extends StatelessWidget {
  final Character character;
  final CharacterState state;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;

  const CharacterCard({
    Key? key,
    required this.character,
    required this.state,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEliminated = state.isEliminated;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Colors.green
                : isEliminated
                    ? Colors.red.shade300
                    : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isEliminated
              ? Colors.grey.shade300
              : Colors.white,
        ),
        child: Stack(
          children: [
            // Character image or placeholder
            Center(
              child: character.imagePath != null
                  ? Image.asset(
                      character.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
            
            // Character name
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.black54,
                child: Text(
                  character.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Eliminated overlay
            if (isEliminated)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
              ),
            
            // Selection indicator
            if (isSelectionMode && isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
