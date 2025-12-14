import 'package:flutter/material.dart';
import 'piece.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.lightGreenAccent;
    } else {
      squareColor = isWhite
          ? Colors.white
          : const Color.fromARGB(255, 116, 116, 116);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 8.0 : 0.0),
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                fit: BoxFit.contain,
                color: piece!.isWhite ? null : Colors.black,
              )
            : null,
      ),
    );
  }
}
