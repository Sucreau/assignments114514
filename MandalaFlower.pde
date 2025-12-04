void setup() {
  size(800, 800);
  noLoop();
  smooth();
  colorMode(HSB, 360, 100, 100, 100);
}

void draw() {
  background(0);
  
  // 先绘制背景效果
  drawBackgroundEffects();
  
  translate(width/2, height/2);
  
  randomSeed(millis());
  
  // 随机参数
  int layerCount = (int)random(4, 7); // 4-6层花瓣
  float baseHue = random(360); // 基础色调
  
  // 绘制中心
  drawCenter(random(40, 100));
  
  // 绘制多层花瓣，每层形态随机
  for (int layer = 0; layer < layerCount; layer++) {
    drawRandomFlowerLayer(layer, layerCount, baseHue);
  }
}

void drawBackgroundEffects() {
  // 中心发光效果
  drawGlowEffect();
  
  // 随机光线
  drawLightRays();
  
  // 粒子效果
  drawParticles();
}

void drawGlowEffect() {
  // 获取花朵基础色调（在绘制花朵前先确定）
  float baseHue = random(360);
  randomSeed(millis()); // 重置随机种子
  
  pushMatrix();
  translate(width/2, height/2);
  
  // 多层径向渐变发光
  int glowLayers = 8;
  float maxGlowRadius = width * 0.8;
  
  for (int i = glowLayers; i > 0; i--) {
    float radius = map(i, 0, glowLayers, maxGlowRadius * 0.3, maxGlowRadius);
    float alpha = map(i, 0, glowLayers, 2, 0.5); // 非常低的透明度
    float hue = (baseHue + i * 10) % 360;
    
    noStroke();
    fill(hue, 40, 30, alpha); // 低饱和度，低亮度
    
    // 创建柔和的发光效果
    for (int j = 0; j < 3; j++) {
      float glowRadius = radius * (1 - j * 0.1);
      ellipse(0, 0, glowRadius * 2, glowRadius * 2);
    }
  }
  
  popMatrix();
}

void drawLightRays() {
  pushMatrix();
  translate(width/2, height/2);
  
  int rayCount = (int)random(3, 8); // 少量光线
  float maxRayLength = width * 0.6;
  float baseHue = random(360);
  
  for (int i = 0; i < rayCount; i++) {
    float angle = random(TWO_PI);
    float rayLength = maxRayLength * random(0.7, 1.0);
    float rayWidth = random(2, 8);
    float hue = (baseHue + i * 30) % 360;
    float alpha = random(3, 8); // 非常低的透明度
    
    pushMatrix();
    rotate(angle);
    
    // 光线渐变
    for (float r = 0; r < rayLength; r += rayWidth * 0.5) {
      float progress = r / rayLength;
      float currentAlpha = alpha * (1 - progress * 0.7);
      float currentWidth = rayWidth * (1 - progress * 0.3);
      
      stroke(hue, 50, 60, currentAlpha);
      strokeWeight(currentWidth);
      
      line(r, 0, r + rayWidth * 1.5, 0);
    }
    
    popMatrix();
  }
  
  popMatrix();
}

void drawParticles() {
  pushMatrix();
  translate(width/2, height/2);
  
  int particleCount = (int)random(15, 30); // 保持原有数量
  float baseHue = random(360);
  float maxParticleDistance = width * 0.45;
  
  for (int i = 0; i < particleCount; i++) {
    float angle = random(TWO_PI);
    // 使粒子多在外侧生成：最小距离设为最大距离的60%
    float minDistance = maxParticleDistance * 0.6;
    float distance = random(minDistance, maxParticleDistance);
    float size = random(2, 6); // 略微放大粒子
    float hue = (baseHue + random(60)) % 360;
    float alpha = random(15, 25); // 略微提高透明度
    
    pushMatrix();
    rotate(angle);
    translate(distance, 0);
    
    // 随机粒子形状
    noStroke();
    fill(hue, 60, 80, alpha);
    
    if (random(1) > 0.3) {
      // 大部分是圆形粒子
      ellipse(0, 0, size, size);
      
      // 为一些圆形粒子添加光晕效果
      if (random(1) > 0.7) {
        fill(hue, 40, 90, alpha * 0.3);
        ellipse(0, 0, size * 1.8, size * 1.8);
      }
    } else {
      // 少量星形粒子，也略微放大
      drawTinyStar(0, 0, size * 1.2, alpha);
    }
    
    popMatrix();
  }
  
  popMatrix();
}

