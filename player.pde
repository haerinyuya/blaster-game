
// プレイヤークラス
class Player {
  PVector position;
  PVector direction;
  PVector bulletDirection;
  float radius = 12;
  float rotateRadian = 0;
  int shotTime = 0;
  int shotCount = 0;
  int bigShotCount = 0;
  
  float speed = 3; // 移動速度
  float range = 160; // 射程範囲
  float magRange = 100; // マグネット範囲
  
  int damageBoost = 0; // ダメージブースト
  int fireRate = 0; // Fire Rate
  int wide = 0; // wide shot
  int multi = 0; // multi shot
  int nova = 0; // nova
  int spiral = 0; // spiral shot
  int bulletNum = 1;
  boolean penetrate = false; // 貫通
  boolean side = false; // side shot
  boolean back = false; // back shot
  
  float damage, interval = 0;
  int multiInterval = 5;
  int multiCount = 0;
  PVector multiPos;
  boolean isMulti = false;
  
  boolean moveUp, moveDown, moveLeft, moveRight;
  
  String state = "appearing";
  boolean isDead = false;
  
  color col = color(210, 210, 255);
  
  ArrayList<Trail> trail;
  ArrayList<Particle> particles;
  ArrayList<Bullet> bullets;
  
  Player(ArrayList<Bullet> bullets) {
    position = new PVector(width / 2, height / 2);
    direction = new PVector(0, 0);
    bulletDirection = new PVector(0, 0);
    multiPos = new PVector(0, 0);
    
    trail = new ArrayList<Trail>();
    particles = new ArrayList<Particle>();
    this.bullets = bullets;
    
    // 爆発パーティクル
    for (int i = 0; i < 100; i++) {
      particles.add(new Particle(position, col, 18, false));
    }
    // 綺麗に揃ったパーティクルも追加
    for (int i = 0; i < 360; i++) {
      var direction = PVector.fromAngle(radians(i));
      particles.add(new Particle(position, direction, col, 10, 12));
    }
    // ダメージとインターバルを初期化
    updateParam();
  }
  
  void draw(ArrayList<Enemy> enemies) {
    if (state.equals("appearing")) { // 出現時
    
      particleDraw(particles, false);
      // 全て削除されたかをチェック
      if (particles.isEmpty()) {
        state = "moving";
        return;
      }
      
      display();
      
    } else if (state.equals("moving")) { // 動いてるとき
      
      shot(enemies);
      trailDraw(trail, position, color(110, 60, 255), 8, 0.4);
      move();
      display();
      
    } else if (state.equals("disappearing")){ // 消滅時
      
      particleDraw(particles, false);
      // 全て削除されたかをチェック
      if (particles.isEmpty()) {
          trail.clear();
          isDead = true;
      }
    }
  }
  
  // ダメージとインターバルの再計算
  public void updateParam() {
    interval = 18 - (fireRate * 1.98);
    if (interval < 1.2) {
      interval = 1.2;
    }
    // ダメージの計算
    damage = 0.0;
    if (damageBoost < 0) {
      damage = 1 + (damageBoost * 0.25);
    } else {
      damage = 1 + (damageBoost * 0.5);
    }
    if (damage < 0.2) {
      damage = 0.2;
    }   
  }
  
  private void shot(ArrayList<Enemy> enemies) {
    shotTime++;
    if (!isMulti) {
      if (shotTime >= interval) {
        
        // 一番近い敵にショット
        var min = 1000000000.0;
        for (Enemy enemy : enemies) {
          if (enemy.state == "moving") {
            // 敵との衝突判定 (sqrtのコスト削減のために、PVector.dist()を使わず、距離の平方で判定する)
            float distanceSq = getDistanceSq(position, enemy.position);
            if (distanceSq < min) {
              min = distanceSq;
              bulletDirection = PVector.sub(enemy.position, position).normalize();
            }
          }
        }
        
        if (min < range * range) {
          shotCount++;
          bigShotCount++;
          
          // 普通のショット
          frontBullet(position, bulletDirection, damage, wide, bulletNum);
          if (side) {
            sideBullet(position, bulletDirection, damage, bulletNum);
          }
          if (back) {
            backBullet(position, bulletDirection, damage, bulletNum);
          }
          
           // 特別なショット
          if (multiCount == 0) {
            var constDamage = 1;
            if (shotCount == 5) {
              nova(position, bulletDirection, constDamage, nova);
              shotCount = 0;
            }
            
            if (bigShotCount == 7) {
              spiral(position, bulletDirection, constDamage, spiral);
              bigShotCount = 0;
            }
          }
          isMulti = true;
          multiPos = position;
          shotTime = 0;
        }
      }
    } else {
      if (multi == multiCount) {
        multiCount = 0;
        isMulti = false;
        return;
      }
      if (shotTime >= multiInterval) {
        // 普通のショット
        frontBullet(multiPos, bulletDirection, damage, wide, bulletNum);
        if (side) {
          sideBullet(multiPos, bulletDirection, damage, bulletNum);
        }
        if (back) {
          backBullet(multiPos, bulletDirection, damage, bulletNum);
        }
        multiCount ++;
        shotTime = 0;
      }
    }
  }
    
