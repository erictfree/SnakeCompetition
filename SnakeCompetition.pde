import processing.core.PApplet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import processing.sound.SoundFile;

ArrayList<CollisionAnimation> collisionAnimations = new ArrayList<CollisionAnimation>();
SoundFile soundtrack;
int currentSnakeIndex = 0;
ArrayList<CelebrationParticle> celebrationParticles = new ArrayList<CelebrationParticle>();
float celebrationPulse = 0;
float celebrationPulseSpeed = 0.05;
ArrayList<Snake> deadSnakes = new ArrayList<Snake>();
int finalTime = 0;

int maxFood = 100;
final int INITIAL_SNAKES = 50;
final boolean USE_TIME_LIMIT = true;  // Flag to enable/disable time limit
final int MAX_ROUND_TIME = 3* 60 * 1000;
final int GRIDSIZE = 20;
int colorIndex = 0;

// Grid dimensions
int[][] gridColors;
PImage backgroundImage;  // Add this line to store the background image

ArrayList<Snake> snakes;
ArrayList<Food> food;
Leaderboard leaderboard;

boolean gameOver = false;
String winnerName = "";
color winnerColor;
int roundStartTime;  // Track when the round started
boolean showLeaderboard = true;  // Whether to show the leaderboard
int winnerScore = 0;  // Add winner score variable

// Arrays of silly names for compound name generation
String[] firstNames = {
  "Happy", "Silly", "Bouncy", "Wiggly", "Jumpy",
  "Dizzy", "Wacky", "Zippy", "Fuzzy", "Snappy",
  "Giggly", "Wobbly", "Squiggly", "Bumpy", "Twisty"
};

String[] secondNames = {
  "Frog", "Panda", "Penguin", "Dolphin", "Koala",
  "Puppy", "Kitten", "Bunny", "Duck", "Otter",
  "Beaver", "Raccoon", "Hedgehog", "Squirrel", "Hamster"
};


/**
 * Generates a silly compound name by combining random words from the name arrays
 * @return A compound name like "HappyFrog" or "SillyPanda"
 */
String generateSillyName() {
  String first = firstNames[int(random(firstNames.length))];
  String second = secondNames[int(random(secondNames.length))];
  return first + second;
}

void setup() {
  size(2000, 1100);

  // Load background image
  backgroundImage = loadImage("background.jpg");
  if (backgroundImage != null) {
    backgroundImage.resize(width, height);  // Resize to match sketch dimensions
  }

  startNewGame();

  // Load and start the soundtrack
  soundtrack = new SoundFile(this, "theme.mp3");
  soundtrack.loop();
  soundtrack.amp(0.8);  // Set volume to 80%
}

void draw() {
  // Draw background image if loaded
  if (backgroundImage != null) {
    image(backgroundImage, 0, 0);
  } else {
    background(0);
  }
  
  // Draw grid
  drawGrid();

  // Draw food
  for (Food f : food) {
    f.draw();
  }

  // Draw snakes
  for (Snake snake : snakes) {
    snake.update(food, snakes, millis());
    snake.draw();
  }

  // Check for dead snakes and convert them to food
  for (int i = snakes.size() - 1; i >= 0; i--) {
    Snake snake = snakes.get(i);
    if (!snake.isAlive()) {
      // Add snake segments as food
      ArrayList<PVector> newFoodPositions = snake.getFood();
      for (PVector pos : newFoodPositions) {
        Food newFood = new Food((int)pos.x, (int)pos.y);
        newFood.foodColor = snake.getColor();  // Set the food color to match the snake
        food.add(newFood);
      }

      // Store dead snake before removing it
      deadSnakes.add(snake);
      leaderboard.update(snake);
      snakes.remove(i);

      if (snakes.size() == 1) {
        gameOver = true;
        winnerName = snakes.get(0).getName();
        winnerColor = snakes.get(0).getColor();
        winnerScore = snakes.get(0).getScore();  // Store the winning score
        finalTime = millis() - roundStartTime;  // Store final time
      }
    }
  }

  // Check for time limit
  checkTimeLimit();

  // Maintain minimum food, but don't exceed maximum
  while (food.size() < maxFood) {
    Food newFood;
    if (random(100) <= 5) {
      newFood = new Food(0, 0, int(random(2, 20)));  // 5-point food
    } else {
      newFood = new Food(0, 0);     // Regular food
    }
    food.add(newFood.spawnRandom(width, height, snakes, food));
  }

  // Draw collision animations
  for (int i = collisionAnimations.size() - 1; i >= 0; i--) {
    CollisionAnimation anim = collisionAnimations.get(i);
    anim.update();
    anim.draw();
    if (!anim.active) {
      collisionAnimations.remove(i);
    }
  }

  // Draw leaderboard if enabled
  if (showLeaderboard) {
    leaderboard.draw(snakes);
  }

  // Draw game over screen if there's a winner
  if (gameOver) {
    drawWinnerScreen();  // Moved to the end to draw on top of everything
  }
}