void drawTinyStar(float x, float y, float size, float alpha) {
  // 绘制小星星
  pushMatrix();
  translate(x, y);
  
  float hue = random(360);
  fill(hue, 70, 90, alpha);
  noStroke();
  
  beginShape();
  for (int i = 0; i < 5; i++) {
    float angle = map(i, 0, 5, 0, TWO_PI);
    float radius = size;
    vertex(cos(angle) * radius, sin(angle) * radius);
    
    angle += PI / 5;
    radius = size * 0.4;
    vertex(cos(angle) * radius, sin(angle) * radius);
  }
  endShape(CLOSE);
  
  popMatrix();
}

void drawCenter(float radius) {
  // 中心圆形渐变
  for (float r = radius; r > 0; r -= 4) {
    float alpha = map(r, 0, radius, 150, 20);
    float hue = random(30, 60); // 中心使用暖色调
    fill(hue, 50, 90, alpha);
    noStroke();
    ellipse(0, 0, r*2, r*2);
  }
}

void drawRandomFlowerLayer(int layer, int totalLayers, float baseHue) {
  // 随机选择花瓣形态类型
  int petalType = (int)random(4); // 0-3 四种不同形态
  
  // 计算当前层参数
  float layerProgress = float(layer) / totalLayers;
  int petals = (int)random(6, 20); // 随机花瓣数量
  float startRadius = 50 + layer * 40;
  float maxLength = 120 + layer * 60;
  
  // 更大的颜色差异，但仍保持渐变规律
  float hueShift = layer * 60 + random(-20, 20); // 每层60度色相变化
  float layerHue = (baseHue + hueShift) % 360;
  float saturation = 50 + random(40);
  float brightness = 70 + random(25);
  
  // 随机透明度范围
  float minAlpha = random(10, 30);
  float maxAlpha = random(40, 80);
  
  // 根据随机类型绘制不同形态的花瓣层
  switch(petalType) {
    case 0:
      drawCurvedPetals(layer, petals, startRadius, maxLength, layerHue, saturation, brightness, minAlpha, maxAlpha);
      break;
    case 1:
      drawSpiralPetals(layer, petals, startRadius, maxLength, layerHue, saturation, brightness, minAlpha, maxAlpha);
      break;
    case 2:
      drawWavyPetals(layer, petals, startRadius, maxLength, layerHue, saturation, brightness, minAlpha, maxAlpha);
      break;
    case 3:
      drawFeatherPetals(layer, petals, startRadius, maxLength, layerHue, saturation, brightness, minAlpha, maxAlpha);
      break;
  }
}

void drawCurvedPetals(int layer, int petals, float startRadius, float length, 
                     float hue, float saturation, float brightness, float minAlpha, float maxAlpha) {
  // 经典弯曲花瓣形态
  for (int i = 0; i < petals; i++) {
    float angle = map(i, 0, petals, 0, TWO_PI);
    pushMatrix();
    rotate(angle);
    
    float curveStrength = random(0.2, 0.5);
    float petalLength = length * random(0.8, 1.2);
    float alpha = map(i, 0, petals, minAlpha, maxAlpha);
    
    // 贝塞尔曲线花瓣
    noStroke();
    fill(hue, saturation, brightness, alpha);
    
    beginShape();
    vertex(startRadius, 0);
    bezierVertex(
      startRadius + petalLength * 0.3, -petalLength * curveStrength,
      startRadius + petalLength * 0.7, -petalLength * curveStrength * 0.3,
      startRadius + petalLength, 0
    );
    bezierVertex(
      startRadius + petalLength * 0.7, petalLength * curveStrength * 0.3,
      startRadius + petalLength * 0.3, petalLength * curveStrength,
      startRadius, 0
    );
    endShape();
    
    popMatrix();
  }
}

