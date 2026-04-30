const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

enum BoardColor {
  brown,
  darkBrown,
  orange,
  green,
  tournament,
  walnut,
  wood,
  blue,
  purple,
}

enum PlayerColor {
  white,
  black,
}

enum BoardPieceType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}

final RegExp squareRegex = RegExp(r'^[A-Ha-h][1-8]$');