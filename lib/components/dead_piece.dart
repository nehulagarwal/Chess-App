import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        color: isWhite ? null : Colors.white,
      ),
    );
  }
}
