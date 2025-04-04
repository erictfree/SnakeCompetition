
// Simple Snake class - just moves around randomly
class EricFreemanSnake extends Snake {
  EricFreemanSnake(int x, int y) {
    super(x, y, "EricFreeman");
    updateInterval = 100;  // Standard speed
  }

  void think(ArrayList<Food> food, ArrayList<Snake> snakes) {
    // Just randomly choose a direction
    float rand = random(1);
    float dx = 0, dy = 0;

    if (rand < 0.25) {
      dx = 1;  // Right
    } else if (rand < 0.5) {
      dx = -1; // Left
    } else if (rand < 0.75) {
      dy = 1;  // Down
    } else {
      dy = -1; // Up
    }

    // Only set direction if it won't cause a collision
    PVector newPos = new PVector(
      segments.get(0).x + dx,
      segments.get(0).y + dy
      );

    if (!checkWallCollision(newPos) && !checkSnakeCollisions(newPos, snakes)) {
      setDirection(dx, dy);
    }
  }
}
