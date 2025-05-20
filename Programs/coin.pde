
class Coin {
  PVector position;
  PVector direction;
  int value = 1;
  float radius = 4;
  float rotateRadian = 0;
  float count = 255;
  boolean isDead = false;
  
  float speed = 6;
  boolean isChasing = false;
  
  Coin(PVector position) {
    this.position = position;
    direction = new PVector(0, 0);
  }
  
  public void draw(Player player) {
    // どんどん透明になって、消える
    count -= 0.5;
    if (count <= 0) isDead = true;
    
    // ぐるぐる回ってる
    rotateRadian += PI / 90;
    if (rotateRadian > 2 * PI) rotateRadian = 0;
    
    move(player);
    
    noStroke();
    fill(110, 60, 255, count);
    drawTriangle(position.x, position.y, radius * 1.4);
  }
  
  private void move(Player player) {
    if (isChasing) {
      // playerを追いかける
      direction = PVector.sub(player.position, position).normalize();
      position = PVector.add(position, direction.setMag(speed));
    }
  }
  
  // 三角形を描画する関数
  private void drawTriangle(float x, float y, float r) {
    pushMatrix();
    
    translate(x, y);  // 中心となる座標
    rotate(rotateRadian);
  
    // 円を均等に3分割する点を結び、三角形をつくる
    beginShape();
    for (int i = 0; i < 3; i++) {
      vertex(r * cos(PI * 2 * i / 3), r * sin(PI * 2 * i / 3));
    }
    endShape(CLOSE);
  
    popMatrix();
  }
}
