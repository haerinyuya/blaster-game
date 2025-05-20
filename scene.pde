class SceneManager {
  HashMap<String, Scene> scenes;
  Scene currentScene;
  
  SceneManager() {
    scenes = new HashMap<String, Scene>();
  }

  void addScene(String name, Scene scene) {
    scenes.put(name, scene);
  }

  void changeScene(String name) {
    if (name.equals("Title")) {
      scenes.put(name, new TitleScene(this)); // タイトルシーンの新しいインスタンス
    } else if (name.equals("Game")) {
      scenes.put(name, new GameScene(this)); // ゲームシーンの新しいインスタンス
    } else if (name.equals("GameOver")) {
      scenes.put(name, new GameOverScene(this)); // ゲームシーンの新しいインスタンス
    }
    currentScene = scenes.get(name);
  }

  void draw() {
    if (currentScene != null) {
      currentScene.draw();
    }
  }
}


// シーンのインターフェース----------------------------------------------------------------------------------
interface Scene {
  void draw();
  // キーが押されたときの処理
  public void keyPressed();
  // キーが離されたときの処理
  public void keyReleased();
}

// タイトルシーン-------------------------------------------------------------------------------------------
class TitleScene implements Scene {
  SceneManager sceneManager;

  TitleScene(SceneManager sceneManager) {
    this.sceneManager = sceneManager;
  }

  public void draw() {
    background(0);
    fill(255);
    textAlign(CENTER);
    text("Title", width / 2, height / 2);
    if (mousePressed) {
      sceneManager.changeScene("Game");
    }
    
    backGroundDraw();
  }
  
  // キーが押されたときの処理
  public void keyPressed() { }
  // キーが離されたときの処理
  public void keyReleased() { }
}

boolean pause = false;
boolean canPress = true;

boolean coinGetable = true;
boolean selecting = false;

// ゲームシーン---------------------------------------------------------------------------------------------
class GameScene implements Scene {
  SceneManager sceneManager;
  
  Player player;
  ArrayList<Enemy> enemies;
  ArrayList<Coin> coins;
  ArrayList<Bullet> bullets;
  
  int[] enemiesList = { };
  int bgRate = 0; //背景
  
  int count = 0;
  ArrayList<Skill> randomSkills;
  
  boolean[] isSelected = {false, false, false};

  GameScene(SceneManager sceneManager) {
    this.sceneManager = sceneManager;
    
    levelManager = new LevelManager();
    bullets = new ArrayList<Bullet>();
    player = new Player(bullets);
    coins = new ArrayList<Coin>();
    enemies = new ArrayList<Enemy>();
    
    skills = new ArrayList<Skill>();
    selectedSkills = new ArrayList<Skill>();
    
    // スキル
    skills.add(new SpeedUp());
    skills.add(new RangeUp());
    skills.add(new Magnet());
    skills.add(new DamageBoost());
    skills.add(new FireRateBoost());
    skills.add(new Wide());
    skills.add(new Multi());
    skills.add(new Nova());
    skills.add(new Spiral());
    skills.add(new Dual());
    skills.add(new Quad());
    skills.add(new Penetrate());
    skills.add(new Side());
    skills.add(new Back());
    skills.add(new MachineGun());
    
    totalScore = 0;
  }

