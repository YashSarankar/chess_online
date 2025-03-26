import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chess/chess.dart' as chess;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chess Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChessGamePage(),
    );
  }
}

class ChessGamePage extends StatefulWidget {
  const ChessGamePage({super.key});

  @override
  State<ChessGamePage> createState() => _ChessGamePageState();
}

class _ChessGamePageState extends State<ChessGamePage> {
  final ChessBoardController _controller = ChessBoardController();
  final chess.Chess _chess = chess.Chess();
  PlayerColor currentTurn = PlayerColor.white;
  String? selectedSquare;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Chess Game'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use the smaller of width or height to ensure square board
            final boardSize = constraints.maxWidth > constraints.maxHeight 
                ? constraints.maxHeight 
                : constraints.maxWidth;
            final squareSize = boardSize / 8;
            
            return SizedBox(
              width: boardSize,
              height: boardSize,
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localPosition = box.globalToLocal(details.globalPosition);
                      final String tappedSquare = _getSquareFromPosition(localPosition, squareSize);

                      setState(() {
                        if (selectedSquare == tappedSquare) {
                          selectedSquare = null;
                        } else {
                          selectedSquare = tappedSquare;
                        }
                      });
                    },
                    child: ChessBoard(
                      controller: _controller,
                      boardColor: BoardColor.brown,
                      boardOrientation: PlayerColor.white,
                      enableUserMoves: true,
                      onMove: () {
                        final move = _controller.getSan();
                        print('Move made: $move');
                        
                        // Make the move in our chess logic
                        try {
                          _chess.move(move);
                          
                          // Check game state
                          if (_chess.in_checkmate) {
                            final winColor = currentTurn == PlayerColor.white ? 'Black' : 'White';
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Game Over'),
                                content: Text('Checkmate! $winColor wins!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resetGame();
                                    },
                                    child: Text('New Game'),
                                  ),
                                ],
                              ),
                            );
                          } else if (_chess.in_draw) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Game Over'),
                                content: Text('Draw!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resetGame();
                                    },
                                    child: Text('New Game'),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          // Toggle the turn after each move
                          setState(() {
                            currentTurn = currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
                            selectedSquare = null; // Reset selection after move
                          });
                        } catch (e) {
                          print('Invalid move: $e');
                        }
                      },
                    ),
                  ),
                  if (selectedSquare != null)
                    ..._highlightLegalMoves(selectedSquare!, squareSize),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _chess.reset();
      _controller.resetBoard();
      currentTurn = PlayerColor.white;
      selectedSquare = null;
    });
  }

  String _getSquareFromPosition(Offset position, double squareSize) {
    int file = (position.dx / squareSize).floor();
    int rank = 7 - (position.dy / squareSize).floor();
    
    String fileStr = String.fromCharCode('a'.codeUnitAt(0) + file);
    String rankStr = (rank + 1).toString();
    
    return '$fileStr$rankStr';
  }

  List<Widget> _highlightLegalMoves(String square, double squareSize) {
    List<String> legalMoves = _calculateLegalMoves(square);

    return legalMoves.map((move) {
      final file = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
      final rank = 7 - (int.parse(move[1]) - 1);

      return Positioned(
        left: file * squareSize + (squareSize / 2) - 10,
        top: rank * squareSize + (squareSize / 2) - 10,
        child: GestureDetector(
          onTap: () {
            try {
              _chess.move({'from': selectedSquare!, 'to': move});
              _controller.makeMove(from: selectedSquare!, to: move);
              
              setState(() {
                currentTurn = currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
                selectedSquare = null;
              });
            } catch (e) {
              print('Invalid move: $e');
            }
          },
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
    }).toList();
  }

  List<String> _calculateLegalMoves(String square) {
    List<String> destinations = [];
    var moves = _chess.moves({
      'square': square,
      'verbose': true
    });

    for (var move in moves) {
      if (move is Map) {
        destinations.add(move['to']);
      }
    }
    return destinations;
  }
}
