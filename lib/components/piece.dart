enum PieceType { king, queen, rook, bishop, knight, pawn }

class ChessPiece {
  final PieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });
}
