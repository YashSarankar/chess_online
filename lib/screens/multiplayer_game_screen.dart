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
  final ChessGame _game = ChessGame();
  String? selectedSquare;
  bool isMyTurn = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _gameService.listenToGame(widget.gameId).listen((snapshot) {
      if (!snapshot.exists) return;
      
      final data = snapshot.data() as Map<String, dynamic>;
      
      // Update board state
      if (data['board_state'] != _controller.getFen()) {
        _controller.loadFen(data['board_state']);
      }
      
      // Update turn
      setState(() {
        isMyTurn = (data['turn'] == 'white' && widget.isCreator) ||
                   (data['turn'] == 'black' && !widget.isCreator);
      });
      
      // Handle game end
      if (data['status'] == 'completed') {
        _handleGameEnd(data['winner']);
      }
    });
  }

  void _handleGameEnd(String winnerId) {
    // Show game over dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _gameService.listenToGame(widget.gameId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Game info
              // Chess board
              // Controls
            ],
          );
        },
      ),
    );
  }
} 