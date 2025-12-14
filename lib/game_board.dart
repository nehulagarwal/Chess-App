import 'dart:ui';

import 'package:chess/components/piece.dart';
import 'package:flutter/material.dart';
import 'package:chess/helper/helper_function.dart';
import 'components/square.dart';
import 'components/dead_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  // dead pieces list
  List<ChessPiece> whiteDeadPieces = [];
  List<ChessPiece> blackDeadPieces = [];

  // turn
  bool isWhiteTurn = true;

  //checks
  List<int> whiteKingPos = [7, 4];
  List<int> blackKingPos = [0, 4];
  bool isInCheck = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //initialize board
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(8, (index) => null),
    );
    //pawns
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

    //bishops
    newBoard[0][2] = ChessPiece(
      type: PieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/bbishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: PieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/bbishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: PieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/wbishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: PieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/wbishop.png',
    );

    //rooks
    newBoard[0][0] = ChessPiece(
      type: PieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/brook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: PieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/brook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: PieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/wrook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: PieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/wrook.png',
    );

    //knights
    newBoard[0][1] = ChessPiece(
      type: PieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/bknight.png',
    );
    newBoard[0][6] = ChessPiece(
      type: PieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/bknight.png',
    );
    newBoard[7][1] = ChessPiece(
      type: PieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/wknight.png',
    );
    newBoard[7][6] = ChessPiece(
      type: PieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/wknight.png',
    );

    //queens
    newBoard[0][3] = ChessPiece(
      type: PieceType.queen,
      isWhite: false,
      imagePath: 'lib/images/bqueen.png',
    );
    newBoard[7][3] = ChessPiece(
      type: PieceType.queen,
      isWhite: true,
      imagePath: 'lib/images/wqueen.png',
    );

    //kings
    newBoard[0][4] = ChessPiece(
      type: PieceType.king,
      isWhite: false,
      imagePath: 'lib/images/bking.png',
    );
    newBoard[7][4] = ChessPiece(
      type: PieceType.king,
      isWhite: true,
      imagePath: 'lib/images/wking.png',
    );

    board = newBoard;
  }

  // chess piece selection and valid moves calculation
  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        // select piece
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        //select different piece of same color
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      // move piece if valid move
      else if (selectedPiece != null &&
          validMoves.any((move) => move[0] == row && move[1] == col)) {
        movePiece(row, col);
        return;
      }
      // valid moves
      validMoves = calculateRealValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
        true,
      );
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    if (piece == null) {
      return [];
    }
    List<List<int>> candidateMoves = [];
    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case PieceType.pawn:
        int nextRow = row + direction;
        if (isInBoard(nextRow, col) && board[nextRow][col] == null) {
          candidateMoves.add([nextRow, col]);
        }
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          int doubleStepRow = row + 2 * direction;
          if (isInBoard(doubleStepRow, col) &&
              board[doubleStepRow][col] == null &&
              board[nextRow][col] == null) {
            candidateMoves.add([doubleStepRow, col]);
          }
        }
        if (isInBoard(nextRow, col - 1) &&
            board[nextRow][col - 1] != null &&
            board[nextRow][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([nextRow, col - 1]);
        }
        if (isInBoard(nextRow, col + 1) &&
            board[nextRow][col + 1] != null &&
            board[nextRow][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([nextRow, col + 1]);
        }
        break;
      case PieceType.rook:
        // Rook movement logic can be added here
        var directions = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.knight:
        // Knight movement logic can be added here
        var knightMoves = [
          [2, 1],
          [2, -1],
          [-2, 1],
          [-2, -1],
          [1, 2],
          [1, -2],
          [-1, 2],
          [-1, -2],
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case PieceType.bishop:
        // Bishop movement logic can be added here
        var directions = [
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.queen:
        // Queen movement logic can be added here
        var directions = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case PieceType.king:
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
        for (var mv in kingMoves) {
          var newRow = row + mv[0];
          var newCol = col + mv[1];
          if (!isInBoard(newRow, newCol)) continue;

          // IMPORTANT: do NOT call anything that eventually calls calculateRawValidMoves again.
          // isSquareAttacked only uses calculateRawAttackSquares -> safe.
          if (isSquareAttacked(newRow, newCol, !piece.isWhite)) continue;

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
        break;
    }
    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
  ) {
    List<List<int>> realValidMoves = [];
    List<List<int>> rawValidMoves = calculateRawValidMoves(row, col, piece);

    if (checkSimulation) {
      for (var move in rawValidMoves) {
        int endRow = move[0];
        int endCol = move[1];
        //simulate move
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = rawValidMoves;
    }
    return realValidMoves;
  }

  // --- 1) attack-only generator: NO recursion, only looks at board and piece types ---
  List<List<int>> calculateRawAttackSquares(
    int row,
    int col,
    ChessPiece? piece,
  ) {
    if (piece == null) return [];
    List<List<int>> attacks = [];
    int dir = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case PieceType.pawn:
        int r = row + dir;
        if (isInBoard(r, col - 1)) attacks.add([r, col - 1]);
        if (isInBoard(r, col + 1)) attacks.add([r, col + 1]);
        break;

      case PieceType.knight:
        var km = [
          [2, 1],
          [2, -1],
          [-2, 1],
          [-2, -1],
          [1, 2],
          [1, -2],
          [-1, 2],
          [-1, -2],
        ];
        for (var m in km) {
          int nr = row + m[0], nc = col + m[1];
          if (!isInBoard(nr, nc)) continue;
          attacks.add([nr, nc]);
        }
        break;

      case PieceType.bishop:
        var dirs = [
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ];
        for (var d in dirs) {
          int i = 1;
          while (true) {
            int nr = row + i * d[0], nc = col + i * d[1];
            if (!isInBoard(nr, nc)) break;
            attacks.add([nr, nc]);
            if (board[nr][nc] != null) break; // blocked beyond this square
            i++;
          }
        }
        break;

      case PieceType.rook:
        var dirs = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
        ];
        for (var d in dirs) {
          int i = 1;
          while (true) {
            int nr = row + i * d[0], nc = col + i * d[1];
            if (!isInBoard(nr, nc)) break;
            attacks.add([nr, nc]);
            if (board[nr][nc] != null) break;
            i++;
          }
        }
        break;

      case PieceType.queen:
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
            int nr = row + i * d[0], nc = col + i * d[1];
            if (!isInBoard(nr, nc)) break;
            attacks.add([nr, nc]);
            if (board[nr][nc] != null) break;
            i++;
          }
        }
        break;

      case PieceType.king:
        var kmoves = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ];
        for (var m in kmoves) {
          int nr = row + m[0], nc = col + m[1];
          if (!isInBoard(nr, nc)) continue;
          attacks.add([nr, nc]);
        }
        break;

      default:
        break;
    }

    return attacks;
  }

  // move pieces
  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      // capture logic
      var capturedPiece = board[newRow][newCol]!;
      if (capturedPiece.isWhite) {
        whiteDeadPieces.add(capturedPiece);
      } else {
        blackDeadPieces.add(capturedPiece);
      }
    }

    if (selectedPiece!.type == PieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPos = [newRow, newCol];
      } else {
        blackKingPos = [newRow, newCol];
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // check for kings under attack
    if (isKingCheck(!isWhiteTurn)) {
      isInCheck = true;
    } else {
      isInCheck = false;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if chck mate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Check Mate!"),
          content: Text(isWhiteTurn ? "White Wins!" : "Black Wins!"),
          actions: [
            //play again button
            TextButton(onPressed: resetGame, child: const Text("Play Again")),
          ],
        ),
      );
    }

    //change turns
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingCheck(bool isWhiteKing) {
    List<int> kingPos = isWhiteKing ? whiteKingPos : blackKingPos;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          false,
        );

        if (pieceValidMoves.any(
          (move) => move[0] == kingPos[0] && move[1] == kingPos[1],
        )) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    // Save pieces involved
    ChessPiece? capturedPiece = board[endRow][endCol];

    // --- Backup king positions properly (deep copy) ---
    List<int> originalWhiteKingPos = [...whiteKingPos];
    List<int> originalBlackKingPos = [...blackKingPos];

    // If king moves, update king position for simulation
    if (piece.type == PieceType.king) {
      if (piece.isWhite) {
        whiteKingPos = [endRow, endCol];
      } else {
        blackKingPos = [endRow, endCol];
      }
    }

    // --- Simulate the move ---
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // --- Check if our own king is now in check ---
    bool kingIsInCheck = isKingCheck(piece.isWhite);

    // --- Restore board ---
    board[startRow][startCol] = piece;
    board[endRow][endCol] = capturedPiece;

    // --- Restore king positions ---
    whiteKingPos = originalWhiteKingPos;
    blackKingPos = originalBlackKingPos;

    // Move is safe only if king is NOT in check
    return !kingIsInCheck;
  }

  //squared attack
  bool isSquareAttacked(int targetRow, int targetCol, bool byWhite) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p == null) continue;
        if (p.isWhite != byWhite) continue;

        final attacks = calculateRawAttackSquares(r, c, p);
        // quick check if any attack covers the target
        if (attacks.any((m) => m[0] == targetRow && m[1] == targetCol)) {
          return true;
        }
      }
    }
    return false;
  }

  // is it check mate?
  bool isCheckMate(bool isWhiteTurn) {
    // if king is not in check, return false
    if (!isKingCheck(isWhiteTurn)) {
      return false;
    }

    // if there is at least one legal move for any of the players pieces then its not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == isWhiteTurn) {
          List<List<int>> pieceValidMoves = calculateRealValidMoves(
            i,
            j,
            board[i][j],
            true,
          );

          if (pieceValidMoves.isNotEmpty) {
            return false;
          }
        }
      }
    }

    // if none of the above conditions are met then there are no legal moves and the king is in check so its checkmate
    return true;
  }

  // reset game
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    isInCheck = false;
    whiteDeadPieces.clear();
    blackDeadPieces.clear();
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      isWhiteTurn = true;
      isInCheck = false;
      whiteKingPos = [7, 4];
      blackKingPos = [0, 4];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (isInCheck)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                isWhiteTurn
                    ? "⚠️ White King is in CHECK!"
                    : "⚠️ Black King is in CHECK!",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Expanded(
            child: GridView.builder(
              itemCount: whiteDeadPieces.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whiteDeadPieces[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                //check if selected
                bool isSelected = selectedRow == row && selectedCol == col;
                //check if valid move
                bool isValidMove = validMoves.any(
                  (move) => move[0] == row && move[1] == col,
                );
                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: blackDeadPieces.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackDeadPieces[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
