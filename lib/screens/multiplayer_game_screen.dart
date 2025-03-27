import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/game_service.dart';
import '../models/chess_game.dart';
import '../widgets/chess_board_widget.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final String gameId;
  final bool isCreator;
  
  const MultiplayerGameScreen({
    super.key,
    required this.gameId,
    required this.isCreator,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final GameService _gameService = GameService();
  final ChessBoardController _controller = ChessBoardController();
  bool isMyTurn = false;
  late bool isWhite;

  @override
  void initState() {
    super.initState();
    isWhite = widget.isCreator; // Creator plays white
    isMyTurn = widget.isCreator; // White moves first
    _setupGame();
  }

  void _setupGame() {
    _gameService.listenToGame(widget.gameId).listen((snapshot) {
      if (!snapshot.exists) return;
      
      final data = snapshot.data() as Map<String, dynamic>;
      
      // Update board state if it changed
      if (data['board_state'] != _controller.getFen()) {
        _controller.loadFen(data['board_state']);
      }
      
      // Update turn
      setState(() {
        isMyTurn = (data['turn'] == 'white' && isWhite) ||
                   (data['turn'] == 'black' && !isWhite);
      });
    });
  }

  void _onMove(String moveStr) async {
    if (!isMyTurn) return;
    try {
      await _gameService.makeMove(
        gameId: widget.gameId,
        move: moveStr,
        boardState: _controller.getFen(),
        turn: isWhite ? 'black' : 'white', // Switch turns after move
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isWhite ? 'Playing as White' : 'Playing as Black'),
        backgroundColor: Colors.indigo[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isMyTurn ? 'Your Turn' : "Opponent's Turn",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ChessBoard(
              controller: _controller,
              boardColor: BoardColor.orange,
              boardOrientation: isWhite ? PlayerColor.white : PlayerColor.black,
              onMove: () {
                final moves = _controller.getSan();
                if (moves.isNotEmpty) {
                  _onMove(moves.last!);
                }
              },
              enableUserMoves: isMyTurn,
            ),
          ],
        ),
      ),
    );
  }
} 