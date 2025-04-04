// Food class
class Food {
  int x, y;
  float pulsePhase;
  int points = 1;
  color foodColor;  // Color of the food
  float pulseSize = 0;
  float pulseSpeed = 0.1;
  float pulseOffset = random(TWO_PI);

  Food(int x, int y) {
    this(x, y, 1);  // Default to 1 point
  }

  Food(int x, int y, int points) {
    this.x = x;
    this.y = y;
    this.pulsePhase = random(0, TWO_PI); // Random start phase for pulsing
    this.foodColor = color(255, 255, 0);  // Default yellow color
    this.points = points;
  }



  void draw() {
    // Pulse size for visual interest
    float pulse = sin(frameCount * 0.1 + pulsePhase) * 2;
    float size = 10 - 4 + pulse;

    // Draw food with glow effect
    pushMatrix();
    noStroke();

    // Outer glow - use a darker version of the food's color
    color glowColor = lerpColor(foodColor, color(0), 0.7);  // Darken the food color by 70%
    fill(red(glowColor), green(glowColor), blue(glowColor), 100);  // Add transparency

    circle(x * GRIDSIZE + GRIDSIZE / 2,
      y * GRIDSIZE + GRIDSIZE / 2,
      size + 6);

    // Inner circle
    fill(foodColor);
    
    if (this.points > 1) {
      fill(255, 255, 255);
    }
    
    circle(x * GRIDSIZE + GRIDSIZE / 2,
      y * GRIDSIZE + GRIDSIZE / 2,
      size);
    popMatrix();
  }

  Food spawnRandom(int width, int height, ArrayList<Snake> snakes, ArrayList<Food> existingFood) {
    int gridWidth = floor(width / GRIDSIZE);
    int gridHeight = floor(height / GRIDSIZE);
    int x, y;
    int attempts = 0;
    final int maxAttempts = 100;

    do {
      x = floor(random(gridWidth));
      y = floor(random(gridHeight));
      attempts++;

      // Check if position is occupied by a snake
      boolean occupied = false;
      for (Snake snake : snakes) {
        for (PVector segment : snake.segments) {
          if (segment.x == x && segment.y == y) {
            occupied = true;
            break;
          }
        }
        if (occupied) break;
      }

      // Check if position is occupied by existing food
      if (!occupied) {
        for (Food f : existingFood) {
          if (f.x == x && f.y == y) {
            occupied = true;
            break;
          }
        }
      }

      if (!occupied) {
        return new Food(x, y, this.points);
      }
    } while (attempts < maxAttempts);

    // If we couldn't find a spot after max attempts, try again with a new random position
    if (attempts >= maxAttempts) {
      return spawnRandom(width, height, snakes, existingFood);
    }

    return null; // This should never be reached
  }
}
