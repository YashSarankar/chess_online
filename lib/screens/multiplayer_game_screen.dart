import 'package:chess_online/screens/game_lobby_screen.dart';
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
import 'package:google_fonts/google_fonts.dart';

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

  // Add this property to the state class
  Set<String> _possibleMoves = {};

  // Add this flag to track resignation
  bool _isResigning = false;

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

  Future<void> _updateUserStatistics(String result) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      
      // Get current stats
      final userDoc = await userRef.get();
      final userData = userDoc.data() ?? {};
      
      // Update stats based on game result
      await userRef.update({
        'games_played': (userData['games_played'] ?? 0) + 1,
        'wins': (userData['wins'] ?? 0) + (result == 'win' ? 1 : 0),
        'losses': (userData['losses'] ?? 0) + (result == 'loss' ? 1 : 0),
        'draws': (userData['draws'] ?? 0) + (result == 'draw' ? 1 : 0),
      });
    } catch (e) {
      print('Error updating user statistics: $e');
    }
  }

  void _handleGameOver() {
    setState(() {
      _isGameOver = true;
      _winner = _whiteTime <= 0 ? 'Black' : 'White';
    });

    // Update user statistics
    final currentUserIsWhite = isWhite;
    final result = _winner == null ? 'draw' 
                  : (_winner == 'White' && currentUserIsWhite) || (_winner == 'Black' && !currentUserIsWhite)
                  ? 'win' 
                  : 'loss';
    
    _updateUserStatistics(result);
    
    _showGameOverDialog(_winner != null ? '$_winner wins!' : 'The game ended in a draw');
  }

  void _setupGame() {
    _gameService.listenToGame(widget.gameId).listen((snapshot) {
      if (!snapshot.exists) return;
      
      final data = snapshot.data() as Map<String, dynamic>;
      
      setState(() {
        // Update player names
        if (widget.isCreator) {
          _playerName = _auth.currentUser?.displayName ?? 'Anonymous';
          _opponentName = data['player2_name'] ?? 'Waiting...';
        } else {
          _playerName = _auth.currentUser?.displayName ?? 'Anonymous';
          _opponentName = data['player1_name'] ?? 'Opponent';
        }

        // Update times from Firestore
        _whiteTime = data['white_time'] ?? _whiteTime;
        _blackTime = data['black_time'] ?? _blackTime;

        // Update captured pieces from Firestore
        if (data['white_captured_pieces'] != null) {
          whiteCapturedPieces = List<String>.from(data['white_captured_pieces']);
        }
        if (data['black_captured_pieces'] != null) {
          blackCapturedPieces = List<String>.from(data['black_captured_pieces']);
        }
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
        // Only show game over dialog if we're not resigning
        if (data['game_over'] == true && !_isResigning) {
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
                // Trophy icon with glow effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 80.sp,
                    color: Colors.amber[400],
                  ),
                ),
                SizedBox(height: 24.h),
                // Game Over text
                Text(
                  'Game Over',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 16.h),
                // Winner message with larger text and special styling
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: Colors.amber[400],
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                // Single prominent back button
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameLobbyScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[700]!,
                          Colors.blue[600]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Return to Lobby',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        final winner = _controller.isCheckMate() 
            ? (isWhite ? 'White' : 'Black')
            : null;
            
        await _gameService.endGame(
          gameId: widget.gameId,
          winner: winner,
        );

        // Update user statistics
        final result = winner == null ? 'draw'
                      : (winner == 'White' && isWhite) || (winner == 'Black' && !isWhite)
                      ? 'win'
                      : 'loss';
        
        await _updateUserStatistics(result);
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
    // Only process if the move contains 'x' indicating a capture
    if (!move.contains('x')) return;

    print('Capture detected: $move'); // Debug print
    
    // Get the captured piece by comparing board states
    final beforePieces = boardStateBefore.split(' ')[0];
    final afterPieces = boardStateAfter.split(' ')[0];
    
    // Find the square where the piece was captured
    final targetSquare = move.substring(move.indexOf('x') + 1, move.indexOf('x') + 3);
    
    // Convert algebraic notation (e.g., 'e4') to board position
    final rank = '87654321'.indexOf(targetSquare[1]);
    final file = 'abcdefgh'.indexOf(targetSquare[0]);
    
    if (rank == -1 || file == -1) return;

    // Get the piece that was on that square before the capture
    String capturedPiece = 'p'; // default to pawn
    final beforeRows = beforePieces.split('/');
    if (rank < beforeRows.length) {
      String row = beforeRows[rank];
      int currentFile = 0;
      
      // Parse the FEN row to find the piece at the target square
      for (int i = 0; i < row.length && currentFile <= file; i++) {
        if (RegExp(r'[1-8]').hasMatch(row[i])) {
          currentFile += int.parse(row[i]);
        } else {
          if (currentFile == file) {
            capturedPiece = row[i];
            break;
          }
          currentFile++;
        }
      }
    }

    print('Captured piece: $capturedPiece'); // Debug print
    print('Board state before: $boardStateBefore'); // Debug print

    setState(() {
      // If it's white's turn in the before state, black made the capture
      final isWhiteTurn = boardStateBefore.split(' ')[1] == 'w';
      
      print('Is white turn: $isWhiteTurn'); // Debug print
      
      if (!isWhiteTurn) {
        // White captured a black piece (lowercase)
        print('White captured piece'); // Debug print
        whiteCapturedPieces.add(capturedPiece);
      } else {
        // Black captured a white piece (uppercase)
        print('Black captured piece'); // Debug print
        blackCapturedPieces.add(capturedPiece);
      }
    });

    print('White captured pieces: $whiteCapturedPieces'); // Debug print
    print('Black captured pieces: $blackCapturedPieces'); // Debug print

    // Update captured pieces in Firebase
    _gameService.updateCapturedPieces(
      gameId: widget.gameId,
      whiteCapturedPieces: whiteCapturedPieces,
      blackCapturedPieces: blackCapturedPieces,
    );
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
              const material.Color(0xFF0B1437),  // Deep navy
              const material.Color(0xFF1A237E),  // Rich indigo
              const material.Color(0xFF000B2C),  // Midnight blue
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: Column(
                  children: [
                    _buildPlayerInfo(false),
                    Expanded(child: _buildChessBoard()),
                    _buildPlayerInfo(true),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlowingIconButton(
            Icons.arrow_back_ios,
            () => _showResignDialog(),
          ),
          Column(
            children: [
              Text(
                'ELITE MATCH',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '10:00 BLITZ',
                  style: GoogleFonts.rajdhani(
                    color: Colors.amber,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          _buildGlowingIconButton(
            Icons.flag,
            () => _showResignDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: 20.sp,
            ),
          ),
        ),
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
              _buildMoveHistoryRow(isWhitePlayer),
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

  Widget _buildMoveHistoryRow(bool isWhitePlayer) {
    if (_moveHistory.isEmpty) {
      return Container(
        height: 40.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            'No moves yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    // Filter moves based on player color
    final playerMoves = _moveHistory.asMap().entries.where((entry) {
      final isWhiteMove = entry.key % 2 == 0;
      return isWhitePlayer ? isWhiteMove : !isWhiteMove;
    }).map((e) => e.value).toList();

    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              isWhitePlayer ? 'White moves: ' : 'Black moves: ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            ...playerMoves.map((move) => _buildMoveChip(move)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveChip(String move) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Text(
        move,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
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
      'P': '♟', 'p': '♟',
      'R': '♜', 'r': '♜',
      'N': '♞', 'n': '♞',
      'B': '♝', 'b': '♝',
      'Q': '♛', 'q': '♛',
      'K': '♚', 'k': '♚',
    };

    // Determine if the piece is white (uppercase) or black (lowercase)
    final isWhitePiece = piece.toUpperCase() == piece;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        pieceToUnicode[piece] ?? '',
        style: TextStyle(
          fontSize: 24.sp,
          color: isWhitePiece ? Colors.white : Colors.black,
          shadows: [
            Shadow(
              color: isWhitePiece ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
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
                  SizedBox(width: 4.w),
                  _buildDialogButton(
                    'Resign',
                    Icons.flag_rounded,
                    Colors.red,
                    () async {
                      // Set resigning flag
                      _isResigning = true;
                      
                      // Determine winner based on who resigned
                      final winner = isWhite ? 'Black' : 'White';
                      
                      // Update game state
                      await _gameService.endGame(
                        gameId: widget.gameId,
                        winner: winner,
                        gameOver: true,
                        reason: 'resignation',
                      );

                      // Update user statistics for resignation (counts as a loss)
                      await _updateUserStatistics('loss');

                      // Update local state
                      setState(() {
                        _isGameOver = true;
                        _winner = winner;
                      });

                      // Close resign dialog and navigate to game lobby
                      if (mounted) {
                        Navigator.of(context)
                          ..pop() // Close resign dialog
                          ..pop(); // Return to game lobby
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

  Widget _buildDialogButton(String text, IconData icon, MaterialColor color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
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
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }
} 