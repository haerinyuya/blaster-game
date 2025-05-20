
// 敵の基底クラス--------------------------------------------------------------------------------------------------------------------------------------
abstract class Enemy {
  PVector position;
  PVector direction;
  float speed;
  float health;
  float radius;
  
  String state;
  boolean isDead = false;
  float appearingCount = 70;
  color bodyColor = color(255, 60, 240);
  color trailColor = color(255, 60, 240, 30);
  
  int score;
  
  ArrayList<Enemy> enemies;
  ArrayList<Coin> coins;
  ArrayList<Particle> particles;
  
  Enemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    this.position = position;
    this.state = state;
    
    this.enemies = enemies;
    this.coins = coins;
    
    particles = new ArrayList<Particle>();
    if (state.equals("appearing")) {
      for (int i = 0; i < 50; i++) {
        particles.add(new Particle(position, 20, true));
      }
    }
  }
  
  Enemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    position = new PVector(random(310 + radius, width - (310 + radius)), random(30 + radius, height - (30 + radius)));
    state = "appearing";
    
    this.enemies = enemies;
    this.coins = coins;
    
    particles = new ArrayList<Particle>();
    for (int i = 0; i < 50; i++) {
      particles.add(new Particle(position, 20, true));
    }
  }
  
  private void draw(Player player) {
    if (state.equals("appearing")) { // 出現時
    
      appearingDraw();
      
    } else if (state.equals("moving")) { // 動いてるとき
      move(player);
      noStroke();
      fill(bodyColor);
      display(1);
      // 当たり判定描画
      //noFill();
      //stroke(0, 255, 255);
      //strokeWeight(1);
      //circle(position.x, position.y, radius * 2);
      
    } else if (state.equals("disappearing")){ // 消滅時
    
      particleDraw(particles, false);
      
      if (particles.size() <= 0) {
        isDead = true;
        return;
      }
    }
  }
  
  // 出現時の描画
  private void appearingDraw() {
    // パーティクルが出始める
    particleDraw(particles, true);
    // 動き出す
    if (appearingCount <= 0) {
      particles.clear();
      state = "moving";
    }
    // 枠線が小さくなっていく
    appearingCount--;
    float rate = 1 + (appearingCount / 60);
    
    // 透明なやつ
    noStroke();
    fill(bodyColor, 100);
    display(1);
    
    //枠線
    stroke(bodyColor);
    strokeWeight(1.6);
    noFill();
    display(rate);
  }
  
  // 動きの計算
  abstract void move(Player player);
  // 描画
  abstract void display(float rate);
  
  // 弾当たったとき
  public void hit(float damage) {
    if (state != "moving") return;
    
    // 死んだら消す
    health -= damage;
    if (health <= 0) {
      totalScore += this.score;
      delete(false);
    }
  }
  
  // 死んだとき
  abstract void delete(boolean forced);
  
  // コインを落とす
  protected void createCoin(PVector position, int num) {
    for (int i = 0; i < num; i++) {
      var randomPosition = new PVector(random(position.x - 10, position.x + 10), random(position.y - 10, position.y + 10));
      coins.add(new Coin(randomPosition));
    }
  }
  
  protected void explosion(boolean parent) {
    // 爆発パーティクル
    for (int i = 0; i < 50; i++) {
      particles.add(new Particle(position, bodyColor, 20, false));
    }
    if (parent) {
      for (int i = 0; i < 180; i ++) {
        particles.add(new Particle(position, PVector.fromAngle(radians(i * 2)), bodyColor, 20, 10));
      }
    }
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------


// 丸い敵---------------------------------------------------------------------------------------------------------------------------------------------
class CircleEnemy extends Enemy {
  
  CircleEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = PVector.random2D(); // ランダムな方向を向く
    speed = 0.3; // おそい
    health = 1;
    radius = 12;
    score = (int)random(100, 200); // 一番ひくい
  }
  
  CircleEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = PVector.random2D(); // ランダムな方向を向く
    speed = 0.3; // おそい
    health = 1;
    radius = 12;
    score = (int)random(100, 200); // 一番ひくい
  }
  
  @Override
  void move(Player player) {
    // 壁で跳ね返る
    if (position.x < 295 + radius || position.x > width - 295 - radius) direction.x = - direction.x;
    if (position.y < 15 + radius || position.y > height - 15 - radius) direction.y = -direction.y;
    position = PVector.add(position, direction.setMag(speed));
  }
  
  // まるい
  @Override
  void display(float rate) {
    circle(position.x, position.y, radius * 2 * rate);
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(false);
    createCoin(position, 2);
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// 三角の敵-------------------------------------------------------------------------------------------------------------------------------------------
class TriangleEnemy extends Enemy {
  
  TriangleEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 1;
    radius = 12;
    score = (int)random(150, 250); // ひくめ
  }
  
  TriangleEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
     
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 1;
    radius = 12;
    score = (int)random(150, 250); // ひくめ
  }
  
  @Override
  void move(Player player) {
    // playerを追いかける
    direction = PVector.sub(player.position, position).normalize();
    position = PVector.add(position, direction.setMag(speed));
  }
  
  //正三角形
  @Override
  void display(float rate) {
    drawTriangle(position.x, position.y, radius * 1.4 * rate, direction);
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(false);
    createCoin(position, 2);
  }
  
  // 三角形を描画する関数
  private void drawTriangle(float x, float y, float r, PVector direction) {
    pushMatrix();
    
    translate(x, y);  // 中心となる座標
    rotate(direction.heading());
  
    // 円を均等に3分割する点を結び、三角形をつくる
    beginShape();
    for (int i = 0; i < 3; i++) {
      vertex(r * cos(PI * 2 * i / 3), r * sin(PI * 2 * i / 3));
    }
    endShape(CLOSE);
  
    popMatrix();
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// 矢印型の敵-----------------------------------------------------------------------------------------------------------------------------------------
class ArrowEnemy extends Enemy {
  ArrayList<Trail> trail;
  
  ArrowEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = getRandomDirection(); //直角座標上?でしか動かない
    speed = 2; //一番はやい
    health = 1.5;
    radius = 12;
    score = (int)random(300, 400); // 微妙にたかい
    
    trail = new ArrayList<Trail>();
  }
  
  ArrowEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = getRandomDirection(); //直角座標上?でしか動かない
    speed = 2; //一番はやい
    health = 1.5;
    radius = 12;
    score = (int)random(300, 400); // 微妙にたかい
    
    trail = new ArrayList<Trail>();
  }
  
  @Override
  void move(Player player) {
    // 壁で跳ね返る
    if (position.x < 295 + radius || position.x > width - 295 - radius) direction.x = - direction.x;
    if (position.y < 15 + radius || position.y > height - 15 - radius) direction.y = -direction.y;
    position = PVector.add(position, direction.setMag(speed));
    
    trailDraw(trail, position, color(trailColor), 6, 0.14);
  }
  
  // やじるしの形
  @Override
  void display(float rate) {
    drawArrow(position.x, position.y, radius * 1.4 * rate, direction);
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(false);
    createCoin(position, 2);
  }
  
  // 矢印型を描画する関数
  private void drawArrow(float x, float y, float r, PVector direction) {
    pushMatrix();
    
    translate(x, y);
    rotate(direction.heading() - HALF_PI);
    
    beginShape();
    vertex(0, r);
    vertex(r, -r);
    vertex(0, -r / 3);
    vertex(-r, -r);
    endShape(CLOSE);
    
    popMatrix();
  }
  
  // 直角なベクトルをランダムで得る関数
  private PVector getRandomDirection() {
    // 上、右、下、左の方向ベクトルを定義
    PVector[] directions = {
      new PVector(0, -1),  // 上方向
      new PVector(1, 0),   // 右方向
      new PVector(0, 1),   // 下方向
      new PVector(-1, 0)   // 左方向
    };
    
    // 配列からランダムに1つ選択
    int index = (int) random(directions.length);
    return directions[index];
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// でかい四角の敵--------------------------------------------------------------------------------------------------------------------------------------
class MsizeRectEnemy extends Enemy {
  float rotateRadian = 0;
  
  MsizeRectEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 15; //多めの体力
    radius = 30;
    score = (int)random(600, 800); // たかめ
  }
  
  MsizeRectEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 15; //多めの体力
    radius = 30;
    score = (int)random(600, 800); // たかめ
  }
  
  @Override
  void move(Player player) {
    // ぐるぐる回っている
    rotateRadian += PI / 40;
    if (rotateRadian > 2 * PI) rotateRadian = 0;
    
    // playerを追いかける
    direction = PVector.sub(player.position, position).normalize();
    position = PVector.add(position, direction.setMag(speed));
  }
  
  // でかい正方形
  @Override
  void display(float rate) {
    
    pushMatrix();
    
    rectMode(CENTER);
    translate(position.x, position.y);
    rotate(rotateRadian);
    rect(0, 0, radius * 2 * rate, radius * 2 * rate);
    
    popMatrix();
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(true);
    if (!forced) {
      // 丸い敵を3個生み出す
      for (int i = 0; i < 3; i++) {
        enemies.add(new CircleEnemy(new PVector(random(position.x - radius, position.x + radius), random(position.y - radius, position.y + radius)), "moving", enemies, coins));
      }
    }
    createCoin(position, 2);
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// でかい三角の敵-------------------------------------------------------------------------------------------------------------------------------------------
class MsizeTriangleEnemy extends Enemy {
  
  MsizeTriangleEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 15; //おおめの体力
    radius = 26;
    score = (int)random(700, 900); // ちょっと高い
  }
  
  MsizeTriangleEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
     
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 15; //おおめの体力
    radius = 26;
    score = (int)random(700, 900); // ちょっと高い
  }
  
  @Override
  void move(Player player) {
    // playerを追いかける
    direction = PVector.sub(player.position, position).normalize();
    position = PVector.add(position, direction.setMag(speed));
  }
  
  //正三角形
  @Override
  void display(float rate) {
    drawTriangle(position.x, position.y, radius * 1.4 * rate, direction);
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(true);
    if (!forced) {
      // 三角の敵を3個生み出す
      for (int i = 0; i < 3; i++) {
        enemies.add(new TriangleEnemy(new PVector(random(position.x - radius, position.x + radius), random(position.y - radius, position.y + radius)), "moving", enemies, coins));
      }
    }
    createCoin(position, 2);
  }
  
  // 三角形を描画する関数
  private void drawTriangle(float x, float y, float r, PVector direction) {
    pushMatrix();
    
    translate(x, y);  // 中心となる座標
    rotate(direction.heading());
  
    // 円を均等に3分割する点を結び、三角形をつくる
    beginShape();
    for (int i = 0; i < 3; i++) {
      vertex(r * cos(PI * 2 * i / 3), r * sin(PI * 2 * i / 3));
    }
    endShape(CLOSE);
  
    popMatrix();
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// 星型の敵--------------------------------------------------------------------------------------------------------------------------------------
class StarEnemy extends Enemy {
  float rotateRadian = 0;
  
  StarEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 0.8; //若干遅い
    health = 30; //結構多い体力
    radius = 18;
    score = (int)random(1600, 1800); // 高い
  }
  
  StarEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 0.8; //若干遅い
    health = 30; //結構多い体力
    radius = 18;
    score = (int)random(1600, 1800); // 高い
  }
  
  @Override
  void move(Player player) {
    // ぐるぐる回っている
    rotateRadian += PI / 60;
    if (rotateRadian > 2 * PI) rotateRadian = 0;
    
    // playerを追いかける
    direction = PVector.sub(player.position, position).normalize();
    position = PVector.add(position, direction.setMag(speed));
  }
  
  // 星型
  @Override
  void display(float rate) {
    
    pushMatrix();
    
    translate(position.x, position.y);
    rotate(rotateRadian);
    drawStar(0, 0, radius * 1.4 * rate, 4);
    
    popMatrix();
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(false);
    createCoin(position, 2);
  }
  
  private void drawStar(float x, float y, float r, int prickleNum) {
    int vertexNum = prickleNum*2;  // 頂点数(トゲの数*2)
    float R;  // 中心点から頂点までの距離
    float outR = r;  // 中心点からトゲまでの距離
    float inR = outR/2;  // 中心点から谷までの距離
  
    pushMatrix();
    translate(x, y);
    rotate(radians(-90));
    beginShape();
    for (int i = 0; i < vertexNum; i++) {
      if (i%2 == 0) {
        R = outR;
      } else {
        R = inR;
      }
      vertex(R*cos(radians(360*i/vertexNum)), R*sin(radians(360*i/vertexNum)));
    }
    endShape(CLOSE);
    popMatrix();
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// すごいでかい四角の敵--------------------------------------------------------------------------------------------------------------------------------------
class LsizeRectEnemy extends Enemy {
  float rotateRadian = 0;
  
  LsizeRectEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 50; //多い体力
    radius = 60;
    score = (int)random(2400, 2800); // 高い
  }
  
  LsizeRectEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = new PVector(0, 0); //さいしょはまっすぐ向いてる
    speed = 1; //普通のはやさ
    health = 50; //多い体力
    radius = 60;
    score = (int)random(2400, 2800); // 高い
  }
  
  @Override
  void move(Player player) {
    // ぐるぐる回っている
    rotateRadian += PI / 50;
    if (rotateRadian > 2 * PI) rotateRadian = 0;
    
    // playerを追いかける
    direction = PVector.sub(player.position, position).normalize();
    position = PVector.add(position, direction.setMag(speed));
  }
  
  // すごいでかい正方形
  @Override
  void display(float rate) {
    
    pushMatrix();
    
    rectMode(CENTER);
    translate(position.x, position.y);
    rotate(rotateRadian);
    rect(0, 0, radius * 2 * rate, radius * 2 * rate);
    
    popMatrix();
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(true);
    if (!forced) {
      // でかい四角の敵を2個生み出す
      for (int i = 0; i < 2; i++) {
        enemies.add(new MsizeRectEnemy(new PVector(random(position.x - radius, position.x + radius), random(position.y - radius, position.y + radius)), "moving", enemies, coins));
      }
    }
    createCoin(position, 2);
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// 魚の敵--------------------------------------------------------------------------------------------------------------------------------------
class FishEnemy extends Enemy {
  ArrayList<Trail> trail;
  
  FishEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = getRandomDirection(); //ななめでしか動かない
    speed = 1.6; //けっこうはやい
    health = 80; // 多い
    radius = 18;
    score = (int)random(3600, 4000); // 結構高い
    
    trail = new ArrayList<Trail>();
  }
  
  FishEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = getRandomDirection(); //ななめでしか動かない
    speed = 1.6; //けっこうはやい
    health = 80; // 多い
    radius = 18;
    score = (int)random(3600, 4000); // 結構高い
    
    trail = new ArrayList<Trail>();
  }
  
  @Override
  void move(Player player) {
    // 壁で跳ね返る
    if (position.x < 295 + radius || position.x > width - 295 - radius) direction.x = - direction.x;
    if (position.y < 15 + radius || position.y > height - 15 - radius) direction.y = -direction.y;
    position = PVector.add(position, direction.setMag(speed));
    
    trailDraw(trail, position, color(trailColor), 6, 0.14);
  }
  
  // 魚の形
  @Override
  void display(float rate) {
    drawFish(position.x, position.y, radius * 1.4 * rate, direction);
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(false);
    createCoin(position, 2);
  }
  
  // 魚型を描画する関数
  private void drawFish(float ox, float oy, float r, PVector direction) {
    pushMatrix();
    translate(ox, oy);
    rotate(direction.heading());
    beginShape();
    for (int theta= 0; theta< 360; theta++) {
      float x = r * cos(radians(theta)) - r * pow(sin(radians(theta)), 2) / sqrt(2);
      float y = r * cos(radians(theta)) * sin(radians(theta));
  
      vertex(x, y);
    }
    endShape(CLOSE);
    popMatrix();
  }
  
  // 斜めのベクトルをランダムで得る関数
  private PVector getRandomDirection() {
    // 上、右、下、左の方向ベクトルを定義
    PVector[] directions = {
      new PVector(1, 1),  // 右上方向
      new PVector(1, -1),   // 右下方向
      new PVector(-1, -1),   // 左下方向
      new PVector(-1, 1)   // 左上方向
    };
    
    // 配列からランダムに1つ選択
    int index = (int) random(directions.length);
    return directions[index];
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------

// とげとげの敵--------------------------------------------------------------------------------------------------------------------------------------
class SpikyEnemy extends Enemy {
  float rotateRadian = 0;
  
  SpikyEnemy(PVector position, String state, ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(position, state, enemies, coins);
    
    direction = PVector.random2D(); // ランダムな方向を向く
    speed = 1; //普通のはやさ
    health = 120; //だいぶ多い体力
    radius = 30;
    score = (int)random(5000, 5400); // だいぶ高い
  }
  
  SpikyEnemy(ArrayList<Enemy> enemies, ArrayList<Coin> coins) {
    super(enemies, coins);
    
    direction = PVector.random2D(); // ランダムな方向を向く
    speed = 1; //普通のはやさ
    health = 120; //だいぶ多い体力
    radius = 30;
    score = (int)random(5000, 5400); // だいぶ高い
  }
  
  @Override
  void move(Player player) {
    // ぐるぐる回っている
    rotateRadian += PI / 40;
    if (rotateRadian > 2 * PI) rotateRadian = 0;
    
    // 壁で跳ね返る
    if (position.x < 295 + radius || position.x > width - 295 - radius) direction.x = - direction.x;
    if (position.y < 15 + radius || position.y > height - 15 - radius) direction.y = -direction.y;
    position = PVector.add(position, direction.setMag(speed));
  }
  
  // とげとげ型
  @Override
  void display(float rate) {
    pushMatrix();
    
    translate(position.x, position.y);
    rotate(rotateRadian);
    drawStar(0, 0, radius * 1.4 * rate, 6);
    
    popMatrix();
  }
  
  @Override
  void delete(boolean forced) {
    state = "disappearing";
    explosion(true);
    if (!forced) {
      // 星型の敵を2個生み出す
      for (int i = 0; i < 2; i++) {
        enemies.add(new StarEnemy(new PVector(random(position.x - radius * 2, position.x + radius * 2), random(position.y - radius * 2, position.y + radius * 2)), "moving", enemies, coins));
      }
    }
    createCoin(position, 2);
  }
  
  // 星型を描画する関数
  private void drawStar(float x, float y, float r, int prickleNum) {
    int vertexNum = prickleNum * 2;  // 頂点数(トゲの数*2)
    float R;  // 中心点から頂点までの距離
    float outR = r;  // 中心点からトゲまでの距離
    float inR = outR * 0.6;  // 中心点から谷までの距離
  
    pushMatrix();
    translate(x, y);
    rotate(radians(-90));
    beginShape();
    for (int i = 0; i < vertexNum; i++) {
      if (i % 2 == 0) {
        R = outR;
      } else {
        R = inR;
      }
      vertex(R * cos(radians(360 * i / vertexNum)), R * sin(radians(360 * i / vertexNum)));
    }
    endShape(CLOSE);
    popMatrix();
  }
}
// -------------------------------------------------------------------------------------------------------------------------------------------------
