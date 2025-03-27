import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material show Color;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/game_service.dart';
import '../models/chess_game.dart';
import '../widgets/chess_board_widget.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> with TickerProviderStateMixin {
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
  List<String> whiteCapturedPieces = [];
  List<String> blackCapturedPieces = [];
  
  // Add new animation controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // Add this property to the state class
  Set<String> _possibleMoves = {};

  @override
  void initState() {
    super.initState();
    isWhite = widget.isCreator;
    isMyTurn = widget.isCreator;
    _setupGame();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
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
    _showGameOverDialog(_winner != null ? '$_winner wins!' : 'The game ended in a draw');
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
          _showGameOverDialog(_winner != null ? '$_winner wins!' : 'The game ended in a draw');
        }
      });
    });

    // Start timer only after setup
    _startTimer();
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 0.8.sw,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo[900]!,
                  Colors.indigo[800]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
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
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 64.sp,
                  color: Colors.amber[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Game Over',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 16.h,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildDialogButton(
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
                      'New Game',
                      Icons.refresh_rounded,
                      Colors.green,
                      () {
                        setState(() {
                          _controller.resetBoard();
                          isMyTurn = widget.isCreator;
                          _moveHistory.clear();
                          whiteCapturedPieces.clear();
                          blackCapturedPieces.clear();
                          _whiteTime = 600;
                          _blackTime = 600;
                          _startTimer();
                        });
                        Navigator.of(context).pop();
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

  Widget _buildDialogButton(String text, IconData icon, MaterialColor color, VoidCallback onPressed) {
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

      final boardStateAfter = _controller.game.fen;
      _updateCapturedPieces(move, boardStateBefore, boardStateAfter);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _updateCapturedPieces(String move, String boardStateBefore, String boardStateAfter) {
    // Get just the piece positions from FEN
    final beforePieces = boardStateBefore.split(' ')[0];
    final afterPieces = boardStateAfter.split(' ')[0];

    // If a piece was captured, the after position will have one less piece
    if (beforePieces.replaceAll(RegExp(r'[^rnbqkpRNBQKP]'), '').length >
        afterPieces.replaceAll(RegExp(r'[^rnbqkpRNBQKP]'), '').length) {
      
      // Find which piece was captured by comparing the positions
      final capturedPiece = move.contains('x') 
          ? move[move.indexOf('x') - 1].toLowerCase() 
          : 'p'; // If no piece specified, it's a pawn

      setState(() {
        if (isMyTurn) {
          // I captured opponent's piece
          whiteCapturedPieces.add(capturedPiece);
        } else {
          // Opponent captured my piece
          blackCapturedPieces.add(capturedPiece);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const material.Color(0xFF1a237e),
              const material.Color(0xFF0d47a1),
              const material.Color(0xFF1a237e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: Column(
                  children: [
                    _buildPlayerInfo(false), // Opponent at top
                    Expanded(child: _buildChessBoard()),
                    _buildPlayerInfo(true), // Current player at bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: () => _showResignDialog(),
          ),
          Column(
            children: [
              Text(
                'Multiplayer Game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '10 Min Game',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.flag, color: Colors.white, size: 20.sp),
            onPressed: () => _showResignDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(bool isCurrentPlayer) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final isPlayerTurn = (isCurrentPlayer && isMyTurn) || (!isCurrentPlayer && !isMyTurn);
        final glowOpacity = isPlayerTurn ? 0.3 + (0.2 * _pulseController.value) : 0.0;
        
        // Determine if this player info is for white or black pieces
        final isWhitePlayer = (isCurrentPlayer && isWhite) || (!isCurrentPlayer && !isWhite);
        
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isPlayerTurn 
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isPlayerTurn 
                        ? Colors.blue.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isPlayerTurn ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(glowOpacity),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ] : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: isWhitePlayer ? Colors.white : Colors.black,
                            child: Icon(
                              Icons.person,
                              size: 20.sp,
                              color: isWhitePlayer ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCurrentPlayer ? _playerName : _opponentName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.sp,
                                fontWeight: isPlayerTurn ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isPlayerTurn)
                              Text(
                                'Current turn',
                                style: TextStyle(
                                  color: Colors.blue.withOpacity(0.9),
                                  fontSize: 12.sp,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    _buildTimer(
                      isWhitePlayer ? _whiteTime : _blackTime,
                      isPlayerTurn,
                    ),
                  ],
                ),
              ),
              _buildCapturedPiecesRow(isWhitePlayer ? whiteCapturedPieces : blackCapturedPieces),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimer(int timeLeft, bool isCurrentTurn) {
    final isLowTime = timeLeft < 30;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: isLowTime 
            ? Colors.red.withOpacity(0.1) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLowTime 
              ? Colors.red.withOpacity(0.5) 
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        _formatTime(timeLeft),
        style: TextStyle(
          color: isLowTime 
              ? Colors.red 
              : Colors.white.withOpacity(0.9),
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto Mono',
        ),
      ),
    );
  }

  Widget _buildCapturedPiecesRow(List<String> pieces) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pieces.isEmpty 
            ? [
                Text(
                  '---',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 20.sp,
                  ),
                ),
              ]
            : pieces.map((piece) => _buildCapturedPiece(piece)).toList(),
      ),
    );
  }

  Widget _buildChessBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth > constraints.maxHeight 
            ? constraints.maxHeight 
            : constraints.maxWidth;
        
        return Transform.rotate(
          angle: isWhite ? 0 : pi,
          child: Container(
            margin: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Transform.rotate(
              angle: isWhite ? 0 : pi,
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
                size: boardSize,
              ),
            ),
          ),
        );
      },
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 0.8.sw,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo[900]!,
                Colors.indigo[800]!,
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
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
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 64.sp,
                color: Colors.amber[400],
              ),
              SizedBox(height: 16.h),
              Text(
                'Resign Game',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to resign? This will count as a loss.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDialogButton(
                    'Stay',
                    Icons.close_rounded,
                    Colors.green,
                    () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 8.w),
                  _buildDialogButton(
                    'Resign',
                    Icons.flag_rounded,
                    Colors.red,
                    () async {
                      await _gameService.endGame(
                        gameId: widget.gameId,
                        winner: isWhite ? 'Black' : 'White',
                      );
                      if (mounted) {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }
} 