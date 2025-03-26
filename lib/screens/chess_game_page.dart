import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material show Color;
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'dart:async';
import '../models/chess_game.dart';
import '../widgets/chess_board_widget.dart';
import 'dart:ui' show ImageFilter;
import '../models/chess_board_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ChessGamePage extends StatefulWidget {
  final int timeControl;
  final ChessBoardStyle boardStyle;
  final bool isBotMode;
  final bool playerIsWhite;
  
  const ChessGamePage({
    super.key,
    required this.timeControl,
    required this.boardStyle,
    this.isBotMode = false,
    this.playerIsWhite = true,
  });

  @override
  State<ChessGamePage> createState() => _ChessGamePageState();
}

class _ChessGamePageState extends State<ChessGamePage> with TickerProviderStateMixin {
  final ChessBoardController _controller = ChessBoardController();
  final ChessGame _game = ChessGame();
  String? selectedSquare;
  late int whiteTimeLeft;
  late int blackTimeLeft;
  Timer? _timer;
  bool isWhiteTurn = true;
  late AnimationController _fadeController;
  List<String> whiteCapturedPieces = [];
  List<String> blackCapturedPieces = [];
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    whiteTimeLeft = widget.timeControl * 60;
    blackTimeLeft = widget.timeControl * 60;
    startTimer();
    
    // Remove fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _game.setBotMode(widget.isBotMode);
    _game.setPlayerColor(widget.playerIsWhite);
    
