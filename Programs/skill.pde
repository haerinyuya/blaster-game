
class Boost {
  int damageBoost = 0;
  int fireRateBoost = 0;
  
  Boost(int damageBoost, int fireRateBoost) {
    this.damageBoost = damageBoost;
    this.fireRateBoost = fireRateBoost;
  }
  
  void apply(Player player) {
    player.damageBoost += damageBoost;
    player.fireRate += fireRateBoost;
  }
}

// スキルの親クラス
abstract class Skill {
  protected String name;
  protected Boost boost;
  protected int weight;
  
  abstract void effect(Player player);
  
  abstract boolean onlyOnce();
  
  public String getName() {
    return name;
  }
  
  public int getWeight() {
    return weight;
  }
}

// speed up-------------------------------------------------------
class SpeedUp extends Skill {
  SpeedUp() {
    name = "Speed Up";
    boost = new Boost(0, 0);
    weight = 4;
  }
  
  void effect(Player player) {
    player.speed += 1;
  }
  
  boolean onlyOnce() {
    return true;
  }
}

// range up-------------------------------------------------------
class RangeUp extends Skill {
  RangeUp() {
    name = "Range Up";
    boost = new Boost(0, 0);
    weight = 10;
  }
  
  void effect(Player player) {
    player.range += 40;
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// magnet-------------------------------------------------------
class Magnet extends Skill {
  Magnet() {
    name = "Magnet";
    boost = new Boost(0, 0);
    weight = 10;
  }
  
  void effect(Player player) {
    player.magRange += 30;
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// damage boost-------------------------------------------------------
class DamageBoost extends Skill {
  DamageBoost() {
    name = "Damage Boost";
    boost = new Boost(1, 0); // ダメージが増加、連射力は変化なし
    weight = 8;
  }
  
  void effect(Player player) {
    boost.apply(player);
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// fire rate boost----------------------------------------------------
class FireRateBoost extends Skill {
  FireRateBoost() {
    name = "Fire Rate Boost";
    boost = new Boost(0, 1); // ダメージは変化なし、連射力は向上
    weight = 8;
  }
  
  void effect(Player player) {
    boost.apply(player);
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// wide shot----------------------------------------------------------
class Wide extends Skill {
  Wide() {
    name = "Wide Shot";
    boost = new Boost(0, -3); // ダメージは変化なし、連射力がとても大きく低下
    weight = 3;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.wide ++;
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// multi shot---------------------------------------------------------
class Multi extends Skill {
  Multi() {
    name = "Multi Shot";
    boost = new Boost(0, -2); // ダメージは変化なし、連射力が大きく低下
    weight = 2;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.multi ++;
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// nova shot----------------------------------------------------------
class Nova extends Skill {
  Nova() {
    name = "Nova";
    boost = new Boost(0, 0); // 変化なし
    weight = 6;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.nova ++;
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// spiral shot--------------------------------------------------------
class Spiral extends Skill {
  Spiral() {
    name = "Spiral";
    boost = new Boost(0, 0); // 変化なし
    weight = 5;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.spiral ++;
  }
  
  boolean onlyOnce() {
    return false;
  }
}

// dual shot----------------------------------------------------------
class Dual extends Skill {
  Dual() {
    name = "Dual Shot";
    boost = new Boost(0, -1); // ダメージは変化なし、連射力が低下
    weight = 1;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.bulletNum += 2;
  }
  
  boolean onlyOnce() {
    return true;
  }
}

// quad shot----------------------------------------------------------
class Quad extends Skill {
  Quad() {
    name = "Quad Shot";
    boost = new Boost(-1, -2); // ダメージが減少、連射力が大きく低下
    weight = 1;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.bulletNum += 4;
  }
  
  boolean onlyOnce() {
    return true;
  }
}

// penetrate----------------------------------------------------------
class Penetrate extends Skill {
  Penetrate() {
    name = "Penetrate";
    boost = new Boost(0, -2); // ダメージは変化なし、連射力が大きく低下
    weight = 1;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.penetrate = true;
  }
  
  boolean onlyOnce() {
    return true;
  }
}

// side shot----------------------------------------------------------
class Side extends Skill {
  Side() {
    name = "Side Shot";
    boost = new Boost(0, 0); // 変化なし
    weight = 4;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.side = true;
  }
  
  boolean onlyOnce() {
    return true;
  }
}

// back shot----------------------------------------------------------
class Back extends Skill {
  Back() {
    name = "Back Shot";
    boost = new Boost(0, 0); // 変化なし
    weight = 4;
  }
  
  void effect(Player player) {
    boost.apply(player);
    player.back = true;
  }
  
  boolean onlyOnce() {
    return true;
  }
}

// machine gun----------------------------------------------------------
class MachineGun extends Skill {
  MachineGun() {
    name = "Machine Gun";
    boost = new Boost(-1, 2); // ダメージが減少、連射力が大きく向上
    weight = 1;
  }
  
  void effect(Player player) {
    boost.apply(player);
  }
  
  boolean onlyOnce() {
    return true;
  }
}
