class CelebrationParticle {
  float x, y;
  float vx, vy;
  float size;
  float alpha;
  color particleColor;
  float rotation;
  float rotationSpeed;

  CelebrationParticle(float x, float y, color particleColor) {
    this.x = x;
    this.y = y;
    this.particleColor = particleColor;
    this.size = random(5, 15);
    this.alpha = 255;
    
    // Random velocity
    float angle = random(TWO_PI);
    float speed = random(2, 5);
    this.vx = cos(angle) * speed;
    this.vy = sin(angle) * speed;
    
    // Rotation
    this.rotation = random(TWO_PI);
    this.rotationSpeed = random(-0.1, 0.1);
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.1; // Gravity
    alpha -= 2; // Fade out
    rotation += rotationSpeed;
  }

  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    
    // Draw star shape
    fill(particleColor, alpha);
    noStroke();
    beginShape();
    for (int i = 0; i < 5; i++) {
      float angle = TWO_PI * i / 5;
      float px = cos(angle) * size;
      float py = sin(angle) * size;
      vertex(px, py);
    }
    endShape(CLOSE);
    
    popMatrix();
  }

  boolean isDead() {
    return alpha <= 0;
  }
} 