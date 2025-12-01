import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import '../../../data/models/character.dart';
import '../../../data/models/character_state.dart';

/// Widget to display a single character card in the grid
class CharacterCard extends StatefulWidget {
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
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start flipped if already eliminated
    if (widget.state.isEliminated) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CharacterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when elimination state changes
    if (oldWidget.state.isEliminated != widget.state.isEliminated) {
      if (widget.state.isEliminated) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEliminated = widget.state.isEliminated;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          // Calculate the angle for 3D rotation
          final angle = _flipAnimation.value;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle);

          // Determine if we're showing the back (eliminated) side
          final showBack = angle > math.pi / 2;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: showBack ? _buildEliminatedSide() : _buildActiveSide(),
          );
        },
      ),
    );
  }

  Widget _buildActiveSide() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isSelected ? Colors.green : Colors.grey.shade400,
          width: widget.isSelected ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          // Character image or placeholder
          Positioned.fill(
            child: widget.character.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.character.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
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
                widget.character.name,
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

          // Selection indicator
          if (widget.isSelectionMode && widget.isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.3),
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
    );
  }

  Widget _buildEliminatedSide() {
    // Mirror the eliminated side so text appears correctly
    return Transform(
      transform: Matrix4.rotationY(math.pi),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade800,
        ),
        child: Stack(
          children: [
            // Darker overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
            // Character name centered
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.character.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
