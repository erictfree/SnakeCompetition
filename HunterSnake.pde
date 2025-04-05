class HunterSnake extends Snake {
  HunterSnake(int gg, int qq) {
    super(gg, qq, generateSillyName());
    updateInterval = 80;
  }
  void think(ArrayList<Food> _a, ArrayList<Snake> _u) {
    Food zz = null;
    float ___z = Float.MAX_VALUE;
    for (Food ww : food) {
      float fdd = abs(ww.x - segments.get(0).x) + abs(ww.y - segments.get(0).y);
      if (fdd < ___z) {
        ___z = fdd;
        zz = ww;
      }
    }
    if (zz != null) {
      float jj = zz.x > segments.get(0).x ? 1 : (zz.x < segments.get(0).x ? -1 : 0);
      float dy = zz.y > segments.get(0).y ? 1 : (zz.y < segments.get(0).y ? -1 : 0);
      if (jj != 0 && !yy(new PVector(segments.get(0).x + jj, segments.get(0).y), snakes)) {
        setDirection(jj, 0);
      } else if (dy != 0 && !yy(new PVector(segments.get(0).x, segments.get(0).y + dy), snakes)) {
        setDirection(0, dy);
      } else {
        xx(snakes);
      }
    }
  }
  boolean yy(PVector pos, ArrayList<Snake> snakes) {
    return edgeDetect(pos) || overlap(pos, snakes);
  }
  void xx(ArrayList<Snake> dd) {
    PVector[] oa = { new PVector(1, 0), new PVector(0, 1), new PVector(-1, 0), new PVector(0, -1) };
    for (PVector dir : oa) {
      PVector newPos = new PVector(segments.get(0).x + dir.x, segments.get(0).y + dir.y);
      if (!yy(newPos, snakes)) {
        setDirection(dir.x, dir.y);
        return;
      }
    }
  }
}
