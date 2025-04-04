// Base Snake class
abstract class Snake {
  // ============= Properties =============
  // Core properties
  ArrayList<PVector> segments;  // Snake body segments
  String name;                  // Snake's name
  color snakeColor;             // Snake's color
  boolean alive;                // Whether the snake is alive
  int score;                    // Current score (length)
  int creationTime;             // When the snake was created

  // Movement properties
  PVector direction;            // Current movement direction
  PVector nextDirection;        // Next direction to move
  int lastUpdate;               // Last update time
  int updateInterval;           // Time between updates (speed)

  // Grid properties
  int gridSize;                 // Size of each grid cell

  // ============= Appearance Properties =============
  boolean showName;             // Whether to show the snake's name
  float nameOffset;             // How far above the snake the name appears
  boolean debug;                // Whether to show debug visualization
  float maxMult;

  // ============= Constructor =============
  /**
   * Creates a new snake at the specified position
   * @param x Starting X position
   * @param y Starting Y position
   * @param name Snake's name
   */
  Snake(int x, int y, String name) {
    // Initialize core properties
    this.name = name;//generateSillyName();//name;
    this.snakeColor = ARCADE_COLORS[colorIndex++];
    this.alive = true;
    this.score = 1;
    this.creationTime = millis();

    // Initialize movement properties
    this.direction = new PVector(1, 0);  // Start moving right
    this.nextDirection = null;
    this.lastUpdate = 0;
    this.updateInterval = 100;  // Default speed

    // Initialize grid properties
    this.gridSize = 20;

    // Initialize appearance properties
    showName = true;
    nameOffset = 5;
    debug = false;
    maxMult = 1;

    // Create snake segments array and head
    segments = new ArrayList<PVector>();
    segments.add(new PVector(x, y));  // Snake head at index 0
  }

  // ============= Public Methods =============

  /**
   * Draws the snake on screen
   */
  void draw() {
    if (!alive) return;
    if (debug) {
      drawDebug();
    }
    drawBody();
    drawName();
  }

  /**
   * To be implemented by subclasses to define AI behavior
   */
   abstract void think(ArrayList<Food> food, ArrayList<Snake> snakes);

void drawBody() {
    float sizeMultiplier = map(score, 1, 50, 1, maxMult);
    float segmentSize = gridSize * sizeMultiplier;
    float gap = 2 * sizeMultiplier;
    float offset = (segmentSize - (gridSize - 1)) / 2;

    stroke(snakeColor);
    strokeWeight(1);
    for (int i = segments.size() - 1; i >= 0; i--) {
      PVector segment = segments.get(i);

      color segmentColor = (i == 0) ?
        lerpColor(snakeColor, color(255), .2) :
        lerpColor(snakeColor, color(0), i % 2 * .08);
      fill(segmentColor);
      
      float s = segmentSize - gap;
      // Draw segment
      rect(
        segment.x * gridSize - offset + gap / 2,
        segment.y * gridSize - offset + gap / 2,
        s,
        s,
        5  // Fixed roundness
        );
    }
  }

void drawName() {
    if (!showName) return;

    float sizeMultiplier = map(score, 1, 50, 1, maxMult);
    float offset = ((gridSize - 1) * sizeMultiplier - (gridSize - 1)) / 2;

    fill(255);
    textAlign(CENTER);
    textSize(12);
    text(name,
      segments.get(0).x * gridSize + gridSize / 2,
      segments.get(0).y * gridSize - nameOffset - offset);
  }

  private void drawDebug() {
    // Draw debug circle around the snake
    PVector head = segments.get(0);
    float sizeMultiplier = map(score, 1, 50, 1, maxMult);
    float segmentSize = (gridSize - 1) * sizeMultiplier;
    float offset = (segmentSize - (gridSize - 1)) / 2;

    stroke(255, 140);
    strokeWeight(.5);
    fill(255, 80);  // Semi-transparent red

    circle(
      head.x * gridSize + gridSize / 2,
      head.y * gridSize + gridSize / 2,
      gridSize * 15
      );
  }


