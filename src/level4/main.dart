import 'dart:io';

enum Type { MATTER, EMPTY, NOTHING, BORDER }

class Tile {
  Type type;
  int x;
  int y;
  int hits;

  Tile(this.type, this.x, this.y, {this.hits = 0});
}

enum Direction { LEFT, RIGHT, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT }

class Emitter {
  Direction direction;
  int x, y;
  bool activated;

  Emitter(this.direction, this.x, this.y, {this.activated = false});
}

class Grid {
  int radius;
  List<Tile> tiles;
  List<Turn> turns;

  // 6 emitters
  List<Emitter> emitters = [
    Emitter(Direction.RIGHT, 0, 0), // 1
    Emitter(Direction.BOTTOM_RIGHT, 0, 0), // 2
    Emitter(Direction.BOTTOM_LEFT, 0, 0),
    Emitter(Direction.LEFT, 0, 0),
    Emitter(Direction.TOP_LEFT, 0, 0),
    Emitter(Direction.TOP_RIGHT, 0, 0),
  ];

  Grid(this.radius, this.turns, this.tiles);

  void assignInitialPosition(Direction dir, int x, int y) {
    Emitter? emitter = emitters.firstWhere((e) => e.direction == dir);
    if (emitter != null) {
      emitter.x = x;
      emitter.y = y;
    }
  }

  void updatePosition(Direction dir, int relX, int relY) {
    Emitter? emitter = emitters.firstWhere((e) => e.direction == dir);
    if (emitter != null) {
      emitter.x += relX;
      emitter.y += relY;
    }
  }

  Emitter getEmitterByDir(Direction dir) {
    return emitters.firstWhere((e) => e.direction == dir);
  }
}

enum Instruction { NOTHING, CLOCKWISE, COUNTERCLOCKWISE, TOGGLE }

class Turn {
  List<Instruction> instructions = [];
}

void main() async {
  File file = File(
    "/home/corruptionhades/IdeaProjects/CodingContest2026/src/level4/files/level-4/in_level-4_2-large.txt",
  );
  String inFIleName = file.path.split("/").last;
  File outFile = File(file.parent.path + "${inFIleName}-out.txt");

  // clear out file
  outFile.writeAsStringSync("", mode: FileMode.write);

  String content = await file.readAsString();
  var lines = content.split("\n");

  int? numberOfGrids = int.tryParse(lines[0]);

  if (numberOfGrids == null) return;

  lines.removeAt(0);

  List<Grid> grids = [];

  String prevLines = "";
  for (var value in lines) {
    if (value.isEmpty) {
      var gridLines = prevLines.split("\n");

      if (gridLines.length <= 2) continue;

      int radius = int.tryParse(gridLines[0]) ?? 0;
      List<Tile> tiles = generateTiles(radius);

      gridLines.removeAt(0);
      // skip line 2 (instruction count)
      gridLines.removeAt(0);

      List<Turn> turns = [];
      for (String instructions in gridLines) {
        if (instructions.trim().isEmpty) continue;

        List<Instruction> instrs = [];
        for (int i = 0; i < instructions.length; i++) {
          switch (instructions[i]) {
            case "-":
              instrs.add(Instruction.NOTHING);
              break;
            case "F":
              instrs.add(Instruction.CLOCKWISE);
              break;
            case "B":
              instrs.add(Instruction.COUNTERCLOCKWISE);
              break;
            case "T":
              instrs.add(Instruction.TOGGLE);
              break;
          }
        }

        turns.add(Turn()..instructions = instrs);
      }

      Grid grid = Grid(radius, turns, tiles);

      initializeEmitterPositions(radius, grid, tiles);

      grids.add(grid);

      prevLines = "";
    } else {
      prevLines += value + "\n";
    }
  }

  for (Grid grid in grids) {
    for (Turn turn in grid.turns) {
      applyTurnTurn(grid, turn);

      for (var value in grid.emitters) {
        shootEmitter(grid, value);
      }

      applyMatter(grid);
    }

    String out = printTilesWithEmitter(grid);
    out += "\n";

    outFile.writeAsStringSync(out, mode: FileMode.append);
  }
}

