# Guess Who? - Digital Board Game

A Flutter implementation of the classic "Guess Who?" board game with support for custom character decks.

## Features

- ✅ **Pass & Play Mode**: Two players share one device with curtain screens between turns
- ✅ **Custom Decks**: Create decks with custom photos and names
- ✅ **Network-Ready Architecture**: Designed to easily add online multiplayer later
- ✅ **Flexible Deck Sizes**: Support for rectangular grids (9, 12, 15, 16, 20, 25 characters, etc.)
- ✅ **Turn-Based Gameplay**: Ask questions or make guesses
- ✅ **Character Elimination**: Tap to eliminate/restore characters
- ✅ **Win Detection**: Automatic game end on correct guess

## Architecture

### Project Structure

```
lib/
├── data/
│   ├── models/           # Data classes with JSON serialization
│   │   ├── character.dart
│   │   ├── deck.dart
│   │   ├── character_state.dart
│   │   ├── player_board.dart
│   │   ├── game_state.dart
│   │   └── game_enums.dart
│   └── repositories/     # Data persistence layer
│       └── deck_repository.dart
├── presentation/
│   ├── game/
│   │   ├── cubit/        # Game logic (network-agnostic)
│   │   │   └── game_cubit.dart
│   │   ├── screens/
│   │   │   └── game_screen.dart
│   │   └── widgets/
│   │       ├── character_card.dart
│   │       └── curtain_screen.dart
│   └── menu/
│       └── menu_screen.dart
└── main.dart
```

### Key Design Principles

#### 1. **Network-Agnostic Game Logic**
The `GameCubit` handles all game state and logic without knowing if it's local or online play:
- Methods like `toggleCharacter()`, `makeGuess()`, `endTurn()` work the same regardless of mode
- Game state is fully serializable for network transmission
- Easy to add a "Transport Layer" later that syncs game state between devices

#### 2. **Separation of Concerns**
- **Models**: Pure data classes with Equatable for comparison
- **Repository**: Handles deck persistence (currently local, can add cloud sync)
- **Cubit**: Business logic and state management
- **UI**: Presentation only, delegates all logic to Cubit

#### 3. **Offline First**
- All data stored locally using `SharedPreferences`
- Game works without internet
- Future network features will sync with local state

### Game Flow

#### Setup Phase
1. User selects a deck from the menu
2. Game initializes with `GameState.initial()`
3. Transitions to character selection

#### Character Selection
1. Player 1 selects their secret character (curtain screen prevents Player 2 from seeing)
2. Player 2 selects their secret character
3. Game transitions to Playing phase

#### Playing Phase
Each turn:
1. **Curtain Screen**: Shows "Player X's Turn" with button to continue
2. **Player's Turn**:
   - Can ask questions (verbal) and eliminate characters by tapping
   - Can switch to "Guess Mode" and tap a character to guess
   - If guess is correct: Player wins!
   - If guess is wrong: Character eliminated, turn ends
   - Otherwise: Click "End Turn"
3. Return to Curtain Screen for next player

#### Game End
- Winner is displayed
- Option to return to menu

### Data Models

#### Character
```dart
{
  id: String,
  name: String,
  imagePath: String?  // Local file or asset path
}
```

#### Deck
```dart
{
  id: String,
  name: String,
  characters: List<Character>,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

#### PlayerBoard
```dart
{
  playerId: String,
  secretCharacterId: String?,  // The character this player is defending
  characterStates: List<CharacterState>  // Elimination states
}
```

#### GameState
```dart
{
  gameId: String,
  deck: Deck,
  mode: GameMode,  // passAndPlay or online
  phase: GamePhase,  // setup, player1Selection, player2Selection, playing, finished
  currentPlayer: int,  // 1 or 2
  currentAction: TurnAction?,  // asking or guessing
  player1Board: PlayerBoard,
  player2Board: PlayerBoard,
  winner: int?,
  result: GameResult?,
  createdAt: DateTime,
  finishedAt: DateTime?
}
```

## Getting Started

### Prerequisites
- Flutter SDK 3.2.0 or higher
- Dart 3.0.0 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Szostak21/Guess-who.git
cd Guess-who
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate JSON serialization code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## Usage

### Creating a Demo Deck
1. Launch the app
2. Tap "Create Demo Deck" to generate a test deck with 20 characters
3. Select the deck to start playing

### Playing the Game
1. Select a deck from the menu
2. Player 1 selects their secret character
3. Player 2 selects their secret character
4. Players take turns:
   - Ask questions verbally
   - Tap characters to eliminate them
   - Click "Guess" to enter guess mode
   - Tap a character to make your guess
   - Click "End Turn" when done

## Future Enhancements

### Phase 1 (Current Demo)
- [x] Pass & Play mode
- [x] Basic deck management
- [x] Turn-based gameplay
- [x] Character elimination
- [x] Guess mechanic

### Phase 2 (Next Steps)
- [ ] Deck Editor UI (camera/gallery integration)
- [ ] Game state persistence (save/resume)
- [ ] Custom deck validation (size requirements)
- [ ] Better character grid layouts
- [ ] Sound effects and animations

### Phase 3 (Online Mode)
- [ ] Network transport layer abstraction
- [ ] Wi-Fi Direct / Local Network multiplayer
- [ ] Online matchmaking
- [ ] Cloud deck storage
- [ ] In-game chat

## Technical Notes

### Why Cubit Instead of Bloc?
For this game, Cubit is simpler and sufficient:
- Game logic is straightforward (no complex event chains)
- State transitions are direct and immediate
- Events would add unnecessary boilerplate
- Easy to migrate to full Bloc if needed for network layer

### Network Readiness
The architecture supports adding online play with minimal changes:

**Current (Pass & Play):**
```dart
onTap: () => gameCubit.toggleCharacter(characterId)
```

**Future (Online):**
```dart
onTap: () => networkChannel.sendAction(
  ToggleCharacterAction(playerId, characterId)
)
// Server receives, validates, updates GameState, broadcasts to both clients
```

The `GameCubit` remains unchanged - it just receives state updates from the network layer instead of direct UI calls.

## License
See LICENSE file for details.

## Guess-who