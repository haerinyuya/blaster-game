
import java.util.Iterator;
import java.util.Random;

SceneManager sceneManager;

LevelManager levelManager;
ArrayList<Skill> skills;
ArrayList<Skill> selectedSkills;

int totalScore = 0;
int totalCoin = 0;

boolean parallelProcessing = true;

void setup() {
  size(1280, 720);
  PFont font = loadFont("ChakraPetch-Bold-48.vlw");
  textFont(font);
  
  sceneManager = new SceneManager();

  // シーンを生成し、SceneManagerに登録
  sceneManager.addScene("Title", new TitleScene(sceneManager));
  sceneManager.addScene("Game", new GameScene(sceneManager));
  sceneManager.addScene("GameOver", new GameOverScene(sceneManager));

  // 初期シーンを設定
  sceneManager.changeScene("Title");
}

void draw() {
  sceneManager.draw();
}

void backGroundDraw() {
  // 背景
  // 枠線外の黒塗りつぶし
  noStroke();
  fill(10, 8, 40);
  beginShape();
  vertex(0, 0);
  vertex(0, height);
  vertex(width, height);
  vertex(width, 0);
  beginContour();
  vertex(width - 295, 15);
  vertex(width - 295, height - 15);
  vertex(295, height - 15);
  vertex(295, 15);
  endContour();
  endShape(CLOSE);
  // 枠線
  stroke(110, 60, 255);
  strokeWeight(6);
  line(0, 15, width, 15);
  line(0, height - 15, width, height - 15);
  line(295, 18, 295, height - 18);
  line(width - 295, 18, width - 295, height - 18);
}

float getDistanceSq(PVector posA, PVector posB) {
  float dx = posA.x - posB.x;
  float dy = posA.y - posB.y;
  return dx * dx + dy * dy;
}


// しっぽの描画
void trailDraw(ArrayList<Trail> trail, PVector position, color col, float radius, float damping) {
  trail.add(new Trail(position, col, radius, damping));
  
  Iterator<Trail> trailIterator = trail.iterator();
  Trail previous = null;
  while (trailIterator.hasNext()) {
    Trail current = trailIterator.next();
    if (previous == null) {
      current.draw(current.position);
    } else {
      current.draw(previous.position);
    }
    if (current.radius < 1) {
      trailIterator.remove();
    }
    
    previous = current;
  }
}

// パーティクルの描画
void particleDraw(ArrayList<Particle> particles, boolean appearing) {
  Iterator<Particle> particleIterator = particles.iterator();
  while (particleIterator.hasNext()) {
    Particle particle = particleIterator.next();
    particle.draw();
    
    if (appearing) {
      // 距離が0以下なら削除
      if (particle.distance <= 0) {
          particleIterator.remove();
      }
    } else {
      // サイズが0以下なら削除
      if (particle.size <= 0) {
          particleIterator.remove();
      }
    }
  }
}
