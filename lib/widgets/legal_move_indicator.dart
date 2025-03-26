import 'package:flutter/material.dart';

class LegalMoveIndicator extends StatelessWidget {
  final String move;
  final double squareSize;
  final VoidCallback onTap;

  const LegalMoveIndicator({
    super.key,
    required this.move,
    required this.squareSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final file = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = 7 - (int.parse(move[1]) - 1);

    return Positioned(
      left: file * squareSize + (squareSize / 2) - 10,
      top: rank * squareSize + (squareSize / 2) - 10,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
} 