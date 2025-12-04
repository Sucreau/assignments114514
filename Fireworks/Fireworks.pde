import java.util.ArrayList;

ArrayList<Firework> fireworks = new ArrayList<Firework>();
ArrayList<Star> stars = new ArrayList<Star>();
float bgBrightness = 0;

void setup() {
  size(800, 600);
  colorMode(HSB, 360, 100, 100, 100);
  noStroke();
  
  // 初始化星星
  createStars(150);
}

void draw() {
  // 背景颜色随着烟花爆炸变亮再恢复
  background(230, 80, 10 + bgBrightness); // 深蓝色背景
  
  // 背景亮度逐渐恢复
  if (bgBrightness > 0) {
    bgBrightness *= 0.9;
    if (bgBrightness < 0.5) bgBrightness = 0;
  }
  
  // 显示星星
  for (Star star : stars) {
    star.display();
  }
  
  // 更新和显示所有烟花
  for (int i = fireworks.size() - 1; i >= 0; i--) {
    Firework fw = fireworks.get(i);
    fw.update();
    fw.display();
    
    // 移除已经消失的烟花
    if (fw.isDead()) {
      fireworks.remove(i);
    }
  }
}

void createStars(int count) {
  for (int i = 0; i < count; i++) {
    stars.add(new Star());
  }
}

void mousePressed() {
  // 创建上升的火苗
  fireworks.add(new RisingFlame(mouseX, mouseY));
}

// 星星类
class Star {
  float x, y;
  float size;
  float brightness;
  
  Star() {
    this.x = random(width);
    this.y = random(height);
    this.size = random(0.5, 2.5);
    this.brightness = random(60, 100);
  }
  
  void display() {
    fill(0, 0, brightness);
    ellipse(x, y, size, size);
  }
}

// 基类 Firework
abstract class Firework {
  boolean dead = false;
  
  boolean isDead() {
    return dead;
  }
  
  // 声明抽象方法
  abstract void update();
  abstract void display();
}

class RisingFlame extends Firework {
  float x, y;
  float speed;
  float targetY;
  color flameColor;
  float size = 4;
  float alpha = 100;
  
  RisingFlame(float startX, float startY) {
    this.x = startX;
    this.y = startY;
    this.speed = random(5, 8); // 增加上升速度
    
    // 随机选择烟花颜色
    flameColor = color(random(360), 80, 100);
    
    // 随机确定爆炸高度（高于鼠标位置）
    targetY = random(50, height/2);
  }
  
  void update() {
    y -= speed;
    
    // 到达目标高度时爆炸
    if (y <= targetY) {
      explode();
      dead = true;
    }
  }
  
  void explode() {
    // 创建爆炸烟花并添加到列表中
    fireworks.add(new ExplodingFirework(x, y, flameColor));
    
    // 使背景变亮
    bgBrightness = 30;
  }
  
  void display() {
    fill(flameColor, alpha);
    ellipse(x, y, size, size * 2);
    
    // 尾迹效果
    for (int i = 0; i < 5; i++) {
      float trailY = y + i * 4;
      float trailAlpha = alpha * (1 - i * 0.2);
      float trailSize = size * (1 - i * 0.15);
      fill(flameColor, trailAlpha);
      ellipse(x, trailY, trailSize * 0.7, trailSize * 1.5);
    }
  }
}

class ExplodingFirework extends Firework {
  float x, y;
  ArrayList<Particle> particles = new ArrayList<Particle>();
  ArrayList<GlowEffect> glows = new ArrayList<GlowEffect>();
  float explodeTime;
  float duration = 2000; // 2秒持续时间
  color baseColor;
  
  ExplodingFirework(float x, float y, color baseColor) {
    this.x = x;
    this.y = y;
    this.baseColor = baseColor;
    this.explodeTime = millis();
    
    // 创建爆炸粒子
    int particleCount = 120;
    for (int i = 0; i < particleCount; i++) {
      particles.add(new Particle(x, y, baseColor));
    }
    
    // 创建发光效果
    glows.add(new GlowEffect(x, y, baseColor, 80));
    glows.add(new GlowEffect(x, y, baseColor, 120));
  }
  
