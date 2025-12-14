import 'package:flutter/material.dart';
import 'components/piece.dart';
import 'components/square.dart';
import 'components/player_panel.dart';
import 'models/game_snapshot.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // --- STATE VARIABLES ---
  late List<List<ChessPiece?>> board;

  // History & Undo
  List<GameSnapshot> undoStack = [];
  List<String> moveHistorySAN = [];

  // Selection
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];

  // Captures
  List<ChessPiece> whiteDeadPieces = [];
  List<ChessPiece> blackDeadPieces = [];

  // Turn & Check
  bool isWhiteTurn = true;
  List<int> whiteKingPos = [7, 4];
  List<int> blackKingPos = [0, 4];
  bool isInCheck = false;

  // Castling Rights
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  List<bool> whiteRookMoved = [false, false];
  List<bool> blackRookMoved = [false, false];

  // En Passant Target [row, col]
  List<int>? enPassantTarget;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // ---------------------------------------------------------------------------
  // 1. INITIALIZATION & UTILS
  // ---------------------------------------------------------------------------
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(8, (index) => null),
    );

    // Initialize Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: PieceType.pawn,
        isWhite: false,
        imagePath: 'lib/images/bpawn.png',
      );
      newBoard[6][i] = ChessPiece(
        type: PieceType.pawn,
        isWhite: true,
        imagePath: 'lib/images/wpawn.png',
      );
    }
    // Initialize Other Pieces
    _placePieces(newBoard, 0, false); // Black
    _placePieces(newBoard, 7, true); // White

    board = newBoard;
  }

  void _placePieces(List<List<ChessPiece?>> b, int row, bool isWhite) {
    String p = isWhite ? 'w' : 'b';
    b[row][0] = ChessPiece(
      type: PieceType.rook,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}rook.png',
    );
    b[row][1] = ChessPiece(
      type: PieceType.knight,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}knight.png',
    );
    b[row][2] = ChessPiece(
      type: PieceType.bishop,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}bishop.png',
    );
    b[row][3] = ChessPiece(
      type: PieceType.queen,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}queen.png',
    );
    b[row][4] = ChessPiece(
      type: PieceType.king,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}king.png',
    );
    b[row][5] = ChessPiece(
      type: PieceType.bishop,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}bishop.png',
    );
    b[row][6] = ChessPiece(
      type: PieceType.knight,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}knight.png',
    );
    b[row][7] = ChessPiece(
      type: PieceType.rook,
      isWhite: isWhite,
      imagePath: 'lib/images/${p}rook.png',
    );
  }

  void resetGame() {
    setState(() {
      _initializeBoard();
      isInCheck = false;
      isWhiteTurn = true;
      whiteDeadPieces.clear();
      blackDeadPieces.clear();
      whiteKingPos = [7, 4];
      blackKingPos = [0, 4];
      whiteKingMoved = false;
      blackKingMoved = false;
      whiteRookMoved = [false, false];
      blackRookMoved = [false, false];
      enPassantTarget = null;
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      undoStack.clear();
      moveHistorySAN.clear();
    });
  }

  // Deep Copy Helper
  ChessPiece _clonePiece(ChessPiece piece) {
    return ChessPiece(
      type: piece.type,
      isWhite: piece.isWhite,
      imagePath: piece.imagePath,
    );
  }

  List<List<ChessPiece?>> _copyBoard(List<List<ChessPiece?>> source) {
    return List.generate(
      8,
      (r) => List.generate(
        8,
        (c) => source[r][c] != null ? _clonePiece(source[r][c]!) : null,
      ),
    );
  }

  void saveState() {
    undoStack.add(
      GameSnapshot(
        board: _copyBoard(board),
        isWhiteTurn: isWhiteTurn,
        whiteDeadPieces: List.from(whiteDeadPieces),
        blackDeadPieces: List.from(blackDeadPieces),
        whiteKingPos: List.from(whiteKingPos),
        blackKingPos: List.from(blackKingPos),
        whiteKingMoved: whiteKingMoved,
        blackKingMoved: blackKingMoved,
        whiteRookMoved: List.from(whiteRookMoved),
        blackRookMoved: List.from(blackRookMoved),
        isInCheck: isInCheck,
        enPassantTarget: enPassantTarget == null
            ? null
            : List.from(enPassantTarget!),
        lastMoveDescription: moveHistorySAN.isEmpty ? "" : moveHistorySAN.last,
      ),
    );
  }

  void undoMove() {
    if (undoStack.isEmpty) return;
    GameSnapshot previous = undoStack.removeLast();
    setState(() {
      board = previous.board;
      isWhiteTurn = previous.isWhiteTurn;
      whiteDeadPieces = previous.whiteDeadPieces;
      blackDeadPieces = previous.blackDeadPieces;
      whiteKingPos = previous.whiteKingPos;
      blackKingPos = previous.blackKingPos;
      whiteKingMoved = previous.whiteKingMoved;
      blackKingMoved = previous.blackKingMoved;
      whiteRookMoved = previous.whiteRookMoved;
      blackRookMoved = previous.blackRookMoved;
      isInCheck = previous.isInCheck;
      enPassantTarget = previous.enPassantTarget;
      if (moveHistorySAN.isNotEmpty) moveHistorySAN.removeLast();

      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
  }

  // ---------------------------------------------------------------------------
  // 2. MOVE LOGIC
  // ---------------------------------------------------------------------------
  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((move) => move[0] == row && move[1] == col)) {
        movePiece(row, col);
        return;
      }
      validMoves = calculateRealValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
        true,
      );
    });
  }

  Future<void> movePiece(int newRow, int newCol) async {
    saveState();
    String notation = _getNotation(
      selectedPiece!,
      selectedRow,
      selectedCol,
      newRow,
      newCol,
      board[newRow][newCol],
    );

    // En Passant Capture
    if (selectedPiece!.type == PieceType.pawn &&
        enPassantTarget != null &&
        newRow == enPassantTarget![0] &&
        newCol == enPassantTarget![1]) {
      int captureRow = selectedPiece!.isWhite ? newRow + 1 : newRow - 1;
      var capturedPawn = board[captureRow][newCol]!;
      if (capturedPawn.isWhite)
        whiteDeadPieces.add(capturedPawn);
      else
        blackDeadPieces.add(capturedPawn);
      board[captureRow][newCol] = null;
      notation = "${notation[0]}x${notation.substring(2)}";
    }

    // Standard Capture
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol]!;
      if (capturedPiece.isWhite)
        whiteDeadPieces.add(capturedPiece);
      else
        blackDeadPieces.add(capturedPiece);
    }

    // Update Castling Flags
    if (selectedPiece!.type == PieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingMoved = true;
        whiteKingPos = [newRow, newCol];
      } else {
        blackKingMoved = true;
        blackKingPos = [newRow, newCol];
      }
    }
    if (selectedPiece!.type == PieceType.rook) {
      if (selectedPiece!.isWhite) {
        if (selectedCol == 0) whiteRookMoved[0] = true;
        if (selectedCol == 7) whiteRookMoved[1] = true;
      } else {
        if (selectedCol == 0) blackRookMoved[0] = true;
        if (selectedCol == 7) blackRookMoved[1] = true;
      }
    }

    // Execute Move
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Castling Move Rook
    if (selectedPiece!.type == PieceType.king &&
        (newCol - selectedCol).abs() == 2) {
      notation = (newCol > selectedCol) ? "O-O" : "O-O-O";
      if (newCol > selectedCol) {
        var rook = board[newRow][7];
        board[newRow][5] = rook;
        board[newRow][7] = null;
      } else {
        var rook = board[newRow][0];
        board[newRow][3] = rook;
        board[newRow][0] = null;
      }
    }

    // Pawn Promotion
    if (selectedPiece!.type == PieceType.pawn && (newRow == 0 || newRow == 7)) {
      PieceType? promotedType = await _showPromotionDialog(
        selectedPiece!.isWhite,
      );
      promotedType ??= PieceType.queen;
      String colorPrefix = selectedPiece!.isWhite ? 'w' : 'b';
      board[newRow][newCol] = ChessPiece(
        type: promotedType,
        isWhite: selectedPiece!.isWhite,
        imagePath: 'lib/images/$colorPrefix${promotedType.name}.png',
      );
      notation += "=${_getPieceCode(promotedType)}";
    }

    // Set En Passant Target
    List<int>? nextEnPassantTarget;
    if (selectedPiece!.type == PieceType.pawn &&
        (newRow - selectedRow).abs() == 2) {
      int dir = selectedPiece!.isWhite ? -1 : 1;
      nextEnPassantTarget = [selectedRow + dir, selectedCol];
    }
    enPassantTarget = nextEnPassantTarget;

    moveHistorySAN.add(notation);
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Game Over Logic
    bool nextTurnIsWhite = !isWhiteTurn;
    bool nextPlayerInCheck = isKingCheck(nextTurnIsWhite);
    bool nextPlayerHasMoves = false;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == nextTurnIsWhite) {
          if (calculateRealValidMoves(i, j, board[i][j], true).isNotEmpty) {
            nextPlayerHasMoves = true;
            break;
          }
        }
      }
      if (nextPlayerHasMoves) break;
    }

    if (!nextPlayerHasMoves) {
      if (nextPlayerInCheck) {
        moveHistorySAN.last += "#";
        _showGameOverDialog(isWhiteTurn ? "White Wins!" : "Black Wins!");
      } else {
        _showGameOverDialog("Stalemate! Draw.");
      }
    } else if (nextPlayerInCheck) {
      moveHistorySAN.last += "+";
    }

    setState(() {
      isInCheck = nextPlayerInCheck;
      isWhiteTurn = nextTurnIsWhite;
    });
  }

  // ---------------------------------------------------------------------------
  // 3. MOVE CALCULATION
  // ---------------------------------------------------------------------------
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    if (piece == null) return [];
    List<List<int>> candidateMoves = [];
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case PieceType.pawn:
        int nextRow = row + direction;
        if (isInBoard(nextRow, col) && board[nextRow][col] == null)
          candidateMoves.add([nextRow, col]);
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          int doubleStep = row + 2 * direction;
          if (isInBoard(doubleStep, col) &&
              board[doubleStep][col] == null &&
              board[nextRow][col] == null)
            candidateMoves.add([doubleStep, col]);
        }
        if (isInBoard(nextRow, col - 1)) {
          var target = board[nextRow][col - 1];
          if (target != null && target.isWhite != piece.isWhite)
            candidateMoves.add([nextRow, col - 1]);
          if (target == null &&
              enPassantTarget != null &&
              enPassantTarget![0] == nextRow &&
              enPassantTarget![1] == col - 1)
            candidateMoves.add([nextRow, col - 1]);
        }
        if (isInBoard(nextRow, col + 1)) {
          var target = board[nextRow][col + 1];
          if (target != null && target.isWhite != piece.isWhite)
            candidateMoves.add([nextRow, col + 1]);
          if (target == null &&
              enPassantTarget != null &&
              enPassantTarget![0] == nextRow &&
              enPassantTarget![1] == col + 1)
            candidateMoves.add([nextRow, col + 1]);
        }
        break;
      case PieceType.rook:
        _addLinearMoves(candidateMoves, row, col, [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
        ], piece);
        break;
      case PieceType.bishop:
        _addLinearMoves(candidateMoves, row, col, [
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ], piece);
        break;
      case PieceType.queen:
        _addLinearMoves(candidateMoves, row, col, [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ], piece);
        break;
      case PieceType.knight:
        var moves = [
          [2, 1],
          [2, -1],
          [-2, 1],
          [-2, -1],
          [1, 2],
          [1, -2],
          [-1, 2],
          [-1, -2],
        ];
        for (var m in moves) {
          int nr = row + m[0], nc = col + m[1];
          if (isInBoard(nr, nc)) {
            if (board[nr][nc] == null ||
                board[nr][nc]!.isWhite != piece.isWhite)
              candidateMoves.add([nr, nc]);
          }
        }
        break;
      case PieceType.king:
        var moves = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ];
        for (var m in moves) {
          int nr = row + m[0], nc = col + m[1];
          if (isInBoard(nr, nc)) {
            if (board[nr][nc] == null ||
                board[nr][nc]!.isWhite != piece.isWhite)
              candidateMoves.add([nr, nc]);
          }
        }
        // Castling
        if (piece.isWhite ? !whiteKingMoved : !blackKingMoved) {
          bool rightRookMoved = piece.isWhite
              ? whiteRookMoved[1]
              : blackRookMoved[1];
          if (!rightRookMoved &&
              board[row][7] != null &&
              board[row][7]!.type == PieceType.rook &&
              board[row][5] == null &&
              board[row][6] == null) {
            if (!isSquareAttacked(row, 4, !piece.isWhite) &&
                !isSquareAttacked(row, 5, !piece.isWhite) &&
                !isSquareAttacked(row, 6, !piece.isWhite))
              candidateMoves.add([row, 6]);
          }
          bool leftRookMoved = piece.isWhite
              ? whiteRookMoved[0]
              : blackRookMoved[0];
          if (!leftRookMoved &&
              board[row][0] != null &&
              board[row][0]!.type == PieceType.rook &&
              board[row][1] == null &&
              board[row][2] == null &&
              board[row][3] == null) {
            if (!isSquareAttacked(row, 4, !piece.isWhite) &&
                !isSquareAttacked(row, 3, !piece.isWhite) &&
                !isSquareAttacked(row, 2, !piece.isWhite))
              candidateMoves.add([row, 2]);
          }
        }
        break;
    }
    return candidateMoves;
  }

  void _addLinearMoves(
    List<List<int>> moves,
    int r,
    int c,
    List<List<int>> dirs,
    ChessPiece piece,
  ) {
    for (var d in dirs) {
      int i = 1;
      while (true) {
        int nr = r + i * d[0];
        int nc = c + i * d[1];
        if (!isInBoard(nr, nc)) break;
        if (board[nr][nc] != null) {
          if (board[nr][nc]!.isWhite != piece.isWhite) moves.add([nr, nc]);
          break;
        }
        moves.add([nr, nc]);
        i++;
      }
    }
  }

  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
  ) {
    List<List<int>> realMoves = [];
    List<List<int>> rawMoves = calculateRawValidMoves(row, col, piece);
    if (checkSimulation) {
      for (var move in rawMoves) {
        if (simulatedMoveIsSafe(piece!, row, col, move[0], move[1]))
          realMoves.add(move);
      }
    } else {
      realMoves = rawMoves;
    }
    return realMoves;
  }

  bool simulatedMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    ChessPiece? targetPiece = board[endRow][endCol];
    List<int> oldWhiteKingPos = [...whiteKingPos];
    List<int> oldBlackKingPos = [...blackKingPos];

    if (piece.type == PieceType.king) {
      if (piece.isWhite)
        whiteKingPos = [endRow, endCol];
      else
        blackKingPos = [endRow, endCol];
    }
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool safe = !isKingCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = targetPiece;
    whiteKingPos = oldWhiteKingPos;
    blackKingPos = oldBlackKingPos;
    return safe;
  }

  bool isSquareAttacked(int r, int c, bool opponentIsWhite) {
    int pawnDir = opponentIsWhite ? -1 : 1;
    if (isInBoard(r - pawnDir, c - 1) &&
        board[r - pawnDir][c - 1]?.type == PieceType.pawn &&
        board[r - pawnDir][c - 1]?.isWhite == opponentIsWhite)
      return true;
    if (isInBoard(r - pawnDir, c + 1) &&
        board[r - pawnDir][c + 1]?.type == PieceType.pawn &&
        board[r - pawnDir][c + 1]?.isWhite == opponentIsWhite)
      return true;
    var kMoves = [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [1, -2],
      [-1, 2],
      [-1, -2],
    ];
    for (var m in kMoves) {
      if (isInBoard(r + m[0], c + m[1]) &&
          board[r + m[0]][c + m[1]]?.type == PieceType.knight &&
          board[r + m[0]][c + m[1]]?.isWhite == opponentIsWhite)
        return true;
    }
    var kingMoves = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    for (var m in kingMoves) {
      if (isInBoard(r + m[0], c + m[1]) &&
          board[r + m[0]][c + m[1]]?.type == PieceType.king &&
          board[r + m[0]][c + m[1]]?.isWhite == opponentIsWhite)
        return true;
    }
    var dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    for (var d in dirs) {
      int i = 1;
      while (true) {
        int nr = r + i * d[0], nc = c + i * d[1];
        if (!isInBoard(nr, nc)) break;
        var p = board[nr][nc];
        if (p != null) {
          if (p.isWhite == opponentIsWhite) {
            bool isDiagonal = (d[0] != 0 && d[1] != 0);
            if (p.type == PieceType.queen) return true;
            if (isDiagonal && p.type == PieceType.bishop) return true;
            if (!isDiagonal && p.type == PieceType.rook) return true;
          }
          break;
        }
        i++;
      }
    }
    return false;
  }

  bool isKingCheck(bool isWhiteKing) {
    List<int> kPos = isWhiteKing ? whiteKingPos : blackKingPos;
    return isSquareAttacked(kPos[0], kPos[1], !isWhiteKing);
  }

  bool isInBoard(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;
  bool isWhite(int index) => (index ~/ 8 + index % 8) % 2 == 0;
  String _getNotation(
    ChessPiece piece,
    int r1,
    int c1,
    int r2,
    int c2,
    ChessPiece? captured,
  ) {
    String cols = "abcdefgh";
    String rows = "87654321";
    String move = "";
    if (piece.type == PieceType.pawn) {
      move = (captured != null || c1 != c2)
          ? "${cols[c1]}x${cols[c2]}${rows[r2]}"
          : "${cols[c2]}${rows[r2]}";
    } else {
      String code = _getPieceCode(piece.type);
      String capture = (captured != null) ? "x" : "";
      move = "$code$capture${cols[c2]}${rows[r2]}";
    }
    return move;
  }

  String _getPieceCode(PieceType type) => type == PieceType.knight
      ? "N"
      : type == PieceType.bishop
      ? "B"
      : type == PieceType.rook
      ? "R"
      : type == PieceType.queen
      ? "Q"
      : type == PieceType.king
      ? "K"
      : "";

  // ---------------------------------------------------------------------------
  // 4. UI & DIALOGS
  // ---------------------------------------------------------------------------
  Future<PieceType?> _showPromotionDialog(bool isWhite) async {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String p = isWhite ? 'w' : 'b';
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text(
            "Promote Pawn",
            style: TextStyle(color: Colors.white),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _promoteOption(PieceType.queen, 'lib/images/${p}queen.png'),
              _promoteOption(PieceType.rook, 'lib/images/${p}rook.png'),
              _promoteOption(PieceType.bishop, 'lib/images/${p}bishop.png'),
              _promoteOption(PieceType.knight, 'lib/images/${p}knight.png'),
            ],
          ),
        );
      },
    );
  }

  Widget _promoteOption(PieceType type, String path) => GestureDetector(
    onTap: () => Navigator.pop(context, type),
    child: Image.asset(path, width: 40, height: 40),
  );

  void _showGameOverDialog(String msg) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text("Game Over", style: TextStyle(color: Colors.white)),
      content: Text(msg, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            resetGame();
          },
          child: const Text(
            "Play Again",
            style: TextStyle(color: Color(0xFF4C6EF5)),
          ),
        ),
      ],
    ),
  );

  void _showMoveHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Move History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: (moveHistorySAN.length / 2).ceil(),
                itemBuilder: (context, index) {
                  int moveNum = index + 1;
                  String wMove = moveHistorySAN[index * 2];
                  String bMove = (index * 2 + 1 < moveHistorySAN.length)
                      ? moveHistorySAN[index * 2 + 1]
                      : "";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            "$moveNum.",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            wMove,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bMove,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF1B1B1B);
    final Color boardLight = const Color(0xFFEBECD0);
    final Color boardDark = const Color(0xFF739552);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Chess Arena",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: undoMove,
            icon: const Icon(Icons.undo, color: Colors.white70),
          ),
          IconButton(
            onPressed: _showMoveHistory,
            icon: const Icon(Icons.history, color: Colors.white70),
          ),
          IconButton(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Opponent Panel (Refactored)
            Expanded(
              flex: 2,
              child: PlayerPanel(
                isMe: false,
                isTurn: !isWhiteTurn,
                capturedPieces: whiteDeadPieces,
              ),
            ),

            // Board (Keep here as it depends on local move logic)
            Expanded(
              flex: 6,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isInCheck)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Text(
                            isWhiteTurn
                                ? "⚠️ White King in Check"
                                : "⚠️ Black King in Check",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: 64,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                            itemBuilder: (context, index) {
                              int row = index ~/ 8;
                              int col = index % 8;
                              bool isSelected =
                                  selectedRow == row && selectedCol == col;
                              bool isValidMove = validMoves.any(
                                (m) => m[0] == row && m[1] == col,
                              );
                              Color squareColor = (row + col) % 2 == 0
                                  ? boardLight
                                  : boardDark;
                              if (isSelected)
                                squareColor = const Color(0xFFBACA2B);
                              if (isValidMove)
                                squareColor = squareColor.withOpacity(0.8);

                              return GestureDetector(
                                onTap: () => pieceSelected(row, col),
                                child: Container(
                                  color: squareColor,
                                  child: Stack(
                                    children: [
                                      Square(
                                        isWhite: isWhite(index),
                                        piece: board[row][col],
                                        isSelected: isSelected,
                                        isValidMove: isValidMove,
                                        onTap: null,
                                      ),
                                      if (isValidMove &&
                                          board[row][col] == null)
                                        Center(
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Player Panel (Refactored)
            Expanded(
              flex: 2,
              child: PlayerPanel(
                isMe: true,
                isTurn: isWhiteTurn,
                capturedPieces: blackDeadPieces,
                lastMove: moveHistorySAN.isNotEmpty
                    ? moveHistorySAN.last
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
