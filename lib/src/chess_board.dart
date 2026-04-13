import 'dart:math';

import 'package:chess/chess.dart' hide State;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'board_arrow.dart';
import 'chess_board_controller.dart';
import 'constants.dart';

class ChessBoard extends StatefulWidget {
  final ChessBoardController controller;
  final double? size;
  final bool enableUserMoves;
  final BoardColor boardColor;
  final PlayerColor boardOrientation;
  final VoidCallback? onMove;
  final List<BoardArrow> arrows;

  const ChessBoard({
    Key? key,
    required this.controller,
    this.size,
    this.enableUserMoves = true,
    this.boardColor = BoardColor.brown,
    this.boardOrientation = PlayerColor.white,
    this.onMove,
    this.arrows = const [],
  }) : super(key: key);

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Chess>(
      valueListenable: widget.controller,
      builder: (context, game, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: _getBoardImage(widget.boardColor),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ 8;
                    final column = index % 8;

                    final boardRank = widget.boardOrientation == PlayerColor.black
                        ? '${row + 1}'
                        : '${(7 - row) + 1}';

                    final boardFile = widget.boardOrientation == PlayerColor.white
                        ? files[column]
                        : files[7 - column];

                    final squareName = '$boardFile$boardRank';
                    final pieceOnSquare = game.get(squareName);

                    final piece = BoardPiece(
                      squareName: squareName,
                      game: game,
                    );

                    final draggable = pieceOnSquare != null
                        ? Draggable<PieceMoveData>(
                      data: PieceMoveData(
                        squareName: squareName,
                        pieceType: pieceOnSquare.type.toUpperCase(),
                        pieceColor: pieceOnSquare.color,
                      ),
                      feedback: SizedBox(
                        width: widget.size != null ? widget.size! / 8 : 48,
                        height:
                        widget.size != null ? widget.size! / 8 : 48,
                        child: piece,
                      ),
                      childWhenDragging: const SizedBox(),
                      child: piece,
                    )
                        : Container();

                    final dragTarget = DragTarget<PieceMoveData>(
                      builder: (context, candidateData, rejectedData) {
                        return draggable;
                      },
                      onWillAccept: (pieceMoveData) {
                        return widget.enableUserMoves;
                      },
                      onAccept: (PieceMoveData pieceMoveData) async {
                        final moveColor = game.turn;

                        if (pieceMoveData.pieceType == "P" &&
                            ((pieceMoveData.squareName[1] == "7" &&
                                squareName[1] == "8" &&
                                pieceMoveData.pieceColor == Color.WHITE) ||
                                (pieceMoveData.squareName[1] == "2" &&
                                    squareName[1] == "1" &&
                                    pieceMoveData.pieceColor == Color.BLACK))) {
                          final val = await _promotionDialog(context);

                          if (val != null) {
                            widget.controller.makeMoveWithPromotion(
                              from: pieceMoveData.squareName,
                              to: squareName,
                              pieceToPromoteTo: val,
                            );
                          } else {
                            return;
                          }
                        } else {
                          widget.controller.makeMove(
                            from: pieceMoveData.squareName,
                            to: squareName,
                          );
                        }

                        if (game.turn != moveColor) {
                          widget.onMove?.call();
                        }
                      },
                    );

                    return dragTarget;
                  },
                  itemCount: 64,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
              if (widget.arrows.isNotEmpty)
                IgnorePointer(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      painter:
                      _ArrowPainter(widget.arrows, widget.boardOrientation),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _getBoardImage(BoardColor color) {
    final assetPath = _boardAssetPath(color);

    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        package: 'flutter_chess_board',
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      assetPath,
      package: 'flutter_chess_board',
      fit: BoxFit.cover,
    );
  }

  String _boardAssetPath(BoardColor color) {
    switch (color) {
      case BoardColor.brown:
        return 'assets/boards/board_brown.svg';
      case BoardColor.darkBrown:
        return 'assets/boards/board_dark_brown.svg';
      case BoardColor.green:
        return 'assets/boards/board_green.svg';
      case BoardColor.orange:
        return 'assets/boards/board_orange.svg';

      case BoardColor.tournamentGreen:
        return 'assets/boards/board_tournament_green.png';
      case BoardColor.walnut:
        return 'assets/boards/board_walnut.png';

      case BoardColor.tournamentWood:
        return 'assets/boards/board_tournament_wood.svg';
      case BoardColor.fritzBlue:
        return 'assets/boards/board_fritz_blue.svg';
      case BoardColor.tournamentBlue:
        return 'assets/boards/board_tournament_blue.svg';
    }
  }

  Future<String?> _promotionDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose promotion'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pop("q");
                },
                child: WhiteQueen(),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop("r");
                },
                child: WhiteRook(),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop("b");
                },
                child: WhiteBishop(),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop("n");
                },
                child: WhiteKnight(),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }
}

class BoardPiece extends StatelessWidget {
  final String squareName;
  final Chess game;

