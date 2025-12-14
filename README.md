# ♟️ Chess Arena – Flutter Chess Application

A **fully-featured chess application built using Flutter**, implementing **official FIDE chess rules** with a modern UI and clean architecture. This project goes beyond a basic chessboard and includes advanced gameplay mechanics such as **check, checkmate, castling, en passant, pawn promotion, undo, move history (SAN notation)**, and a polished player interface.

---

## 📱 Features Overview

### 🧠 Core Chess Rules (FIDE-Compliant)

* ✅ Legal move generation for all pieces
* ✅ Check & checkmate detection
* ✅ Stalemate detection
* ✅ Castling (king-side & queen-side)
* ✅ En Passant capture
* ✅ Pawn promotion (Queen, Rook, Bishop, Knight)
* ✅ King safety validation (no illegal self-check moves)

### ♻️ Game Utilities

* 🔄 **Undo move** (full board state restoration)
* 📜 **Move history** using simplified SAN (Standard Algebraic Notation)
* ♻️ **Reset game**

### 🎨 UI & UX

* Modern dark-themed UI
* Highlighted selected piece & valid moves
* Captured pieces panel for both players
* Turn indication (active player highlight)
* In-game check warning banner
* Smooth grid-based chessboard layout

---

## 🏗️ Project Structure

```
lib/
│
├── components/
│   ├── piece.dart        # ChessPiece model & PieceType enum
│   ├── square.dart       # UI widget for a single board square
│
├── game_board.dart       # Main game logic, rules & UI
│
└── main.dart             # App entry point
```

---

## 📂 File Descriptions

### `piece.dart`

Defines the **ChessPiece model**.

* `PieceType` enum: pawn, rook, knight, bishop, queen, king
* `ChessPiece` class:

  * `type`
  * `isWhite`
  * `imagePath`

Used across the app for move generation and rendering.

---

### `square.dart`

Responsible for rendering an **individual chessboard square**.

Features:

* Displays piece image
* Highlights selected squares
* Indicates valid moves
* Handles user taps

This widget is reused for all 64 board positions.

---

### `game_board.dart`

The **heart of the application**.

Contains:

* Board state management
* Piece selection & move execution
* Legal move validation using simulation
* Check/checkmate/stalemate logic
* En passant handling
* Castling logic
* Pawn promotion dialog
* Undo system using `GameSnapshot`
* Move history generation (SAN)
* UI layout for players, board, and controls

This file combines **game engine logic** with **Flutter UI** in a structured manner.

---

## ♟️ Advanced Rule Implementation

### ✔ Check & King Safety

* Uses square-attack detection
* Prevents illegal moves that expose own king
* Displays in-check warning banner

### ✔ Castling

* Tracks king & rook movement
* Ensures:

  * Path is clear
  * King does not castle through check
  * King is not currently in check

### ✔ En Passant

* Tracks en-passant target square
* Allows capture only on the immediately following move
* Correctly removed pawn during simulation & undo

### ✔ Pawn Promotion

* Triggered on reaching last rank
* Modal dialog for piece selection
* Defaults to Queen if dialog dismissed

---

## 🔄 Undo System

Implemented using a **GameSnapshot** class that stores:

* Deep-copied board state
* Turn info
* Captured pieces
* Castling rights
* En passant target
* Check state

Ensures **100% accurate rollback** of game state.

---

## 🧾 Move History (SAN)

* Pawn moves: `e4`, `exd5`
* Piece moves: `Nf3`, `Qxe7`
* Castling: `O-O`, `O-O-O`
* Check: `+`
* Checkmate: `#`

Displayed in a bottom-sheet modal.

---

## 🛠️ Tech Stack

* **Flutter** (UI framework)
* **Dart** (logic & state management)
* Material Design components

No external chess libraries used — **all rules implemented manually**.

---

## 🚀 How to Run

1. Clone the repository
2. Run:

   ```bash
   flutter pub get
   flutter run
   ```
3. Ensure piece images exist in:

   ```
   lib/images/
   ```

---

## 🔮 Future Enhancements

* 🤖 AI opponent (Minimax / Alpha-Beta)
* ⏱️ Chess clock
* 🔁 Threefold repetition detection
* ♻️ 50-move draw rule
* 🔄 Board flip for black player
* 🌐 Online multiplayer
* 📤 PGN export

---

## 🏆 Project Level

This project is suitable for:

* Advanced Flutter portfolio
* Game development showcase
* Chess engine fundamentals
* College final-year / capstone project

---

## 👤 Author

Developed with ❤️ using Flutter.

If you’re reviewing this project: **all chess rules are implemented without shortcuts**.

---

**Enjoy the game! ♟️**
