import 'package:flutter/material.dart';
import 'piece.dart';

class PlayerPanel extends StatelessWidget {
  final bool isMe;
  final bool isTurn;
  final List<ChessPiece> capturedPieces;
  final String? lastMove;

  const PlayerPanel({
    super.key,
    required this.isMe,
    required this.isTurn,
    required this.capturedPieces,
    this.lastMove,
  });

  @override
  Widget build(BuildContext context) {
    final Color panelColor = Colors.white.withOpacity(0.05);
    final Color accentColor = const Color(0xFF4C6EF5);

    // If it's my turn (and I am me), OR opponent's turn (and I am opponent)
    // Actually, simpler logic: "isTurn" is passed in as "Is this specific player's turn?"

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: isTurn ? Border.all(color: accentColor, width: 1.5) : null,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: isMe ? accentColor : Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          // Name & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isMe ? "You (White)" : "Opponent (Black)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isTurn ? "Thinking..." : "Waiting",
                  style: TextStyle(
                    color: isTurn ? accentColor : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (isMe && lastMove != null && lastMove!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Last: $lastMove",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Captured Pieces
          Expanded(
            flex: 2,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              children: capturedPieces
                  .map(
                    (p) => SizedBox(
                      height: 25,
                      width: 25,
                      child: Image.asset(p.imagePath),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