  public void draw() {
    
    if (pause) return;
    
    background(10, 8, 40);
    
    pushMatrix();
    
    translate(width / 2, -170);
    noStroke();
    fill(20, 18, 50);
    for (int i = 0; i < 6; i ++) {
      beginShape();
      vertex(-340, i * 160 + bgRate);
      vertex(0, 80 + i * 160 + bgRate);
      vertex(340, 0 + i * 160 + bgRate);
      vertex(340, 80 + i * 160 + bgRate);
      vertex(0, 160 + i * 160 + bgRate);
      vertex(-340, 80 + i * 160 + bgRate);
      endShape(CLOSE);
    }
    bgRate += 2;
    if (bgRate == 160) {
      bgRate = 0;
    }
    
    popMatrix();
    
    // レベルアップしますか
    if (levelManager.isLevelUpNeeded()) {
      for (int i = enemies.size() - 1; i >= 0; i--) {
        enemies.get(i).delete(true);
      }
      for (int i = coins.size() - 1; i >= 0; i--) {
        coins.get(i).isChasing = true;
      }
      levelManager.coin = 0;
      coinGetable = false;
      randomSkills = getRandomSkills(skills, 3);
    }
    
    // 敵のリストを更新
    enemiesList = levelManager.generateEnemiesList(9);
    
    // 何秒かごとに敵を生成
    if (player.state.equals("moving")) {
      if (count > 180) {
        count = 0;
        spawnEnemies();
      }
    }
    
    manageEnemies();
    manageCoins();
    manageBullets();
    managePlayer();
    
    backGroundDraw();
    leftUiDraw();
    rightUiDraw();
    
    //textSize(20);
    //text("damageBoost" + player.damageBoost, width - 100, height - 200);
    //text("fireRate" + player.fireRate, width - 100, height - 300);
    
    if (coinGetable) { // 通常のゲーム時
      count++;
    } else { // レベルアップ時
      if (coins.size() == 0) {
        selecting = true;
      }
      if (selecting) {
        selectUiDraw(randomSkills);
        // スキルを選択
        if (mousePressed) {
          for (int i = 0; i < 3; i ++) {
            if (isSelected[i]) {
              selectedSkills.add(randomSkills.get(i));
              randomSkills.get(i).effect(player);
              player.updateParam();
              // 一回しか取れないやつだったら消す
              if(randomSkills.get(i).onlyOnce()) {
                for (int j = 0; j < skills.size(); j ++) {
                  if (randomSkills.get(i).getName().equals(skills.get(j).getName())) {
                    skills.remove(j);
                  }
                }
              }
              coinGetable = true;
              selecting = false;
              count = 0;
              levelManager.levelUp();
            }
          }
        }
      }
    }
  }
  
  // enemiesの処理
  private void manageEnemies() {
    Iterator<Enemy> enemyIterator = enemies.iterator();
    while (enemyIterator.hasNext()) {
      Enemy enemy = enemyIterator.next();
      enemy.draw(player);
      if (enemy.state.equals("moving")) {
        // 敵との衝突判定 (sqrtのコスト削減のために、PVector.dist()を使わず、距離の平方で判定する)
        float distanceSq = getDistanceSq(player.position, enemy.position);
        float collisionDistanceSq = (player.radius + enemy.radius) * (player.radius + enemy.radius);
        if (distanceSq < collisionDistanceSq) {
          player.state = "disappearing";
          for (int j = 0; j < 200; j++) {
            player.particles.add(new Particle(player.position, player.col, 18, false));
          }
          // 敵全削除
          Iterator<Enemy> iterator = enemies.iterator();
          while (iterator.hasNext()) {
              Enemy e = iterator.next();
              e.delete(true);
          }
          return;
        }
      }
      // 死んでたらリストから削除
      if (enemy.isDead) {
        enemyIterator.remove();
      }
    }
  }
  
  // coinsの処理
  private void manageCoins() {
    Iterator<Coin> coinIterator = coins.iterator();
    while (coinIterator.hasNext()) {
      Coin coin = coinIterator.next();
      // 更新
      coin.draw(player);
      // 取りましたか (sqrtのコスト削減のために、PVector.dist()を使わず、距離の平方で判定する)
      float distanceSq = getDistanceSq(player.position, coin.position);
      float collisionDistanceSq = player.radius * player.radius; // ほんとはcoinのradiusを足さないといけないけど、小さいから無視する
      if (distanceSq < collisionDistanceSq) {
        levelManager.getCoin();
        coinIterator.remove();
        continue;
      }
      // 吸収できる範囲ですか
      if (distanceSq < player.magRange * player.magRange) {
        coin.isChasing = true;
        continue;
      }
    }
  }
  
  // bulletの処理
  private void manageBullets() {
    Iterator<Bullet> bulletIterator = bullets.iterator();
    while (bulletIterator.hasNext()) {
      Bullet bullet = bulletIterator.next();
      bullet.draw();
      if (bullet.isMoving) {
        Iterator<Enemy> enemyIterator = enemies.iterator();
        while (enemyIterator.hasNext()) {
          Enemy enemy = enemyIterator.next();
          if (enemy.state.equals("moving")) {
            // 敵との衝突判定 (sqrtのコスト削減のために、PVector.dist()を使わず、距離の平方で判定する)
            float distanceSq = getDistanceSq(bullet.position, enemy.position);
            float collisionDistanceSq = (bullet.radius + enemy.radius) * (bullet.radius + enemy.radius);
            if (distanceSq < collisionDistanceSq) {
              enemy.hit(player.damage);
              bullet.delete();
              break;
            }
          }
        }
      }
      
      // 削除
      if (bullet.isDead) {
          bulletIterator.remove();
      }
    }
  }
  
