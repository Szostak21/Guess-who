# Guess Who? — But with your friends!

**Guess Who?** is an online implementation of classic board game but with characters of your choice! Use photos of friends, family, classmates or coworkers to build decks and play instantly. The Deck Editor lets you import from the gallery or take quick photos with your camera so each game is personal and recognisable.

The app includes built‑in base decks, a full Deck Editor (camera + gallery), Pass & Play, and online play support.

## ✨ Highlights

Below are the key features — descriptions first, followed by a compact inline gallery.

### Play with your photos

Create personal decks quickly from the camera or gallery. Use 6–30 photos per deck to make games personal and memorable.

### Pass & Play — Turn-based gameplay

Real‑time, turn‑based gameplay with curtain screens that keep selections private when players share one device.

### Online mode — Play over Wi‑Fi

Play with a friend on the same Wi‑Fi network. Online supports simultaneous character selection and live state sync.


<div style="display:flex;gap:12px;align-items:center;justify-content:space-between;">
   <img src="docs/media/add_character_demo.jpg" alt="Add character" style="width:32%;height:auto;;border-radius:6px;" />
   <img src="docs/media/game_demo.jpg" alt="Game screen" style="width:32%;height:auto;;border-radius:6px;" />
   <img src="docs/media/multiplayer_demo.jpg" alt="Online mode" style="width:32%;height:auto;;border-radius:6px;" />
</div>

## ❤️ Why you'll love it

- Family game nights become hilarious when you use real photos
- Great for parties, meetups, or gossiping about friends
- Quick setup: snap or pick 6–30 photos and start playing


## 🧠 How it works

1. Deck selection
   - Pick a base deck or create a custom deck using the Deck Editor.

2. Character selection
   - Pass & Play: players choose their secret character in sequence behind curtain screens.
   - Online: both players pick simultaneously; the game begins once both have selected.

3. Playing
   - On your turn ask yes/no questions verbally, eliminate characters by tapping, or toggle Guess mode to make a formal guess.
   - Correct guess wins the game. Incorrect guess eliminates the character and ends your turn.

## 🛠 Tech stack

- Language: Dart + Flutter
- State: `flutter_bloc` (Cubit) for game logic
- Persistence: `shared_preferences` (user decks)
- Image handling: `image_picker` (camera/gallery) and `Image.asset`/`Image.file`
- Build & tooling: Flutter SDK, `build_runner` + `json_serializable`

## ▶️ Quick start

Prereqs: Flutter SDK and an emulator or device.

```bash
git clone https://github.com/Szostak21/Guess-who.git
cd Guess-who
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d <device-id>
```

If you add or change assets under `assets/` run:

```bash
flutter clean
flutter pub get
```

## 📁 Project layout

```
lib/
├─ data/
│  ├─ models/           # Character, Deck, GameState, serialization
│  ├─ repositories/     # DeckRepository
│  └─ services/         # BaseDecksService, WebSocket helpers
├─ presentation/
│  ├─ menu/             # `menu_screen.dart` (deck list)
│  ├─ deck_editor/      # Create/edit decks with camera/gallery
│  └─ game/             # UI, cubit, and widgets (game_screen.dart)
└─ main.dart

assets/
├─ decks/               # `base_decks.json` + base deck folders (clash_royale/, animals/)
└─ images/              # UI images
```

## 📜 License

MIT — see [LICENSE](LICENSE)

---
