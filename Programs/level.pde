
class LevelManager {
  int level;
  int coin = 0;
  int neededCoin = 0;
  int enemiesNum = 5;
  
  LevelManager() {
    level = 1;
    neededCoin = 10;
  }
  
  void draw() {
  }
  
  public boolean isLevelUpNeeded() {
    return (coin >= neededCoin);
  }
  
  public void getCoin() {
    if (coinGetable) coin ++;
    totalCoin ++;
  }
  
  // レベルアップ!
  public void levelUp() {
    level ++;
    coin = 0;
    neededCoin = (int)Math.pow(1.2, level) * 20;
    enemiesNum ++;
  }
  
  // レベルに応じた敵のリストを返す
  public int[] generateEnemiesList(int kindNum) {
    int[] enemies = new int[enemiesNum];
    
    // levelを0~1の範囲に正規化
    float normalizedLevel = map(level, 0, 30, 0, 1);
    
    for (int i = 0; i < enemiesNum; i++) {
      // 正規化されたレベルに基づいて指数的に重み付けされたランダムな値を生成
      float biasedValue = pow(random(1), normalizedLevel);
      enemies[i] = kindNum - int(biasedValue * kindNum);
    }
    return enemies;
  }
}
