
class Bullet {
  PVector position;
  PVector direction;
  float damage;
  float radius;
  float speed;
  boolean isMoving = true;
  boolean isDead = false;
  color col = color(110, 60, 255);
  
  ArrayList<Trail> trail;
  ArrayList<Particle> particles;
  
  Bullet(PVector position, PVector direction, float damage, float radius) {
    this.position = position;
    this.direction = direction;
    this.damage = damage;
    this.radius = radius;
    
    trail = new ArrayList<Trail>();
    particles = new ArrayList<Particle>();
  }
  
  private void draw() {
    if (isMoving) {
      trailDraw(trail, position, color(col, 60), radius / 2, 1.2);
      move();
      
      pushMatrix();
      
      translate(position.x, position.y);
      rotate(direction.heading());
      noStroke();
      fill(col);
      drawDiamond(0, 0, radius);
      
      popMatrix();
      
      // 壁に当たった
      if (position.x < 295 || position.x > width - 295 || position.y < 15 || position.y > height - 15) {
        delete();
      }
    } else {
      particleDraw(particles, false);
      // 全て削除されたかをチェック
      if (particles.isEmpty()) {
          isDead = true;
      }
    }
  }
  
  protected void move() {
    position = PVector.add(position, direction.setMag(speed));
  }
  
  private void delete() {
    isMoving = false;
    // 爆発パーティクル
    for (int i = 0; i < 20; i++) {
      particles.add(new Particle(position, col, 8, false));
    }
  }
  
  // ダイアモンド型を描画する関数
  private void drawDiamond(float x, float y, float r) {
    float R;
    pushMatrix();
    
    translate(x, y);
    rotate(HALF_PI);
    
    beginShape();
    for (int i = 0; i < 4; i++) {
      if (i % 2 == 0) {
        R = (r / 2) * (damage / 2 + 0.3);
      } else {
        R = r;
      }
      vertex(R*cos(radians(90*i)), R*sin(radians(90*i)));
    }
    endShape(CLOSE);
    
    popMatrix();
  }
}

class NormalBullet extends Bullet {
  NormalBullet(PVector position, PVector direction, float damage, float radius) {
    super(position, direction, damage, radius);
    speed = 8;
  }
}

class SpiralBullet extends Bullet {
  SpiralBullet(PVector position, PVector direction, float damage, float radius) {
    super(position, direction, damage, radius);
    speed = 2;
  }
  
  @Override
  void move() {
    if (speed < 16) {
      speed += 0.1;
    }
    direction.rotate(0.04);
    position = PVector.add(position, direction.setMag(speed));
  }
}
