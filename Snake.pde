// Base Snake class
abstract class Snake {
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
  float nameOffset;             // How far above the snake the name appears
  float maxMult;
  
  boolean showName;             // Whether to show the snake's name

  boolean debug = false;
  boolean speedMeter = false;

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
    maxMult = 1;

    // Create snake segments array and head
    segments = new ArrayList<PVector>();
    segments.add(new PVector(x, y));  // Snake head at index 0
  }

  /**
   * Draws the snake on screen
   */
  void draw() {
    if (!alive) return;
    if (debug) {
      drawDebug();
    }
    if (speedMeter) {
      drawSpeedMeter();
    }
    drawBody();
    drawName();
  }

  /**
   * To be implemented by subclasses to define behavior
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
      drawSegment(
        i,
        segment.x * gridSize - offset + gap / 2,
        segment.y * gridSize - offset + gap / 2,
        s
        );
    }
  }


  // override to change look of snake
  void drawSegment(int index, float x, float y, float size) {
    rect(
      x,
      y,
      size,
      size,
      5  // Fixed roundness
      );
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

  // optional, override to change for your snake

  void drawDebug() {
    PVector head = segments.get(0);

    // Draw a slowly pulsing aura
    float pulse = sin(frameCount * 0.02) * 0.5 + 0.5;  // Very slow pulse (0.02 for a leisurely pace)
    float auraSize = map(pulse, 0, 1, gridSize * 10, gridSize * 15);  // Pulse between 10x and 15x grid size
    float hueShift = map(pulse, 0, 1, 0, 30);  // Shift hue between green (0) and a bluish-green (30)
    colorMode(HSB, 360, 100, 100);
    fill(120 + hueShift, 80, 80, 80);  // Green to bluish-green, semi-transparent
    colorMode(RGB, 255);
    noStroke();
    circle(
      head.x * gridSize + gridSize / 2,
      head.y * gridSize + gridSize / 2,
      auraSize
      );
  }

  // optional


  void drawSpeedMeter() {
    PVector head = segments.get(0);

    // Draw speed meter above the snake's name
    float sizeMultiplier = map(score, 1, 50, 1, maxMult);
    float offset = ((gridSize - 1) * sizeMultiplier - (gridSize - 1)) / 2;

    float meterX = head.x * gridSize + gridSize / 2;
    float meterY = head.y * gridSize - nameOffset - offset - 20;  // Position above the name

    // Map speed to a fill percentage (faster = more filled)
    float speedPercentage = constrain(map(updateInterval, 50, 200, 1, 0), 0, 1);  // Inverse mapping: lower interval = faster
    float meterWidth = gridSize * 2;  // Width of the meter
    float meterHeight = 5;            // Height of the meter
    float filledWidth = meterWidth * speedPercentage;

    // Background of the meter (empty)
    stroke(255, 100);
    fill(50, 100);
    rect(meterX - meterWidth / 2, meterY - meterHeight / 2, meterWidth, meterHeight);

    // Filled portion of the meter (based on speed)
    color speedColor = lerpColor(color(255, 0, 0), color(0, 255, 0), speedPercentage);  // Red (slow) to green (fast)
    fill(speedColor);
    noStroke();
    rect(meterX - meterWidth / 2, meterY - meterHeight / 2, filledWidth, meterHeight);

    // Add a label showing the exact speed
    fill(255);
    textAlign(CENTER);
    textSize(10);
    float fps = 1000/updateInterval;
    if (fps < 0) {
      fps = 0;
    }
    text( fps + " FPS", meterX, meterY - 10);  // Show speed as frames per second
  }

  // ============= Utiities ====================

  boolean edgeDetect(PVector pos) {
    int w = floor(width / gridSize);
    int h = floor(height / gridSize);
    return pos.x < 0 || pos.x >= w || pos.y < 0 || pos.y >= h;
  }


  boolean overlap(PVector pos, ArrayList<Snake> snakes) {
    for (Snake snake : snakes) {
      if (!snake.alive) continue;
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


    if (abs(direction.x) > 1 || abs(direction.y) > 1 || (abs(direction.x) + abs(direction.y) > 1)) {
      println("Invalid direction in move: (" + direction.x + ", " + direction.y + "). Resetting to (0, 0).");
      direction = new PVector(0, 0); // Stop movement to prevent errors
    }

    // Check for collisions
    if (edgeDetect(newHead)) {
      die();
      return;
    }

    // Check for snake collisions and create animation if collision occurs
    if (overlap(newHead, snakes)) {
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

  void setDirection(float dx, float dy) {
    // Validate direction components: must be -1, 0, or 1
    if (dx != -1 && dx != 0 && dx != 1) {
      println("Invalid dx value: " + dx + ". Must be -1, 0, or 1.");
      return;
    }
    if (dy != -1 && dy != 0 && dy != 1) {
      println("Invalid dy value: " + dy + ". Must be -1, 0, or 1.");
      return;
    }

    // Ensure the snake moves in only one direction (not diagonally)
    if (abs(dx) + abs(dy) > 1) {
      println("Invalid direction: (" + dx + ", " + dy + "). Cannot move diagonally.");
      return;
    }

    // Prevent 180-degree turns (e.g., moving right then immediately left)
    if (direction.x != -dx || direction.y != -dy) {
      nextDirection = new PVector(dx, dy);
    } else {
      println("Invalid direction change: (" + dx + ", " + dy + "). Cannot make a 180-degree turn.");
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


  boolean ateFood = false;
  void checkFood(ArrayList<Food> food) {
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

  void die() {
    alive = false;
  }

  ArrayList<PVector> getFood() {
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