void drawSpiralPetals(int layer, int petals, float startRadius, float length, 
                     float hue, float saturation, float brightness, float minAlpha, float maxAlpha) {
  // 螺旋状排列的花瓣
  float spiralTightness = random(0.1, 0.3);
  
  for (int i = 0; i < petals; i++) {
    float baseAngle = map(i, 0, petals, 0, TWO_PI);
    float spiralOffset = i * spiralTightness;
    float angle = baseAngle + spiralOffset;
    
    pushMatrix();
    rotate(angle);
    
    float petalLength = length * (0.7 + 0.3 * sin(i * 0.5)); // 波浪长度变化
    float alpha = minAlpha + (maxAlpha - minAlpha) * sin(i * 0.8); // 波浪透明度变化
    
    // 椭圆形花瓣
    fill(hue, saturation, brightness, alpha);
    noStroke();
    ellipse(startRadius + petalLength * 0.5, 0, petalLength, petalLength * 0.3);
    
    // 添加细节线条
    stroke(hue, saturation, brightness, alpha * 0.5);
    strokeWeight(1);
    line(startRadius, 0, startRadius + petalLength, 0);
    
    popMatrix();
  }
}

void drawWavyPetals(int layer, int petals, float startRadius, float length, 
                   float hue, float saturation, float brightness, float minAlpha, float maxAlpha) {
  // 波浪形边缘的花瓣
  for (int i = 0; i < petals; i++) {
    float angle = map(i, 0, petals, 0, TWO_PI);
    pushMatrix();
    rotate(angle);
    
    float waveFreq = random(2, 5);
    float petalLength = length * random(0.9, 1.1);
    float alpha = random(minAlpha, maxAlpha);
    
    // 波浪形花瓣
    noStroke();
    fill(hue, saturation, brightness, alpha);
    
    beginShape();
    vertex(startRadius, 0);
    // 创建波浪边缘
    for (int j = 0; j <= 10; j++) {
      float progress = float(j) / 10;
      float x = startRadius + petalLength * progress;
      float wave = sin(progress * PI * waveFreq) * petalLength * 0.1;
      float y = wave * (j <= 5 ? -1 : 1); // 上半部向下，下半部向上
      vertex(x, y);
    }
    vertex(startRadius, 0);
    endShape();
    
    popMatrix();
  }
}

void drawFeatherPetals(int layer, int petals, float startRadius, float length, 
                      float hue, float saturation, float brightness, float minAlpha, float maxAlpha) {
  // 羽毛状细长花瓣
  for (int i = 0; i < petals; i++) {
    float angle = map(i, 0, petals, 0, TWO_PI);
    pushMatrix();
    rotate(angle);
    
    float featherCount = (int)random(3, 8);
    float petalLength = length * random(0.7, 1.3);
    float alpha = map(i, 0, petals, maxAlpha, minAlpha); // 反向透明度渐变
    
    // 多个细长羽毛组成一个花瓣
    for (int f = 0; f < featherCount; f++) {
      float featherOffset = map(f, 0, featherCount, -petalLength * 0.2, petalLength * 0.2);
      float featherLength = petalLength * random(0.6, 0.9);
      float featherAlpha = alpha * random(0.7, 1.0);
      
      stroke(hue, saturation, brightness, featherAlpha);
      strokeWeight(random(1, 3));
      noFill();
      
      // 羽毛状曲线
      bezier(
        startRadius, featherOffset,
        startRadius + featherLength * 0.3, featherOffset - featherLength * 0.1,
        startRadius + featherLength * 0.7, featherOffset + featherLength * 0.1,
        startRadius + featherLength, featherOffset
      );
    }
    
    popMatrix();
  }
}

// 点击鼠标重新生成
void mousePressed() {
  redraw();
}

// 按空格键保存图片
void keyPressed() {
  if (key == ' ') {
    save("abstract_flower_" + year() + month() + day() + hour() + minute() + second() + ".png");
  }
}