void startNewGame() {
  snakes = new ArrayList<Snake>();
  food = new ArrayList<Food>();
  deadSnakes = new ArrayList<Snake>();  // Clear dead snakes
  leaderboard = new Leaderboard();

  gameOver = false;
  winnerName = "";
  winnerColor = color(255);
  roundStartTime = millis();  // Record round start time
  colorIndex = 0;

  // Create snakes
  for (int i = 0; i < snakeNames.length; i++) {
    PVector spot = findEmptySpot(snakes, 100);
    if (spot != null) {
      Snake newSnake = spawnNewSnake((int)spot.x, (int)spot.y, snakeNames[i]);

      if (newSnake != null) {
        snakes.add(newSnake);
      }
    }
  }

  // Create initial food
  for (int i = 0; i < maxFood; i++) {
    Food newFood = new Food(0, 0);
    food.add(newFood.spawnRandom(width, height, snakes, food));
  }
}

PVector findEmptySpot(ArrayList<Snake> snakes, int maxAttempts) {
  int attempts = 0;
  boolean foundSpot = false;
  PVector spot = null;

  while (attempts < maxAttempts && !foundSpot) {
    int x = floor(random(width / 20));
    int y = floor(random(height / 20));
    spot = new PVector(x, y);
    attempts++;

    boolean occupied = false;
    for (Snake snake : snakes) {
      if (snake.overlap(spot, snakes)) {
        occupied = true;
        break;
      }
    }

    if (!occupied) {
      foundSpot = true;
    }
  }

  return foundSpot ? spot : null;
}

void checkTimeLimit() {
  if (USE_TIME_LIMIT && !gameOver && snakes.size() > 1) {
    int currentTime = millis();
    if (currentTime - roundStartTime >= MAX_ROUND_TIME) {
      finalTime = MAX_ROUND_TIME;  // Store final time
      endRoundByTimeLimit();
    }
  }
}

Snake findHighestScorer() {
  Snake highestScorer = null;
  int highestScore = -1;

  // Only consider alive snakes
  for (Snake snake : snakes) {
    if (snake.getScore() > highestScore) {
      highestScore = snake.getScore();
      highestScorer = snake;
    }
  }

  return highestScorer;
}

void endRoundByTimeLimit() {
  Snake highestScorer = findHighestScorer();
  if (highestScorer != null) {  // Only end round if there are alive snakes
    gameOver = true;
    winnerName = highestScorer.getName();
    winnerColor = highestScorer.getColor();
    winnerScore = highestScorer.getScore();  // Store the winning score
  }
}


void drawWinnerScreen() {
  // Update celebration effects
  celebrationPulse += celebrationPulseSpeed;
  float pulseScale = 1 + sin(celebrationPulse) * 0.1;  // 10% pulse

  // Add new particles
  if (random(1) < 0.3) {  // 30% chance each frame
    float x = random(width);
    float y = random(height);
    color particleColor = color(random(255), random(255), random(255));
    celebrationParticles.add(new CelebrationParticle(x, y, particleColor));
  }

  // Update and draw particles
  for (int i = celebrationParticles.size() - 1; i >= 0; i--) {
    CelebrationParticle p = celebrationParticles.get(i);
    p.update();
    p.draw();
    if (p.isDead()) {
      celebrationParticles.remove(i);
    }
  }

  // Draw winner text with pulse effect
  pushMatrix();
  translate(width/2, height/2);
  scale(pulseScale);

  // Draw glow effect
  for (int i = 0; i < 3; i++) {
    float glowSize = 250 + i * 50;  // Increased glow size
    float glowAlpha = 100 - i * 30;
    fill(winnerColor, glowAlpha);
    noStroke();
    circle(0, 0, glowSize);
  }

  // Draw winner text
  fill(winnerColor);  // Use snake's color
  textAlign(CENTER, CENTER);
  textSize(96);  // Increased text size
  text(winnerName + " WINS!", 0, -80);  // Move up

  // Draw score
  textSize(72);  // Slightly smaller than winner text
  text("Score: " + winnerScore, 0, 20);  // Move down

  // Draw subtitle
  fill(255);
  textSize(48);  // Increased subtitle size
  text("Press SPACE to play again", 0, 120);  // Move down further

  popMatrix();
}

void keyPressed() {
  if (gameOver && key == ' ') {
    startNewGame();
  } else if (key == 'l' || key == 'L') {
    showLeaderboard = !showLeaderboard;
  }
}

// Add to stop the soundtrack when the sketch closes
void stop() {
  soundtrack.stop();  // Uncomment soundtrack stop
  super.stop();
}

void drawGrid() {
  // Draw grid lines
  stroke(50, 100);
  strokeWeight(1);
  for (int x = 0; x < width; x += GRIDSIZE) {
    line(x, 0, x, height);
  }
  for (int y = 0; y < height; y += GRIDSIZE) {
    line(0, y, width, y);
  }
}
