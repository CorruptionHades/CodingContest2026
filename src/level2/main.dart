import 'dart:io';

class GridInfo {
  final String contents;

  GridInfo(this.contents);

  List<String> contentsList() {
    return contents.split("\n").where((element) => element.isNotEmpty).toList();
  }
}

class Tile {
  final int x, y;
  Type type;
  final int dir;

  Tile(this.x, this.y, this.type, this.dir);
}

enum Type {
  MINUS, STAR, O, DIRECTION, MATTER
}

class Grid {
  final List<Tile> tiles;

  Grid(this.tiles);


}


void main() async {
 // File file = File("/home/corruptionhades/IdeaProjects/CodingContest2026/src/level2/files/level-2/in_level-2_0-example.txt");
 // File file = File("/home/corruptionhades/IdeaProjects/CodingContest2026/src/level2/files/level-2/in_level-2_1-small.txt");
  File file = File("/home/corruptionhades/IdeaProjects/CodingContest2026/src/level2/files/level-2/in_level-2_2-large.txt");
  String inFIleName = file.path.split("/").last;
  File outFile = File(file.parent.path + "${inFIleName}-out.txt");

  // clear out file
  outFile.writeAsStringSync("", mode: FileMode.write);

  String content = await file.readAsString();
  var lines = content.split("\n");

  int? numberOfGrids = int.tryParse(lines[0]);

  if(numberOfGrids == null) return;

  lines.removeAt(0);

  List<GridInfo> gridInfos = [];

  String prevLines = "";
  for (var value in lines) {
    if(value.isEmpty) {
      gridInfos.add(GridInfo(prevLines.trim()));
      prevLines = "";
    }
    else {
      prevLines += value + "\n";
    }
  }

  print("---");
  print("gridinfos::");
  for (var gridinfo in gridInfos) {
    print("---");
    print(gridinfo.contents);
    print("---");

    var contentList = gridinfo.contentsList();

    if(contentList.isEmpty) continue;

    String gridInfo = contentList.first;
    int radius = int.tryParse(gridInfo.split(" ")[0])!;
    int rows = int.tryParse(gridInfo.split(" ")[1])!;
    int columns = int.tryParse(gridInfo.split(" ")[2])!;

    contentList.removeAt(0);

    List<Tile> tiles = [];

    for(int y = 1; y <= rows; y++) {

      String row = contentList[y - 1];

      // go through each
      // ----*-*-*-*-*----
      for (int x = 1; x <= columns; x++) {

        int direction = 0;
        String char = row[x - 1];
        Type type;
        switch(char) {
          case "-":
            type = Type.MINUS;
            break;
          case "*":
            type = Type.STAR;
            break;
          case "O":
            type = Type.O;
            break;
          default: {
              direction = int.tryParse(char) ?? 0;
              type = Type.DIRECTION;
          }
        }

        tiles.add(Tile(x, y, type, direction));
      }


    }

  //  printTiles(tiles);

    // direction types
    for (var tile in tiles) {
      if(tile.type == Type.DIRECTION) {
        int direction = tile.dir;

        int currentX = tile.x;
        int currentY = tile.y;

        switch(direction) {
          case 1: {
            // right

            // get all tiles to teh right of this tile which are Type.O

            List<Tile> candidates = tiles.map((e) => e)
                .where((element) => element.y == tile.y && element.x > tile.x && element.type == Type.O)
                .toList();

            // set candidate type to M
            for (var candidate in candidates) {
              candidate.type = Type.MATTER;
            }
          }
          case 2: {
            // bottom right in a line
            while (true) {
              currentX++;
              currentY++;

              try {
                Tile? candidate = tiles.firstWhere((element) => element.x == currentX && element.y == currentY);
                if(candidate != null) {
                  if(candidate.type == Type.O) {
                    candidate.type = Type.MATTER;
                  }
                  else if(candidate.type == Type.STAR) break;
                } else {
                  break;
                }
              }
              catch(e) {
                break;
              }
            }
          }
          case 3: {
            // bottom left in a line

            while (true) {
              currentX--;
              currentY++;

              try {
                Tile? candidate = tiles.firstWhere((element) => element.x == currentX && element.y == currentY);
                if(candidate != null) {

                  if(candidate.type == Type.O) {
                    candidate.type = Type.MATTER;
                  }
                  else if(candidate.type == Type.STAR) break;


                } else {
                  break;
                }
              } on Exception catch (e) {
                break;
              }
            }
          }
          case 4: {
            // left

            List<Tile> candidates = tiles.map((e) => e)
                .where((element) => element.y == tile.y && element.x < tile.x && element.type == Type.O)
                .toList();

            for (var candidate in candidates) {
              candidate.type = Type.MATTER;
            }
          }
          case 5: {
            // top left in a line

            while (true) {
              currentX--;
              currentY--;

              try {
                Tile? candidate = tiles.firstWhere((element) => element.x == currentX && element.y == currentY);
                if(candidate != null) {
                  if(candidate.type == Type.O) {
                    candidate.type = Type.MATTER;
                  }
                  else if(candidate.type == Type.STAR) break;
                } else {
                  break;
                }
              }
              on Exception catch (e) {
                break;
              }
            }
          }
          case 6: {
            // top right in a line

            while (true) {
              currentX++;
              currentY--;

              try {
                Tile? candidate = tiles.firstWhere((element) => element.x == currentX && element.y == currentY);
                if(candidate != null) {
                  if(candidate.type == Type.O) {
                    candidate.type = Type.MATTER;
                  }
                  else if(candidate.type == Type.STAR) break;
                } else {
                  break;
                }
              } on Exception catch (e) {
                break;
              }
            }
          }
        }


      }
    }

    printTiles(tiles);

    outFile.writeAsStringSync(tilesToString(tiles), mode: FileMode.append);
    outFile.writeAsStringSync("\n", mode: FileMode.append);
  }
}

String tilesToString(List<Tile> tiles) {
  String s = "";

  for(int y = 1; y <= tiles.map((e) => e.y).reduce((value, element) => value > element ? value : element); y++) {
    for (int x = 1; x <= tiles.map((e) => e.x).reduce((value, element) => value > element ? value : element); x++) {
      Tile? tile = tiles.firstWhere((element) => element.x == x && element.y == y);
      if(tile == null) {
        s += " ";
      } else {
        switch(tile.type) {
          case Type.MINUS:
            s += "-";
            break;
          case Type.STAR:
            s += "*";
            break;
          case Type.O:
            s += "O";
            break;
          case Type.DIRECTION:
            s += tile.dir.toString();
            break;
          case Type.MATTER:
            s += "M";
            break;
        }
      }
    }
    s += "\n";
  }
  return s;
}

void printTiles(List<Tile> tiles) {
  // print as xy grid
  int maxX = tiles.map((e) => e.x).reduce((value, element) => value > element ? value : element);
  int maxY = tiles.map((e) => e.y).reduce((value, element) => value > element ? value : element);

  for(int y = 1; y <= maxY; y++) {
    String row = "";
    for(int x = 1; x <= maxX; x++) {
      Tile? tile = tiles.firstWhere((element) => element.x == x && element.y == y);
      if(tile == null) {
        row += " ";
      } else {
        switch(tile.type) {
          case Type.MINUS:
            row += "-";
            break;
          case Type.STAR:
            row += "*";
            break;
          case Type.O:
            row += "O";
            break;
          case Type.DIRECTION:
            row += tile.dir.toString();
            break;
          case Type.MATTER:
            row += "M";
            break;
        }
      }
    }
    print(row);
  }
}