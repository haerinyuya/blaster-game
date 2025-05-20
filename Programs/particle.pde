
class Particle {
  PVector position;
  PVector direction;
  color col;
  float size;
  float sizeDamping;
  float distance;
  float speed;
  boolean appearing;
  
  // 消滅時の普通のパーティクル
  Particle(PVector position, color col, float size, boolean appearing) {
    this.position = position;
    direction = PVector.random2D();
    this.col = col;
    this.size = size;
    sizeDamping = random(0.2, 0.4);
    distance = 0;
    speed = random(0.8, 6);
    this.appearing = appearing;
  }
  
  // 綺麗に揃ったパーティクル
  Particle(PVector position, PVector direction, color col, float size, float speed) {
    this.position = position;
    this.direction = direction;
    this.col = col;
    this.size = size;
    sizeDamping = 0.1;
    distance = 0;
    this.speed = speed;
  }
  
  // 出現時のパーティクル
  Particle(PVector position, float size, boolean appearing) {
    this.position = position;
    direction = PVector.random2D();
    this.col = color(255, 60, 240);
    this.size = size;
    sizeDamping = random(0.2, 0.4);
    distance = random(80, 120);
    speed = random(2, 4);
    this.appearing = appearing;
  }
  
  void draw() {
    if (appearing) { // 外から内へ
      distance -= speed;
      size -= sizeDamping;
      
      push();
      
      translate(position.x, position.y);
      rotate(direction.heading());
      strokeWeight(2);
      stroke(col);
      line(0, distance, 0, size + distance);
      
      pop();
    } else { // 内から外へ
      distance += speed;
      size -= sizeDamping;
      
      push();
      
      translate(position.x, position.y);
      rotate(direction.heading());
      strokeWeight(2);
      stroke(col);
      line(0, size + distance, 0, distance);
      
      pop();
    }
  }
}