  private void move() {
    direction.set(0, 0);
    if (moveUp) direction.y = -1;
    if (moveDown) direction.y = 1;
    if (moveLeft) direction.x = -1;
    if (moveRight) direction.x = 1;
    
    position = PVector.add(position, direction.setMag(speed));
    
    // 移動制限
    position.x = constrain(position.x, 295 + radius, width - 295 - radius);
    position.y = constrain(position.y, 15 + radius, height - 15 - radius);
  }
  
  private void display() {
      rotateRadian += PI / 30;
      if (rotateRadian > 2 * PI) rotateRadian = 0;
      
      pushMatrix();
      
      translate(position.x, position.y);
      
      // rangeの表示
      stroke(255, 255, 255, 50);
      strokeWeight(3);
      noFill();
      circle(0, 0, range * 2);
      
      // playerの表示
      noStroke();
      rectMode(CENTER);
      fill(col);
      rotate(rotateRadian);
      rect(0, 0, radius * 2, radius * 2);
      
      popMatrix();
  }
  
  private void bullet(PVector position, PVector direction, float damage, int bulletNum) {
    for (int i = 0; i < bulletNum; i ++) {
      var dif = int((i + 1) / 2) * ((i % 2 == 0) ? -1 : 1) * 14;
      var difVector = direction.copy().rotate(HALF_PI);
      var newPos = PVector.add(position, difVector.copy().setMag(dif));
      bullets.add(new NormalBullet(newPos, direction, damage, 14));
    }
  }
  
  // front--------------------------------------------------------------------------------------------------------------------
  public void frontBullet(PVector position, PVector direction, float damage, int wide, int bulletNum) {
    bullet(position, direction, damage, bulletNum);
    if (wide > 0) {
      for (int i = 0; i < wide; i++) {
        bullet(position, direction.copy().rotate((i + 1) * -0.15), damage, bulletNum);
        bullet(position, direction.copy().rotate((i + 1) * 0.15), damage, bulletNum);
      }
    }
  }
  
  // side---------------------------------------------------------------------------------------------------------------------
  public void sideBullet(PVector position, PVector direction, float damage, int bulletNum) {
    bullet(position, direction.copy().rotate(-HALF_PI), damage, bulletNum);
    bullet(position, direction.copy().rotate(HALF_PI), damage, bulletNum);
  }
  
  // back---------------------------------------------------------------------------------------------------------------------
  public void backBullet(PVector position, PVector direction, float damage, int bulletNum) {
    bullet(position, direction.copy().rotate(PI), damage, bulletNum);
  }
  
  // nova---------------------------------------------------------------------------------------------------------------------
  public void nova(PVector position, PVector direction, float damage, int nova) {
    if (nova > 0) {
      var count = 4 + nova * 4;
      for (int i = 0; i < count; i++) {
        bullets.add(new NormalBullet(position, direction.copy().rotate((2 * PI / count) * i), damage, 14));
      }
    }
  }
  
  // spiral-------------------------------------------------------------------------------------------------------------------
  public void spiral(PVector position, PVector direction, float damage, int spiral) {
    if (spiral > 0) {
      var count = 4 + spiral * 4;
      for (int i = 0; i < count; i++) {
        bullets.add(new SpiralBullet(position, direction.copy().rotate((2 * PI / count) * i), damage, 14));
      }
    }
  }
}