    if (widget.isBotMode && !widget.playerIsWhite) {
      _makeBotMove();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (isWhiteTurn) {
          if (whiteTimeLeft > 0) {
            whiteTimeLeft--;
          } else {
            _timer?.cancel();
            showGameOverDialog('Black wins on time!');
          }
        } else {
          if (blackTimeLeft > 0) {
            blackTimeLeft--;
          } else {
            _timer?.cancel();
            showGameOverDialog('White wins on time!');
          }
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 0.8.sw, // Set maximum width
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
                Wrap( // Replace Row with Wrap
                  spacing: 16.w, // Add horizontal spacing between buttons
                  runSpacing: 16.h, // Add vertical spacing if buttons wrap
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
                          _game.reset();
                          _controller.loadFen(_game.getFen());
                          isWhiteTurn = true;
                          whiteCapturedPieces.clear();
                          blackCapturedPieces.clear();
                          whiteTimeLeft = widget.timeControl * 60;
                          blackTimeLeft = widget.timeControl * 60;
                          startTimer();
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

  void _handlePieceCapture(String piece) {
    setState(() {
      if (piece == 'clear') {
        whiteCapturedPieces.clear();
        blackCapturedPieces.clear();
      } else {
        if (piece.startsWith('w')) {
          blackCapturedPieces.add(piece);
        } else {
          whiteCapturedPieces.add(piece);
        }
      }
    });
  }

  Future<void> showPromotionDialog(String from, String to) async {
    final pieces = [
      {'piece': 'q', 'symbol': isWhiteTurn ? '♕' : '♛'},
      {'piece': 'r', 'symbol': isWhiteTurn ? '♖' : '♜'},
      {'piece': 'b', 'symbol': isWhiteTurn ? '♗' : '♝'},
      {'piece': 'n', 'symbol': isWhiteTurn ? '♘' : '♞'},
    ];

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.indigo[900],
          title: Text(
            'Choose Promotion Piece',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: pieces.map((p) => GestureDetector(
              onTap: () => Navigator.of(context).pop(p['piece']),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p['symbol']!,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            )).toList(),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _game.makePromotionMove(from, to, result);
        _controller.loadFen(_game.getFen());
        isWhiteTurn = !isWhiteTurn;
      });
    }
  }

  // Update handleBackButtonCaptures to use history
  void handleBackButtonCaptures() {
    final capturedPieces = _game.getCapturedPiecesUpToCurrentMove();
    
    whiteCapturedPieces = capturedPieces.where((piece) => piece[0] == 'b').toList();
    blackCapturedPieces = capturedPieces.where((piece) => piece[0] == 'w').toList();
  }

  // Update handleUndoCaptures to use history
  void handleUndoCaptures() {
    final capturedPieces = _game.getCapturedPiecesUpToCurrentMove();
    
    whiteCapturedPieces = capturedPieces.where((piece) => piece[0] == 'b').toList();
    blackCapturedPieces = capturedPieces.where((piece) => piece[0] == 'w').toList();
  }

  Future<void> _makeBotMove() async {
    // Add a small delay to make the bot move feel more natural
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Only make bot move if it's the bot's turn
    if ((widget.playerIsWhite && !isWhiteTurn) || (!widget.playerIsWhite && isWhiteTurn)) {
      final botMove = _game.getBotMove();
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
        
        if (mounted) {
          setState(() {
            if (moveMap['promotion'] != null) {
              _game.makePromotionMove(moveMap['from']!, moveMap['to']!, moveMap['promotion']!);
            } else {
              _game.makeMoveFromTo(moveMap['from']!, moveMap['to']!);
            }
            _controller.makeMove(
              from: moveMap['from']!,
              to: moveMap['to']!,
            );
            isWhiteTurn = !isWhiteTurn;
          });
        }
      }
    }
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {
        isWhiteTurn = _game.currentTurn == PlayerColor.white;
        selectedSquare = null;
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
              buildCustomAppBar(),
              Expanded(
                child: Column(
                  children: [
                    // Conditionally order player info based on orientation
                    if (_game.playerIsWhite) ...[
                      buildPlayerInfo(
                        isWhite: false,
                        timeLeft: blackTimeLeft,
                        isCurrentTurn: !isWhiteTurn,
                      ),
                      Expanded(
                        child: buildChessBoard(),
                      ),
                      buildPlayerInfo(
                        isWhite: true,
                        timeLeft: whiteTimeLeft,
                        isCurrentTurn: isWhiteTurn,
                      ),
                    ] else ...[
                      buildPlayerInfo(
                        isWhite: true,
                        timeLeft: whiteTimeLeft,
                        isCurrentTurn: isWhiteTurn,
                      ),
                      Expanded(
                        child: buildChessBoard(),
                      ),
                      buildPlayerInfo(
                        isWhite: false,
                        timeLeft: blackTimeLeft,
                        isCurrentTurn: !isWhiteTurn,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChessBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth > constraints.maxHeight 
            ? constraints.maxHeight 
            : constraints.maxWidth;
        
        return ChessBoardWidget(
          controller: _controller,
          game: _game,
          boardSize: boardSize,
          selectedSquare: selectedSquare,
          onSquareSelected: (square) {
            setState(() {
              selectedSquare = square;
            });
          },
          onGameStateChanged: _onGameStateChanged,
          onPieceCapture: _handlePieceCapture,
          onMove: (from, to) async {
            if (_game.isPawnPromotion(from, to)) {
              await showPromotionDialog(from, to);
            }
          },
          boardColor: widget.boardStyle == ChessBoardStyle.brown ? BoardColor.brown :
                      widget.boardStyle == ChessBoardStyle.green ? BoardColor.green :
                      widget.boardStyle == ChessBoardStyle.darkBrown ? BoardColor.darkBrown :
                      widget.boardStyle == ChessBoardStyle.orange ? BoardColor.orange :
                      BoardColor.brown,
        );
      },
    );
  }

  Widget buildCustomAppBar() {
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
            onPressed: () {
              print('back button pressed');
              setState(() {
                handleBackButtonCaptures();
              });
              //create dialog box to confirm if user wants to go back
              showDialog(
                context: context,
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
                        borderRadius: BorderRadius.circular(0.r),
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
                            size: 48.sp,
                            color: Colors.amber[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Exit Game?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Are you sure you want to leave the current game? Your progress will be lost.',
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
                                'Leave',
                                Icons.exit_to_app_rounded,
                                Colors.red,
                                () => Navigator.of(context)
                                  ..pop()
                                  ..pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Column(
            children: [
              Text(
                '${widget.timeControl} Min Game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Classical Chess',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          buildGameControls(),
        ],
      ),
    );
  }

  Widget buildGameControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          buildControlButton(
            icon: Icons.arrow_back,
            onPressed: _game.canUndo() ? () {
              setState(() {
                _game.undo();
                _controller.loadFen(_game.getFen());
                isWhiteTurn = !isWhiteTurn;
                handleUndoCaptures();
              });
            } : null,
          ),
          buildControlButton(
            icon: Icons.arrow_forward,
            onPressed: _game.canRedo() ? () {
              setState(() {
                _game.redo();
                _controller.loadFen(_game.getFen());
                isWhiteTurn = !isWhiteTurn;
              });
            } : null,
          ),
          buildControlButton(
            icon: Icons.replay,
            onPressed: () {
              setState(() {
                _game.reset();
                _controller.loadFen(_game.getFen());
                isWhiteTurn = true;
                whiteCapturedPieces.clear();
                blackCapturedPieces.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8.r),
        child: Icon(
          icon,
          color: onPressed != null 
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.3),
          size: 20.sp,
        ),
      ),
    );
  }

  Widget buildPlayerInfo({
    required bool isWhite,
    required int timeLeft,
    required bool isCurrentTurn,
  }) {
    return Transform.rotate(
      angle: isWhite == _game.playerIsWhite ? 0 : pi,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final glowOpacity = isCurrentTurn ? 
              0.3 + (0.2 * _pulseController.value) : 
              0.0;
              
          return Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isCurrentTurn 
                        ? Colors.blue.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isCurrentTurn 
                          ? Colors.blue.withOpacity(0.5) 
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: isCurrentTurn ? [
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
                              backgroundColor: isWhite ? Colors.white : Colors.black,
                              child: Icon(
                                Icons.person,
                                size: 20.sp,
                                color: isWhite ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWhite ? 'White' : 'Black',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16.sp,
                                  fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (isCurrentTurn)
                                Text(
                                  'Your turn',
                                  style: TextStyle(
                                    color: Colors.blue.withOpacity(0.9),
                                    fontSize: 12.sp,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                        child: buildTimer(timeLeft, isCurrentTurn),
                      ),
                    ],
                  ),
                ),
                buildCapturedPieces(isWhite),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTimer(int timeLeft, bool isCurrentTurn) {
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
        formatTime(timeLeft),
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

  Widget buildCapturedPieces(bool isWhite) {
    final pieces = isWhite ? whiteCapturedPieces : blackCapturedPieces;
    
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
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
          : pieces.map((piece) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Text(
                  _getPieceSymbol(piece),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getPieceSymbol(String piece) {
    final Map<String, String> symbols = {
      'wp': '♙', 'wr': '♖', 'wn': '♘', 'wb': '♗', 'wq': '♕', 'wk': '♔',
      'bp': '♟', 'br': '♜', 'bn': '♞', 'bb': '♝', 'bq': '♛', 'bk': '♚',
    };
    return symbols[piece] ?? '';
  }
}

// Place StarFieldPainter here, at the same level as _ChessGamePageState
class StarFieldPainter extends CustomPainter {
  final Animation<double> animation;
  
  StarFieldPainter({required this.animation}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = Random(42);
    
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (animation.value * random.nextDouble()).clamp(0.1, 0.5);
      final starSize = random.nextDouble() * 2;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
} 