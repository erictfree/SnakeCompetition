class GreedySnake extends Snake {
  GreedySnake(int x, int y) {
    super(x, y, "GREEDY");
  }

  void think(ArrayList<Food> food, ArrayList<Snake> snakes) {
    if (food.isEmpty()) return;
    
    // Find the food with the highest point value
    Food bestFood = null;
    float bestScore = -1;
    
    for (Food f : food) {
      if (f.points > bestScore) {
        bestScore = f.points;
        bestFood = f;
      }
    }
    
    if (bestFood == null) return;
    
    // Get current head position
    PVector head = segments.get(0);
    
    // Calculate direction to best food
    float dx = bestFood.x - head.x;
    float dy = bestFood.y - head.y;
    
    // Determine which direction to move based on the larger difference
    PVector newDirection = new PVector(0, 0);
    
    if (abs(dx) > abs(dy)) {
      // Move horizontally
      newDirection.x = dx > 0 ? 1 : -1;
    } else {
      // Move vertically
      newDirection.y = dy > 0 ? 1 : -1;
    }
    
    // Check if the new direction would cause a collision
    PVector nextPos = new PVector(
      head.x + newDirection.x,
      head.y + newDirection.y
    );
    
    // Only change direction if it's safe
    if (!checkWallCollision(nextPos) && !checkSnakeCollisions(nextPos, snakes)) {
      nextDirection = newDirection;
    }
  }
}
