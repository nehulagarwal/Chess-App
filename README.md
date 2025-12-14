# ♟️ Chess Arena

A feature-complete, rules-accurate Chess Engine built with **Flutter**.

\<div align="center"\>
\<img src="[https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter](https://www.google.com/search?q=https://img.shields.io/badge/Flutter-3.0%252B-02569B%3Flogo%3Dflutter)" alt="Flutter"\>
\<img src="[https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart](https://www.google.com/search?q=https://img.shields.io/badge/Dart-3.0%252B-0175C2%3Flogo%3Ddart)" alt="Dart"\>
\<img src="[https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green](https://www.google.com/search?q=https://img.shields.io/badge/Platform-iOS%2520%257C%2520Android-green)" alt="Platform"\>
\<img src="[https://img.shields.io/badge/License-MIT-yellow](https://www.google.com/search?q=https://img.shields.io/badge/License-MIT-yellow)" alt="License"\>
\</div\>

\<br /\>

## 📖 Overview

**Chess Arena** is a fully functional chess application designed with a focus on clean architecture, performance, and a modern dark-themed UI. Unlike basic prototypes, this engine enforces **all** standard chess rules, including complex edge cases like En Passant, Castling, and Stalemate detection.

## ✨ Key Features

### 🧠 Advanced Chess Logic

  * **Move Validation:** Only legal moves are highlighted and allowed.
  * **Castling:** Supports both Kingside (O-O) and Queenside (O-O-O) castling.
  * **En Passant:** Correctly handles the special pawn capture rule.
  * **Pawn Promotion:** Interactive dialog to promote pawns to Queen, Rook, Bishop, or Knight.
  * **Check & Checkmate Detection:** Real-time king safety analysis.
  * **Draw Detection:** Automatically detects **Stalemate** conditions.

### 🎮 Game State Management

  * **Undo/Redo System:** Full history tracking allows players to revert mistakes without breaking game state (castling rights, etc.).
  * **Move History:** Displays moves in standard **SAN (Standard Algebraic Notation)** format (e.g., `Nf3`, `exd5`, `O-O`).
  * **Deep Copy State:** Ensures robust history management by cloning board states rather than referencing them.

### 🎨 Modern UI/UX

  * **Dark Mode Aesthetic:** Elegant charcoal and glassmorphism design.
  * **Responsive Board:** Perfectly square aspect ratio on all devices.
  * **Player Panels:** Live display of current turn, captured pieces, and player status.
  * **Visual Aids:**
      * **Highlights:** Selected piece and valid move indicators (green dots).
      * **Alerts:** Visual red banner when a King is in Check.

## 📂 Project Structure

The project follows a component-based architecture for maintainability and scalability.

```text
lib/
├── components/
│   ├── piece.dart         # Chess Piece Model (Type, Color, Image)
│   ├── square.dart        # Individual Board Square UI
│   ├── player_panel.dart  # Player Info & Captured Pieces UI
│   └── dead_piece.dart    # (Optional) Widget for captured pieces
├── models/
│   └── game_snapshot.dart # State model for Undo/Redo history
├── helper/
│   └── helper_methods.dart # (Optional) Utility functions
└── game_board.dart        # Main Game Loop & Logic Controller
```

## 🚀 Getting Started

### Prerequisites

  * [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
  * An IDE (VS Code or Android Studio) with Flutter/Dart plugins.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/chess-arena.git
    cd chess-arena
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Add Assets:**
    Ensure you have your chess piece images in `lib/images/`.

      * Naming convention: `wking.png`, `bpawn.png`, etc.
      * Update `pubspec.yaml`:
        ```yaml
        flutter:
          assets:
            - lib/images/
        ```

4.  **Run the app:**

    ```bash
    flutter run
    ```

## 📸 Screenshots

| Game Board | Move Validation | Promotion Dialog |
|:---:|:---:|:---:|
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

## 🔮 Future Roadmap

  * [ ] **Sound Effects:** Add audio feedback for moves and captures.
  * [ ] **Chess Clock:** Implement a 5/10-minute timer per player.
  * [ ] **AI Opponent:** Integrate a simple Minimax algorithm or Stockfish API.
  * [ ] **Multiplayer:** Add Firebase/WebSockets for online play.

## 🤝 Contributing

Contributions are welcome\!

1.  Fork the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

-----

**Developed with ❤️ using Flutter.**
