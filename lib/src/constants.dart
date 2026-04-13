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

enum BoardPieceType { Pawn, Rook, Knight, Bishop, Queen, King }

RegExp squareRegex = RegExp("^[A-H|a-h][1-8]\$");