void applyTurnTurn(Grid grid, Turn turn) {
  /*
  0 : 1 right
  1 : 2 bottom right
  2 : 3 bottom left
  ...
   */

  int radius = grid.radius;

  List<Tile> border = [];

  // upper-left edge: leftmost -> top-left
  for (int y = radius + 1; y >= 1; y--) {
    border.add(Tile(Type.BORDER, radius + 2 - y, y));
  }

  // top edge, without the top-left corner
  for (int x = radius + 3; x <= 3 * radius + 1; x += 2) {
    border.add(Tile(Type.BORDER, x, 1));
  }

  // upper-right edge, without the top-right corner
  for (int y = 2; y <= radius + 1; y++) {
    border.add(Tile(Type.BORDER, 3 * radius + y, y));
  }

  // lower-right edge, without the rightmost corner
  for (int y = radius + 2; y <= 2 * radius + 1; y++) {
    border.add(Tile(Type.BORDER, 5 * radius + 2 - y, y));
  }

  // bottom edge, without the bottom-right corner
  for (int x = 3 * radius - 1; x >= radius + 1; x -= 2) {
    border.add(Tile(Type.BORDER, x, 2 * radius + 1));
  }

  // lower-left edge, without the bottom-left and leftmost corners
  for (int y = 2 * radius; y >= radius + 2; y--) {
    border.add(Tile(Type.BORDER, y - radius, y));
  }

  for (int i = 0; i < 6; i++) {
    Emitter emitter = grid.emitters[i];
    Instruction inst = turn.instructions[i];

    switch (inst) {
      case Instruction.CLOCKWISE:
      case Instruction.COUNTERCLOCKWISE:
        {
          int index = border.indexWhere(
            (t) => t.x == emitter.x && t.y == emitter.y,
          );

          if (index == -1) break;

          int step = inst == Instruction.CLOCKWISE ? 1 : -1;
          Tile next = border[(index + step) % border.length];

          emitter.x = next.x;
          emitter.y = next.y;
          break;
        }
      case Instruction.TOGGLE:
        {
          emitter.activated = !emitter.activated;
          break;
        }
      case Instruction.NOTHING:
        {
          break;
        }
    }
  }
}

void shootEmitter(Grid grid, Emitter emitter) {
  if (!emitter.activated) return;

  int deltaX = 0;
  int deltaY = 0;

  switch (emitter.direction) {
    case Direction.RIGHT:
      deltaX = 1;
      break;
    case Direction.BOTTOM_RIGHT:
      deltaX = 1;
      deltaY = 1;
      break;
    case Direction.BOTTOM_LEFT:
      deltaX = -1;
      deltaY = 1;
      break;
    case Direction.LEFT:
      deltaX = -1;
      break;
    case Direction.TOP_LEFT:
      deltaX = -1;
      deltaY = -1;
      break;
    case Direction.TOP_RIGHT:
      deltaX = 1;
      deltaY = -1;
      break;
  }

  int width = 4 * grid.radius + 1;
  int height = 2 * grid.radius + 1;

  int currentX = emitter.x + deltaX;
  int currentY = emitter.y + deltaY;

  while (true) {
    if (currentX < 1 || currentX > width || currentY < 1 || currentY > height)
      break;

    Tile tile = grid.tiles[(currentY - 1) * width + (currentX - 1)];

    if (tile.type == Type.BORDER) break;

    if (tile.type == Type.EMPTY || tile.type == Type.MATTER) {
      tile.hits++;
    }

    currentX += deltaX;
    currentY += deltaY;
  }
}

void applyMatter(Grid grid) {
  for (Tile tile in grid.tiles) {
    if (tile.type == Type.EMPTY && tile.hits == 2) {
      tile.type = Type.MATTER;
    } else if (tile.type == Type.MATTER && tile.hits >= 3) {
      tile.type = Type.EMPTY;
    }

    // Hits only apply to the current turn
    tile.hits = 0;
  }
}

