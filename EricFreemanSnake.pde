// Simple Snake class - moves randomly with no collision checks
class EricFreemanSnake extends Snake {
  EricFreemanSnake(int x, int y) {
    super(x, y, "EricFreeman");
    updateInterval = 100;  // Standard speed
  }

  void think(ArrayList<Food> food, ArrayList<Snake> snakes) {
    // Define all possible directions: right, left, down, up
    PVector[] possibleDirs = {
      new PVector(1, 0),   // Right
      new PVector(-1, 0),  // Left
      new PVector(0, 1),   // Down
      new PVector(0, -1)   // Up
    };

    // Pick a random direction from all possibilities
    PVector newDir = possibleDirs[(int)random(possibleDirs.length)];
    setDirection(newDir.x, newDir.y);
  }
}
