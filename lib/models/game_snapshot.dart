import '../components/piece.dart';

class GameSnapshot {
  final List<List<ChessPiece?>> board;
  final bool isWhiteTurn;
  final List<ChessPiece> whiteDeadPieces;
  final List<ChessPiece> blackDeadPieces;
  final List<int> whiteKingPos;
  final List<int> blackKingPos;
  final bool whiteKingMoved;
  final bool blackKingMoved;
  final List<bool> whiteRookMoved;
  final List<bool> blackRookMoved;
  final bool isInCheck;
  final List<int>? enPassantTarget;
  final String lastMoveDescription;

  GameSnapshot({
    required this.board,
    required this.isWhiteTurn,
    required this.whiteDeadPieces,
    required this.blackDeadPieces,
    required this.whiteKingPos,
    required this.blackKingPos,
    required this.whiteKingMoved,
    required this.blackKingMoved,
    required this.whiteRookMoved,
    required this.blackRookMoved,
    required this.isInCheck,
    required this.enPassantTarget,
    required this.lastMoveDescription,
  });
}