  const BoardPiece({
    Key? key,
    required this.squareName,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget imageToDisplay;
    final square = game.get(squareName);

    if (square == null) {
      return Container();
    }

    final piece =
        (square.color == Color.WHITE ? 'W' : 'B') + square.type.toUpperCase();

    switch (piece) {
      case "WP":
        imageToDisplay = WhitePawn();
        break;
      case "WR":
        imageToDisplay = WhiteRook();
        break;
      case "WN":
        imageToDisplay = WhiteKnight();
        break;
      case "WB":
        imageToDisplay = WhiteBishop();
        break;
      case "WQ":
        imageToDisplay = WhiteQueen();
        break;
      case "WK":
        imageToDisplay = WhiteKing();
        break;
      case "BP":
        imageToDisplay = BlackPawn();
        break;
      case "BR":
        imageToDisplay = BlackRook();
        break;
      case "BN":
        imageToDisplay = BlackKnight();
        break;
      case "BB":
        imageToDisplay = BlackBishop();
        break;
      case "BQ":
        imageToDisplay = BlackQueen();
        break;
      case "BK":
        imageToDisplay = BlackKing();
        break;
      default:
        imageToDisplay = WhitePawn();
    }

    return imageToDisplay;
  }
}

class PieceMoveData {
  final String squareName;
  final String pieceType;
  final Color pieceColor;

  PieceMoveData({
    required this.squareName,
    required this.pieceType,
    required this.pieceColor,
  });
}

class _ArrowPainter extends CustomPainter {
  final List<BoardArrow> arrows;
  final PlayerColor boardOrientation;

  _ArrowPainter(this.arrows, this.boardOrientation);

  @override
  void paint(Canvas canvas, Size size) {
    final blockSize = size.width / 8;
    final halfBlockSize = size.width / 16;

    for (final arrow in arrows) {
      final startFile = files.indexOf(arrow.from[0]);
      final startRank = int.parse(arrow.from[1]) - 1;
      final endFile = files.indexOf(arrow.to[0]);
      final endRank = int.parse(arrow.to[1]) - 1;

      int effectiveRowStart = 0;
      int effectiveColumnStart = 0;
      int effectiveRowEnd = 0;
      int effectiveColumnEnd = 0;

      if (boardOrientation == PlayerColor.black) {
        effectiveColumnStart = 7 - startFile;
        effectiveColumnEnd = 7 - endFile;
        effectiveRowStart = startRank;
        effectiveRowEnd = endRank;
      } else {
        effectiveColumnStart = startFile;
        effectiveColumnEnd = endFile;
        effectiveRowStart = 7 - startRank;
        effectiveRowEnd = 7 - endRank;
      }

      final startOffset = Offset(
        ((effectiveColumnStart + 1) * blockSize) - halfBlockSize,
        ((effectiveRowStart + 1) * blockSize) - halfBlockSize,
      );

      final endOffset = Offset(
        ((effectiveColumnEnd + 1) * blockSize) - halfBlockSize,
        ((effectiveRowEnd + 1) * blockSize) - halfBlockSize,
      );

      final yDist = 0.8 * (endOffset.dy - startOffset.dy);
      final xDist = 0.8 * (endOffset.dx - startOffset.dx);

      final paint = Paint()
        ..strokeWidth = halfBlockSize * 0.8
        ..color = arrow.color;

      canvas.drawLine(
        startOffset,
        Offset(startOffset.dx + xDist, startOffset.dy + yDist),
        paint,
      );

      final dx = endOffset.dx - startOffset.dx;
      final dy = endOffset.dy - startOffset.dy;

      if (dx == 0) {
        final points = _getNewPointsVertical(
          Offset(startOffset.dx + xDist, startOffset.dy + yDist),
          halfBlockSize,
        );

        final path = Path()
          ..moveTo(endOffset.dx, endOffset.dy)
          ..lineTo(points[0].dx, points[0].dy)
          ..lineTo(points[1].dx, points[1].dy)
          ..close();

        canvas.drawPath(path, paint);
        continue;
      }

      final slope = dy / dx;
      final newLineSlope = -1 / slope;

      final points = _getNewPoints(
        Offset(startOffset.dx + xDist, startOffset.dy + yDist),
        newLineSlope,
        halfBlockSize,
      );

      final newPoint1 = points[0];
      final newPoint2 = points[1];

      final path = Path()
        ..moveTo(endOffset.dx, endOffset.dy)
        ..lineTo(newPoint1.dx, newPoint1.dy)
        ..lineTo(newPoint2.dx, newPoint2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  List<Offset> _getNewPoints(Offset start, double slope, double length) {
    if (slope == double.infinity || slope == double.negativeInfinity) {
      return [
        Offset(start.dx, start.dy + length),
        Offset(start.dx, start.dy - length),
      ];
    }

    return [
      Offset(
        start.dx + (length / sqrt(1 + (slope * slope))),
        start.dy + ((length * slope) / sqrt(1 + (slope * slope))),
      ),
      Offset(
        start.dx - (length / sqrt(1 + (slope * slope))),
        start.dy - ((length * slope) / sqrt(1 + (slope * slope))),
      ),
    ];
  }

  List<Offset> _getNewPointsVertical(Offset start, double length) {
    return [
      Offset(start.dx, start.dy + length),
      Offset(start.dx, start.dy - length),
    ];
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return arrows != oldDelegate.arrows ||
        boardOrientation != oldDelegate.boardOrientation;
  }
}