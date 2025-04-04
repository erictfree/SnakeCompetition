class CollisionAnimation {
  float x, y;           // Position of the animation
  float size;           // Current size of the animation
  float maxSize;        // Maximum size the animation will reach
  float speed;          // How fast the animation expands
  float alpha;          // Current transparency
  color animColor;      // Color of the animation
  boolean active;       // Whether the animation is currently playing

  // Multiple circle properties
  static final int NUM_CIRCLES = 3;  // Number of concentric circles
  float[] circleSizes;               // Current sizes of each circle
  float[] circleSpeeds;              // Speeds for each circle
  float[] circleAlphas;              // Alpha values for each circle

  CollisionAnimation(float x, float y, color animColor) {
    this.x = x;
    this.y = y;
    this.animColor = animColor;
    this.size = 0;
    this.maxSize = 200;
    this.speed = 4;
    this.alpha = 255;
    this.active = true;

    // Initialize multiple circles
    circleSizes = new float[NUM_CIRCLES];
    circleSpeeds = new float[NUM_CIRCLES];
    circleAlphas = new float[NUM_CIRCLES];

    // Set different speeds and starting sizes for each circle
    for (int i = 0; i < NUM_CIRCLES; i++) {
      circleSizes[i] = 0;
      circleSpeeds[i] = speed * (1 + i * 0.5);  // Each circle moves faster
      circleAlphas[i] = 255;
    }
  }

  void update() {
    if (!active) return;

    // Update each circle
    for (int i = 0; i < NUM_CIRCLES; i++) {
      circleSizes[i] += circleSpeeds[i];
      circleAlphas[i] = map(circleSizes[i], 0, maxSize, 255, 0);
    }

    // Check if all circles are done
    boolean allDone = true;
    for (int i = 0; i < NUM_CIRCLES; i++) {
      if (circleSizes[i] < maxSize) {
        allDone = false;
        break;
      }
    }
    if (allDone) {
      active = false;
    }
  }

  void draw() {
    if (!active) return;

    // Draw each circle
    for (int i = 0; i < NUM_CIRCLES; i++) {
      float strokeWeight = 4 - (i * 1.5);  // Thinner strokes for outer circles
      float alphaMultiplier = 1.0 - (i * 0.2);  // Less alpha for outer circles
      
      // Draw outer glow
      noFill();
      stroke(255, circleAlphas[i] * 0.5 * alphaMultiplier);
      strokeWeight(strokeWeight);
      circle(x, y, circleSizes[i]);

      // Draw inner circle
      stroke(255, circleAlphas[i] * alphaMultiplier);
      strokeWeight(strokeWeight * 0.5);
      circle(x, y, circleSizes[i] * 0.8);
    }
  }
} 