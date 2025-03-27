import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/game_service.dart';
import '../models/chess_game.dart';
import '../widgets/chess_board_widget.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  String? _lastMove;
  int _whiteTime = 600; // 10 minutes in seconds
  int _blackTime = 600;
  bool _isGameOver = false;
  String? _winner;
  List<String> _moveHistory = [];
  String _playerName = '';
  String _opponentName = '';
  Timer? _timer;
  final _auth = FirebaseAuth.instance;
  List<String> _whiteCapturedPieces = [];
  List<String> _blackCapturedPieces = [];
  
  @override
  void initState() {
    super.initState();
    isWhite = widget.isCreator;
    isMyTurn = widget.isCreator;
    _setupGame();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted && !_isGameOver) {
        setState(() {
          if (isMyTurn) {
            if (isWhite && _whiteTime > 0) {
              _whiteTime--;
            } else if (!isWhite && _blackTime > 0) {
              _blackTime--;
            }
            
            // Update time in Firestore when it's our turn
            _gameService.updateTime(
              gameId: widget.gameId,
              whiteTime: _whiteTime,
              blackTime: _blackTime,
            );
          }
          
          if (_whiteTime <= 0 || _blackTime <= 0) {
            _handleGameOver();
            timer.cancel();
          }
        });
      }
    });
  }

  void _handleGameOver() {
    setState(() {
      _isGameOver = true;
      _winner = _whiteTime <= 0 ? 'Black' : 'White';
    });
    _showGameOverDialog();
  }

  void _setupGame() {
    _gameService.listenToGame(widget.gameId).listen((snapshot) {
      if (!snapshot.exists) return;
      
      final data = snapshot.data() as Map<String, dynamic>;
      
      // Update player names from Firebase users
      setState(() {
        if (widget.isCreator) {
          _playerName = _auth.currentUser?.displayName ?? 'Anonymous';
          _opponentName = data['player2_name'] ?? 'Waiting...';
        } else {
          _playerName = _auth.currentUser?.displayName ?? 'Anonymous';
          _opponentName = data['player1_name'] ?? 'Opponent';
        }

        // Always update times from Firestore
        _whiteTime = data['white_time'] ?? _whiteTime;
        _blackTime = data['black_time'] ?? _blackTime;
      });

      if (data['board_state'] != _controller.getFen()) {
        _controller.loadFen(data['board_state']);
        
        // Update move history
        if (data['moves'] != null) {
          setState(() {
            _moveHistory = List<String>.from(data['moves']);
            _lastMove = _moveHistory.isNotEmpty ? _moveHistory.last : null;
          });
        }
      }
      
      setState(() {
        isMyTurn = (data['turn'] == 'white' && isWhite) ||
                   (data['turn'] == 'black' && !isWhite);
        
        // Check for checkmate or stalemate
        if (data['game_over'] == true) {
          _isGameOver = true;
          _winner = data['winner'];
          _showGameOverDialog();
        }
      });
    });

    // Start timer only after setup
    _startTimer();
  }

  void _showGameOverDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(_winner != null 
          ? '$_winner wins!' 
          : 'The game ended in a draw'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Return to Lobby'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onMove(String move) async {
    final boardStateBefore = _controller.game.fen;
    if (!isMyTurn) return;
    try {
      _moveHistory.add(move);
      await _gameService.makeMove(
        gameId: widget.gameId,
        move: move,
        boardState: _controller.getFen(),
        turn: isWhite ? 'black' : 'white',
        moves: _moveHistory,
        whiteTime: _whiteTime,
        blackTime: _blackTime,
      );
      
      // Check for checkmate or stalemate
      if (_controller.isCheckMate() || _controller.isDraw()) {
        await _gameService.endGame(
          gameId: widget.gameId,
          winner: _controller.isCheckMate() 
              ? (isWhite ? 'White' : 'Black')
              : null,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
    final boardStateAfter = _controller.game.fen;
    _updateCapturedPieces(move, boardStateBefore, boardStateAfter);
    setState(() {});
  }

  void _updateCapturedPieces(String move, String boardStateBefore, String boardStateAfter) {
    final beforePieces = boardStateBefore.replaceAll(RegExp(r'[^rnbqkpRNBQKP]'), '').split('');
    final afterPieces = boardStateAfter.replaceAll(RegExp(r'[^rnbqkpRNBQKP]'), '').split('');
    
    for (var piece in beforePieces) {
      if (!afterPieces.contains(piece)) {
        if (piece.toUpperCase() == piece) {
          _blackCapturedPieces.add(piece);
        } else {
          _whiteCapturedPieces.add(piece);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isWhite ? 'Playing as White' : 'Playing as Black'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () => _showResignDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[900]!, Colors.indigo[700]!],
          ),
        ),
        child: Column(
          children: [
            _buildPlayerInfo(false), // Opponent
            const Spacer(),
            _buildChessBoard(),
            const Spacer(),
            _buildPlayerInfo(true), // Current player
            if (_moveHistory.isNotEmpty) _buildMoveHistory(),
            Container(
              padding: EdgeInsets.all(8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _whiteCapturedPieces.map((piece) => _buildCapturedPiece(piece)).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _blackCapturedPieces.map((piece) => _buildCapturedPiece(piece)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(bool isCurrentPlayer) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isCurrentPlayer ? _playerName : _opponentName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isCurrentPlayer 
                ? _formatTime(isWhite ? _whiteTime : _blackTime)
                : _formatTime(isWhite ? _blackTime : _whiteTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ChessBoard(
        controller: _controller,
        boardColor: BoardColor.orange,
        boardOrientation: isWhite ? PlayerColor.white : PlayerColor.black,
        onMove: () {
          final moves = _controller.getSan();
          if (moves.isNotEmpty) {
            _onMove(moves.last!);
          }
        },
        enableUserMoves: isMyTurn && !_isGameOver,
      ),
    );
  }

  Widget _buildMoveHistory() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _moveHistory.length,
        itemBuilder: (context, index) {
          final moveNumber = (index ~/ 2) + 1;
          final isWhiteMove = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                isWhiteMove 
                    ? '$moveNumber. ${_moveHistory[index]}'
                    : _moveHistory[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: index == _moveHistory.length - 1 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCapturedPiece(String piece) {
    final Map<String, String> pieceToUnicode = {
      'p': '♟', 'P': '♙',
      'r': '♜', 'R': '♖',
      'n': '♞', 'N': '♘',
      'b': '♝', 'B': '♗',
      'q': '♛', 'Q': '♕',
      'k': '♚', 'K': '♔',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        pieceToUnicode[piece] ?? '',
        style: TextStyle(
          fontSize: 24.sp,
          color: piece.toUpperCase() == piece ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void _showResignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resign Game'),
        content: const Text('Are you sure you want to resign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _gameService.endGame(
                gameId: widget.gameId,
                winner: isWhite ? 'Black' : 'White',
              );
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Resign'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
} 