  // ============= Utiities ====================
  /**
   * Checks if a position would collide with walls
   * @param pos Position to check
   * @return true if collision would occur
   */
  boolean checkWallCollision(PVector pos) {
    int w = floor(width / gridSize);
    int h = floor(height / gridSize);
    return pos.x < 0 || pos.x >= w || pos.y < 0 || pos.y >= h;
  }

  /**
   * Checks if a position would collide with any snake
   * @param pos Position to check
   * @param snakes List of all snakes
   * @return true if collision would occur
   */
  boolean checkSnakeCollisions(PVector pos, ArrayList<Snake> snakes) {
    // Check collision with self
    for (PVector segment : segments) {
      if (pos.x == segment.x && pos.y == segment.y) {
        return true;
      }
    }

    // Check collision with other snakes
    for (Snake snake : snakes) {
      if (snake == this) continue;
      for (PVector segment : snake.segments) {
        if (pos.x == segment.x && pos.y == segment.y) {
          return true;
        }
      }
    }
    return false;
  }


  // ============= Private Methods =============

  /**
   * Updates the snake's position and checks for collisions
   * @param food List of food items
   * @param snakes List of all snakes
   * @param time Current time in milliseconds
   */
  void update(ArrayList<Food> food, ArrayList<Snake> snakes, int time) {
    if (!alive) return;
    if (time - lastUpdate < updateInterval) return;
    lastUpdate = time;

    // Think about next move (to be implemented by subclasses)
    think(food, snakes);

    // Apply buffered direction change
    if (nextDirection != null) {
      direction = nextDirection.copy();
      nextDirection = null;
    }

    // Move snake
    move();

    // Check for food
    checkFood(food);
  }

  private void move() {
    PVector head = segments.get(0);
    PVector newHead = new PVector(
      head.x + direction.x,
      head.y + direction.y
      );

    // Check for collisions
    if (checkWallCollision(newHead)) {
      die();
      return;
    }

    // Check for snake collisions and create animation if collision occurs
    if (checkSnakeCollisions(newHead, snakes)) {
      // Create collision animation at the point of impact
      float animX = newHead.x * gridSize + gridSize / 2;
      float animY = newHead.y * gridSize + gridSize / 2;
      collisionAnimations.add(new CollisionAnimation(animX, animY, snakeColor));
      die();
      return;
    }

    // Add new head
    segments.add(0, newHead);

    // Remove tail if no food was eaten
    if (!ateFood) {
      segments.remove(segments.size() - 1);
    }
  }

  /**
   * Changes the snake's direction
   * @param dx X direction (-1, 0, or 1)
   * @param dy Y direction (-1, 0, or 1)
   */
  void setDirection(float dx, float dy) {
    // Prevent 180-degree turns
    if (direction.x != -dx || direction.y != -dy) {
      nextDirection = new PVector(dx, dy);
    }
  }

  /**
   * Returns whether the snake is alive
   * @return true if snake is alive, false otherwise
   */
  boolean isAlive() {
    return alive;
  }

  /**
   * Returns the snake's current score
   * @return Current score
   */
  int getScore() {
    return score;
  }

  /**
   * Returns the snake's name
   * @return Snake's name
   */
  String getName() {
    return name;
  }

  /**
   * Returns the snake's color
   * @return Snake's color
   */
  color getColor() {
    return snakeColor;
  }


  private boolean ateFood = false;
  private void checkFood(ArrayList<Food> food) {
    ateFood = false;
    for (int i = food.size() - 1; i >= 0; i--) {
      Food f = food.get(i);
      if (f.x == segments.get(0).x && f.y == segments.get(0).y) {
        food.remove(i);
        score+= f.points;
        ateFood = true;
        break;
      }
    }
  }

  /**
   * Called when the snake dies, converts segments to food
   * @return List of positions where food should be created
   */
  ArrayList<PVector> die() {
    alive = false;
    // Convert every other segment to food, starting from the head
    // Only take up to 10 segments from the head
    ArrayList<PVector> foodPositions = new ArrayList<PVector>();
    int endIndex = min(10, segments.size() - 1);  // Take up to 10 segments from head
    for (int i = 1; i <= endIndex; i += 2) {  // Skip head (index 0) and take every other segment
      foodPositions.add(segments.get(i).copy());
    }
    return foodPositions;
  }
}