  void update() {
    // 检查是否超过持续时间
    if (millis() - explodeTime > duration) {
      dead = true;
      return;
    }
    
    // 更新所有粒子
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      
      // 移除不可见的粒子
      if (p.alpha <= 0) {
        particles.remove(i);
      }
    }
    
    // 更新发光效果
    for (int i = glows.size() - 1; i >= 0; i--) {
      GlowEffect glow = glows.get(i);
      glow.update();
      if (glow.alpha <= 0) {
        glows.remove(i);
      }
    }
    
    // 检查是否所有粒子都消失了
    if (particles.size() == 0 && glows.size() == 0) {
      dead = true;
    }
  }
  
  void display() {
    // 显示发光效果
    for (GlowEffect glow : glows) {
      glow.display();
    }
    
    // 显示粒子
    for (Particle p : particles) {
      p.display();
    }
  }
}

class Particle {
  float x, y;
  float vx, vy;
  float gravity = 0.1;
  float alpha;
  color particleColor;
  float size;
  float decayRate;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  int maxTrailLength = 8;
  
  Particle(float startX, float startY, color baseColor) {
    this.x = startX;
    this.y = startY;
    
    // 随机方向速度
    float angle = random(TWO_PI);
    float speed = random(3, 8); // 稍微增加速度
    this.vx = cos(angle) * speed;
    this.vy = sin(angle) * speed;
    
    // 基于基础颜色生成相似颜色
    float hue = hue(baseColor) + random(-20, 20);
    float saturation = saturation(baseColor) + random(-10, 10);
    float brightness = brightness(baseColor) + random(-20, 20);
    
    // 限制颜色范围
    hue = constrain(hue, 0, 360);
    saturation = constrain(saturation, 60, 100);
    brightness = constrain(brightness, 70, 100);
    
    this.particleColor = color(hue, saturation, brightness);
    this.alpha = 100;
    this.size = random(3, 8);
    this.decayRate = random(0.8, 2.0);
  }
  
  void update() {
    // 保存当前位置到尾迹
    trail.add(0, new PVector(x, y));
    if (trail.size() > maxTrailLength) {
      trail.remove(trail.size() - 1);
    }
    
    // 应用重力
    vy += gravity;
    
    // 更新位置
    x += vx;
    y += vy;
    
    // 空气阻力
    vx *= 0.98;
    vy *= 0.98;
    
    // 透明度衰减
    alpha -= decayRate;
    if (alpha < 0) alpha = 0;
  }
  
  void display() {
    // 显示尾迹
    for (int i = 0; i < trail.size(); i++) {
      PVector pos = trail.get(i);
      float trailAlpha = alpha * (1 - (float)i / trail.size()) * 0.5;
      float trailSize = size * (1 - (float)i / trail.size() * 0.3);
      fill(particleColor, trailAlpha);
      ellipse(pos.x, pos.y, trailSize, trailSize);
    }
    
    // 显示粒子本身
    fill(particleColor, alpha);
    ellipse(x, y, size, size);
  }
}

// 发光效果类
class GlowEffect {
  float x, y;
  color glowColor;
  float size;
  float alpha;
  float decayRate;
  
  GlowEffect(float x, float y, color baseColor, float size) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.alpha = 80;
    this.decayRate = random(1.0, 2.0);
    
    // 创建发光颜色（比基础颜色更亮）
    float hue = hue(baseColor);
    float saturation = saturation(baseColor) * 0.7;
    float brightness = min(brightness(baseColor) + 20, 100);
    this.glowColor = color(hue, saturation, brightness);
  }
  
  void update() {
    alpha -= decayRate;
    if (alpha < 0) alpha = 0;
  }
  
  void display() {
    // 使用多个同心圆模拟发光效果
    for (int i = 0; i < 3; i++) {
      float glowSize = size * (1 + i * 0.3);
      float glowAlpha = alpha * (1 - i * 0.3);
      fill(glowColor, glowAlpha * 0.3);
      ellipse(x, y, glowSize, glowSize);
    }
  }
}
