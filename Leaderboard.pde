class Leaderboard {
  // Properties
  private ArrayList<LeaderboardEntry> entries;
  private static final int LEADERBOARD_WIDTH = 240;
  private static final int LEADERBOARD_MARGIN = 10;
  int x = 10;
  int y = 10;
  int width = 200;
  int padding = 10;
  int lineHeight = 25;

  // Constructor
  Leaderboard() {
    entries = new ArrayList<LeaderboardEntry>();
  }

  // Public methods
  void update(Snake snake) {
    // No need to update anything since we're showing current scores
  }

  void draw(ArrayList<Snake> snakes) {
    // Create a list of all snakes (live and dead) sorted by score
    ArrayList<Snake> allSnakes = new ArrayList<Snake>();
    allSnakes.addAll(snakes);  // Add live snakes first
    allSnakes.addAll(deadSnakes);  // Add dead snakes second
    
    Collections.sort(allSnakes, new Comparator<Snake>() {
      @Override
      public int compare(Snake s1, Snake s2) {
        return s2.getScore() - s1.getScore();  // Sort in descending order
      }
    });

    // Calculate how many entries will fit
    int statsSectionHeight = 80;  // Height for stats section
    int availableHeight = height - 2 * y - statsSectionHeight;
    int maxEntries = floor(availableHeight / lineHeight);
    int entriesToShow = min(allSnakes.size(), maxEntries);
    
    // Calculate total height needed
    int leaderboardHeight = entriesToShow * lineHeight + padding * 2;

    // Draw background
    fill(0, 120);
    noStroke();
    rect(x, y, width, leaderboardHeight + statsSectionHeight);

    // Draw title
    fill(255);
    textAlign(LEFT);
    textSize(16);
    text("Leaderboard", x + padding, y + padding + 15);

    // Draw entries
    for (int i = 0; i < entriesToShow; i++) {
      Snake snake = allSnakes.get(i);
      float entryY = y + padding + 30 + i * lineHeight;

      // Draw rank
      fill(255, 180);
      textSize(12);
      text("#" + (i + 1), x + padding, entryY);

      // Draw name and score with appropriate color based on alive status
      if (snake.isAlive()) {
        fill(snake.getColor());
      } else {
        fill(128);  // Grey for dead snakes
      }
      textSize(14);
      text(snake.getName(), x + padding + 30, entryY);

      // Draw score
      fill(255);
      textAlign(RIGHT);
      text(snake.getScore(), x + width - padding, entryY);
      textAlign(LEFT);
    }

    // Draw stats section
    float statsY = y + leaderboardHeight;
    stroke(255, 100);
    line(x + padding, statsY, x + width - padding, statsY);

    // Draw stats
    fill(255, 180);
    textSize(16);
    textAlign(LEFT);
    text("Live Snakes: " + snakes.size(), x + padding, statsY + 25);
    text("Food Available: " + food.size(), x + padding, statsY + 45);
    
    // Draw time
    if (USE_TIME_LIMIT) {
      int timeToDisplay;
      if (gameOver) {
        timeToDisplay = finalTime;  // Use final time when game is over
      } else {
        timeToDisplay = MAX_ROUND_TIME - (millis() - roundStartTime);  // Use current time during game
      }
      
      if (timeToDisplay > 0) {
        int minutes = timeToDisplay / 60000;
        int seconds = (timeToDisplay % 60000) / 1000;
        String timeStr = String.format("Time Remaining: %02d:%02d", minutes, seconds);
        text(timeStr, x + padding, statsY + 65);
      }
    }
  }

  // Getter methods
  ArrayList<LeaderboardEntry> getEntries() {
    return entries;
  }
}

// Leaderboard entry class
class LeaderboardEntry {
  String name;
  int score;
  String time;
  boolean current;
  color snakeColor;

  LeaderboardEntry(String name, int score, String time) {
    this.name = name;
    this.score = score;
    this.time = time;
    this.current = false;
    this.snakeColor = color(255); // Default white color for historical entries
  }

  LeaderboardEntry(String name, int score, String time, boolean current) {
    this.name = name;
    this.score = score;
    this.time = time;
    this.current = current;
    this.snakeColor = color(255); // Default white color for current entries
  }
}

// Comparator for sorting leaderboard entries
class LeaderboardComparator implements java.util.Comparator<LeaderboardEntry> {
  public int compare(LeaderboardEntry a, LeaderboardEntry b) {
    return b.score - a.score; // Descending order
  }
} 