  // playerの処理
  private void managePlayer() {
    player.draw(enemies);
    
    // プレイヤーが死んだらゲームオーバー
    if (player.isDead && enemies.size() == 0){
      sceneManager.changeScene("GameOver");
      return;
    }
  }
  
  private ArrayList<Skill> getRandomSkills(ArrayList<Skill> skills, int count) {
    ArrayList<Skill> result = new ArrayList<Skill>();
    Random random = new Random();

    // 重複を防ぐための一時リスト
    ArrayList<Skill> itemList = new ArrayList<Skill>(skills);

    for (int i = 0; i < count; i++) {
        if (itemList.isEmpty()) break; // 要素がなくなったら終了

        // 優先順位に基づいて1つ選択
        Skill selected = getWeightedRandomItem(itemList, random);
        result.add(selected);
        itemList.remove(selected); // 選ばれた要素を除外
    }
    return result;
  }
  
  // 優先順位に基づいて1つの要素をランダムに選択
  public Skill getWeightedRandomItem(ArrayList<Skill> skills, Random random) {
    // 優先順位の合計を計算
    int totalWeight = skills.stream().mapToInt(item -> item.getWeight()).sum();

    // 0からtotalPriorityの間でランダムな値を生成
    int randomValue = random.nextInt(totalWeight);

    // ランダム値がどの要素に該当するかを探す
    int cumulativeWeight = 0;
    for (Skill skill : skills) {
        cumulativeWeight += skill.getWeight();
        if (randomValue < cumulativeWeight) {
            return skill;
        }
      }

      return skills.get(skills.size() - 1);
  }
  
  // 敵を生成するメソッド
  private void spawnEnemies() {
    for (int i = 0; i < enemiesList.length; i++) {
      int num = enemiesList[i];
      switch (num) {
        case 1:
          enemies.add(new CircleEnemy(enemies, coins));
          break;
          
        case 2:
          enemies.add(new TriangleEnemy(enemies, coins));
          break;
          
        case 3:
          enemies.add(new ArrowEnemy(enemies, coins));
          break;
          
        case 4:
          enemies.add(new MsizeRectEnemy(enemies, coins));
          break;
          
        case 5:
          enemies.add(new MsizeTriangleEnemy(enemies, coins));
          break;
          
        case 6:
          enemies.add(new StarEnemy(enemies, coins));
          break;
          
        case 7:
          enemies.add(new LsizeRectEnemy(enemies, coins));
          break;
          
        case 8:
        enemies.add(new FishEnemy(enemies, coins));
          break;
          
        case 9:
        enemies.add(new SpikyEnemy(enemies, coins));
          break;
          
        default:
          break;
      }
    }
  }
  
  // スキル選択
  private void selectUiDraw(ArrayList<Skill> skills) {
    
    pushMatrix();
    translate(width / 2, height / 2);
    textAlign(CENTER);
    fill(110, 60, 255);
    textSize(50);
    text("Select The Skill", 0, -160);
    noStroke();
    rectMode(CENTER);
    textSize(24);
    
    for (int i = 0; i < 3; i ++) {
      var posX = (i - 1) * 224;
      var col = color(210, 210, 255, 80);
      
      isSelected[i] = false;
      if (254 <= mouseY && mouseY <= 510) {
        if (310 + i * 224 <= mouseX && mouseX <= 522 + i * 224) {
          isSelected[i] = true;
          col = color(210, 210, 255, 110);
        }
      }
      
      pushMatrix();
      translate(posX, 0);
      noStroke();
      // 外枠
      fill(col);
      rect(0, 22, 212, 256, 14);
      // スキル名
      fill(210, 210, 255);
      text(skills.get(i).getName(), 0, 134);
      //text("Fire Rate Boost", 0, 132);
      // スキルの画像
      noFill();
      strokeWeight(2);
      stroke(210, 210, 255, 120);
      rect(0, 0, 188, 188, 8);
      popMatrix();
    }
    popMatrix();
  }
  