List<Tile> generateTiles(int radius) {
  List<Tile> tiles = [];

  int startMinuse = radius;

  for (int y = 1; y <= 2 * radius + 1; y++) {
    int x = 1;
    int normalized = startMinuse.abs();

    // leading indentation
    for (int i = 1; i <= normalized; i++) {
      tiles.add(Tile(Type.NOTHING, x++, y));
    }

    // row start border
    if (y != 1 && y != 2 * radius + 1) {
      tiles.add(Tile(Type.BORDER, x++, y));
      tiles.add(Tile(Type.NOTHING, x++, y));
    } else {
      tiles.add(Tile(Type.BORDER, x++, y));
    }

    // top and bottom border cells
    if (y == 1 || y == 2 * radius + 1) {
      for (int j = 1; j <= radius; j++) {
        tiles.add(Tile(Type.NOTHING, x++, y));
        tiles.add(Tile(Type.BORDER, x++, y));
      }
    }

    // empty cells and row end border
    if (y != 1 && y != 2 * radius + 1) {
      int anzahlNullen = 2 * radius - 1 - normalized;
      for (int k = 1; k <= anzahlNullen; k++) {
        tiles.add(Tile(Type.EMPTY, x++, y));
        tiles.add(Tile(Type.NOTHING, x++, y));
      }

      tiles.add(Tile(Type.BORDER, x++, y));
    }

    // trailing indentation
    for (int i = 1; i <= normalized; i++) {
      tiles.add(Tile(Type.NOTHING, x++, y));
    }

    startMinuse--;
  }

  return tiles;
}

String printTilesWithEmitter(Grid grid) {
  String out = "";

  for (
    int y = 1;
    y <= grid.tiles.map((t) => t.y).reduce((a, b) => a > b ? a : b);
    y++
  ) {
    for (
      int x = 1;
      x <= grid.tiles.map((t) => t.x).reduce((a, b) => a > b ? a : b);
      x++
    ) {
      Tile tile = grid.tiles.firstWhere(
        (t) => t.x == x && t.y == y,
        orElse: () => Tile(Type.NOTHING, x, y),
      );
      bool hasEmitter =
          false; // grid.emitters.any((e) => e.x == x && e.y == y);
      if (hasEmitter) {
        Emitter emitter = grid.emitters.firstWhere((e) => e.x == x && e.y == y);
        if (emitter.direction == Direction.RIGHT) {
          out += "1";
        } else if (emitter.direction == Direction.BOTTOM_RIGHT) {
          out += "2";
        } else if (emitter.direction == Direction.BOTTOM_LEFT) {
          out += "3";
        } else if (emitter.direction == Direction.LEFT) {
          out += "4";
        } else if (emitter.direction == Direction.TOP_LEFT) {
          out += "5";
        } else if (emitter.direction == Direction.TOP_RIGHT) {
          out += "6";
        }
      } else {
        switch (tile.type) {
          case Type.MATTER:
            out += "M";
            break;
          case Type.EMPTY:
            out += "O";
            break;
          case Type.NOTHING:
            out += "-";
            break;
          case Type.BORDER:
            out += "*";
            break;
        }
      }
    }
    out += "\n";
  }

  print(out);

  return out;
}

void initializeEmitterPositions(int radius, Grid grid, List<Tile> tiles) {
  grid.assignInitialPosition(Direction.RIGHT, 1, radius + 1);
  grid.assignInitialPosition(Direction.BOTTOM_RIGHT, radius + 1, 1);
  // width: 4n+1
  grid.assignInitialPosition(Direction.BOTTOM_LEFT, (3 * radius) + 1, 1);
  grid.assignInitialPosition(Direction.LEFT, 4 * radius + 1, radius + 1);
  grid.assignInitialPosition(
    Direction.TOP_LEFT,
    3 * radius + 1,
    2 * radius + 1,
  );
  grid.assignInitialPosition(Direction.TOP_RIGHT, radius + 1, 2 * radius + 1);
}
