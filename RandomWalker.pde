// Simple Snake class - moves intelligently avoiding invalid directions
class RandomWalkerSnake extends Snake {
  RandomWalkerSnake(int x, int y) {
    super(x, y, "RandomWalker");
    updateInterval = 100;  // Standard speed
  }

  void think(ArrayList<Food> food, ArrayList<Snake> snakes) {
    // Current head position
    PVector head = segments.get(0);
    // Current direction
    PVector currentDir = direction;

    // Define all possible directions: right, left, down, up
    PVector[] possibleDirs = {
      new PVector(1, 0),   // Right
      new PVector(-1, 0),  // Left
      new PVector(0, 1),   // Down
      new PVector(0, -1)   // Up
    };

    // Store valid directions
    ArrayList<PVector> validDirs = new ArrayList<PVector>();

    // Check each direction
    for (PVector dir : possibleDirs) {
      // Calculate new position
      PVector newPos = new PVector(head.x + dir.x, head.y + dir.y);

      // Rule 1: No 180-degree turnaround (opposite of current direction)
      boolean isTurnaround = (dir.x == -currentDir.x && dir.y == -currentDir.y);
      if (isTurnaround) continue;

      // Rule 2: No wall collision
      if (checkWallCollision(newPos)) continue;

      // Rule 3: No snake collision (self or others)
      if (checkSnakeCollisions(newPos, snakes)) continue;

      // If all checks pass, this direction is valid
      validDirs.add(dir);
    }

    // Choose a new direction
    if (validDirs.size() > 0) {
      // Pick a random valid direction
      PVector newDir = validDirs.get((int)random(validDirs.size()));
      setDirection(newDir.x, newDir.y);
    } else {
      // Edge case: no valid direction (snake is trapped)
      // Keep moving in current direction (or could stop, depending on game rules)
      setDirection(currentDir.x, currentDir.y);
    }
  }
}
