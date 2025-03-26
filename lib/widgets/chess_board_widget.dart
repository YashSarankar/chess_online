import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import '../models/chess_game.dart';
import 'legal_move_indicator.dart';
import '../models/chess_game.dart' show GameStatus;

class ChessBoardWidget extends StatelessWidget {
  final ChessBoardController controller;
  final ChessGame game;
  final double boardSize;
  final String? selectedSquare;
  final Function(String) onSquareSelected;
  final VoidCallback onGameStateChanged;
  final Function(String piece)? onPieceCapture;
  final Function(String from, String to)? onMove;
  final BoardColor boardColor;

  const ChessBoardWidget({
    super.key,
    required this.controller,
    required this.game,
    required this.boardSize,
    required this.selectedSquare,
    required this.onSquareSelected,
    required this.onGameStateChanged,
    required this.onPieceCapture,
    required this.onMove,
    required this.boardColor,
  });

  @override
  Widget build(BuildContext context) {
    final squareSize = boardSize / 8;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          _buildChessBoard(context),
          if (selectedSquare != null)
            ..._buildLegalMoveIndicators(context, squareSize),
        ],
      ),
    );
  }

  Widget _buildChessBoard(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPosition = box.globalToLocal(details.globalPosition);
            final String tappedSquare = _getSquareFromPosition(localPosition, boardSize / 8);
            onSquareSelected(tappedSquare);
          },
          child: ChessBoard(
            controller: controller,
            boardOrientation: game.playerIsWhite ? PlayerColor.white : PlayerColor.black,
            enableUserMoves: true,
            onMove: () => _handleMove(context),
            size: boardSize,
            boardColor: boardColor,
          ),
        ),
        ...List.generate(8, (rank) {
          return List.generate(8, (file) {
            final square = game.playerIsWhite 
                ? String.fromCharCode('a'.codeUnitAt(0) + file) + (8 - rank).toString()
                : String.fromCharCode('a'.codeUnitAt(0) + file) + (rank + 1).toString();
            return Positioned(
              left: file * (boardSize / 8),
              top: rank * (boardSize / 8),
              child: Container(
                width: boardSize / 8,
                height: boardSize / 8,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(2),
                child: Text(
                  square,
                  style: TextStyle(
                    color: (file + rank) % 2 == 0 ? Colors.brown[300] : Colors.white70,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          });
        }).expand((widgets) => widgets).toList(),
      ],
    );
  }

  Future<void> _handleMove(BuildContext context) async {
    try {
      final moves = controller.getSan();
      if (moves.isNotEmpty) {
        game.makeMove(moves.last!);
        onGameStateChanged();
        
        await _checkGameStatusAndMakeNextMove(context);
      }
    } catch (e) {
      print('Invalid move: $e');
    }
  }

  Future<void> _checkGameStatusAndMakeNextMove(BuildContext context) async {
    // Check game status
    final gameStatus = game.getGameStatus();
    if (gameStatus == GameStatus.checkmate) {
      final winner = game.winner == PlayerColor.white ? "White" : "Black";
      _showGameOverDialog(context, '$winner wins by checkmate!');
      return;
    } else if (gameStatus == GameStatus.draw) {
      _showGameOverDialog(context, 'Game is a draw!');
      return;
    }

    // Handle captured pieces
    final capturedPiece = game.getCapturedPiece();
    if (capturedPiece != null) {
      onPieceCapture?.call(capturedPiece);
    }

    // Make bot move if it's bot's turn
    if (game.isBotMode && 
        ((game.currentTurn == PlayerColor.black && game.playerIsWhite) ||
         (game.currentTurn == PlayerColor.white && !game.playerIsWhite))) {
      await Future.delayed(const Duration(milliseconds: 500));
      final botMove = game.getBotMove();
      if (botMove != null) {
        final moveMap = Map<String, String>.from(
          Map<String, dynamic>.from(
            botMove.substring(1, botMove.length - 1)
                .split(', ')
                .map((e) => e.split(': '))
                .map((e) => MapEntry(e[0], e[1].replaceAll("'", "")))
                .toList()
                .asMap()
                .map((_, e) => e),
          ),
        );

        if (moveMap['promotion'] != null) {
          game.makePromotionMove(moveMap['from']!, moveMap['to']!, moveMap['promotion']!);
        } else {
          game.makeMoveFromTo(moveMap['from']!, moveMap['to']!);
        }
        
        controller.makeMove(
          from: moveMap['from']!,
          to: moveMap['to']!,
        );
        onGameStateChanged();
      }
    }
  }

  List<Widget> _buildLegalMoveIndicators(BuildContext context, double squareSize) {
    final legalMoves = game.getLegalMoves(selectedSquare!);
    
    return legalMoves.map((move) {
      return LegalMoveIndicator(
        move: move,
        squareSize: squareSize,
        onTap: () => _handleLegalMove(context, move),
      );
    }).toList();
  }

  Future<void> _handleLegalMove(BuildContext context, String move) async {
    try {
      game.makeMoveFromTo(selectedSquare!, move);
      controller.makeMove(from: selectedSquare!, to: move);
      onGameStateChanged();

      await _checkGameStatusAndMakeNextMove(context);

      if (onMove != null) {
        await onMove!(selectedSquare!, move);
      }
    } catch (e) {
      print('Invalid move: $e');
    }
  }

  void _showGameOverDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo[900]!,
                  Colors.indigo[800]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: Colors.amber[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Game Over',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildDialogButton(
                      context,
                      'Return to Home',
                      Icons.home_rounded,
                      Colors.red,
                      () {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                    ),
                    _buildDialogButton(
                      context,
                      'New Game',
                      Icons.refresh_rounded,
                      Colors.green,
                      () {
                        Navigator.of(context).pop();
                        _resetGame(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(BuildContext context, String text, IconData icon, MaterialColor color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetGame(BuildContext context) {
    game.reset();
    controller.resetBoard();
    onPieceCapture?.call('clear');
    onGameStateChanged();
  }

  String _getSquareFromPosition(Offset position, double squareSize) {
    int file = (position.dx / squareSize).floor();
    int rank = 7 - (position.dy / squareSize).floor();
    
    String fileStr = String.fromCharCode('a'.codeUnitAt(0) + file);
    String rankStr = (rank + 1).toString();
    
    return '$fileStr$rankStr';
  }
} 