  // 左側のUI
  private void leftUiDraw() {
    pushMatrix();
    translate(0, 30);
    
    fill(210, 210, 255);
    textAlign(CENTER);
    textSize(40);
    // LEVEL
    text("LEVEL", 110, 120);
    // SCORE
    text("SCORE", 110, 280);
    
    // 現在のレベル
    textAlign(RIGHT);
    text(levelManager.level, 190, 190);
    // 現在のスコア
    textSize(30);
    text(totalScore, 200, 340);
    // 現在の合計コイン数
    text(totalCoin, 200, 490);
    
    // 線
    stroke(50, 35, 110);
    strokeWeight(3);
    line(10, 140, 210, 140);
    line(10, 300, 210, 300);
    line(10, 450, 210, 450);
    
    // 三角形
    pushMatrix();
    noStroke();
    fill(110, 60, 255);
    translate(110, 420);
    rotate(-HALF_PI);
    beginShape();
    for (int i = 0; i < 3; i++) {
      vertex(20 * cos(PI * 2 * i / 3), 20 * sin(PI * 2 * i / 3));
    }
    endShape(CLOSE);
    popMatrix();
    
    popMatrix();
    
    // レベルアップゲージ(外枠)
    rectMode(CENTER);
    noStroke();
    fill(50, 35, 110);
    rect(250, height / 2, 60, height - 100, 14);
    // 枠
    rectMode(CORNERS);
    rect(70, height - 120, 275, height - 50, 14);
    pushMatrix();
    textSize(24);
    translate(30, height - 84);
    rotate(HALF_PI);
    textAlign(CENTER);
    text("GAGE", 0, 0);
    popMatrix();
    
    // レベルアップゲージ(中身)
    fill(110, 60, 255);
    var topPos = height - ((float)levelManager.coin / (float)levelManager.neededCoin) * (height - 120) - 60;
    rect(230, topPos, 270, height - 60, 8);
    // 何%表示
    var percent = float(round(((float)levelManager.coin / (float)levelManager.neededCoin) * 1000)) / 10;
    textSize(36);
    text(percent + "%", 146, height - 72);
  }
  
  private void rightUiDraw() {
    if (selectedSkills.size() < 1) {
      return;
    }
    textSize(20);
    textAlign(LEFT);
    noStroke();
    fill(210, 210, 255);
    for (int i = 0; i < selectedSkills.size(); i ++) {
      text(selectedSkills.get(i).getName(), width - 270, 50 + i * 24);
    }
  }
  
  // キーが押されたときの処理
  public void keyPressed() {
    if (player != null) {
      if (key == 'w' || key == 'W') player.moveUp = true;
      if (key == 's' || key == 'S') player.moveDown = true;
      if (key == 'a' || key == 'A') player.moveLeft = true;
      if (key == 'd' || key == 'D') player.moveRight = true;
      if (canPress) {
        if (key == 'p' || key == 'P') {
          pause = !pause;
          canPress = false;
        }
      }
    }
  }
  
  // キーが離されたときの処理
  public void keyReleased() {
    if (player != null) {
      if (key == 'w' || key == 'W') player.moveUp = false;
      if (key == 's' || key == 'S') player.moveDown = false;
      if (key == 'a' || key == 'A') player.moveLeft = false;
      if (key == 'd' || key == 'D') player.moveRight = false;
      if (key == 'p' || key == 'P') canPress = true;
    }
  }
}

// ゲームオーバーシーン-------------------------------------------------------------------------------------------
class GameOverScene implements Scene {
  SceneManager sceneManager;
  
  GameOverScene(SceneManager sceneManager) {
    this.sceneManager = sceneManager;
  }
  
  public void draw() {
    background(0);
    fill(255);
    textAlign(CENTER);
    text("GameOver", width / 2, height / 2);
    if(mousePressed) {
      sceneManager.changeScene("Title");
    }
    
    backGroundDraw();
  }
  
  // キーが押されたときの処理
  public void keyPressed() { }
  // キーが離されたときの処理
  public void keyReleased() { }
}
