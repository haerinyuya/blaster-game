
class Trail {
  PVector position;
  color col;
  float radius;
  float damping;
  
  Trail(PVector position, color col, float radius, float damping) {
    this.position = position;
    this.col = col;
    this.radius = radius;
    this.damping = damping;
  }
  
  // trail
  void draw(PVector pPos) {
    radius -= damping;
    if (radius <= 0) {
      return;
    }
    stroke(col);
    strokeWeight(radius * 2);
    line(position.x, position.y, pPos.x, pPos.y);
  }
}
