
import geomerative.*;
import oscP5.*;

// Two main object
Muse muse;
NeuroFont neuroFont;

// Colors
int BLACK = color(0);
int WHITE = color(255);

int backColor = WHITE, frontColor = BLACK;

float amtColor = 0.0;
float speedColor = -0.075;
boolean lerpingColor = false;

Demo demo;

void setup () {
  //size(1344, 756);
  //size(2560, 1440);
  fullScreen();
  pixelDensity(displayDensity());
  smooth();

  RG.init(this);

  // Init main objects
  neuroFont = new NeuroFont("Roboto-Medium.ttf", 100);

  muse = new Muse(5000);
  muse.addListener(new MuseEvents());
  
  demo = new Demo();
  switchColors();
}

void draw () {
  updateFont();
  updateColors();

  demo.draw();
}

void updateFont () {
  concentration();
  mellow();
  stress();

  neuroFont.update();
}

void updateColors () {
  backColor = lerpColor(BLACK, WHITE, amtColor);
  frontColor = lerpColor(WHITE, BLACK, amtColor);

  if (lerpingColor) {
    amtColor = constrain(amtColor + speedColor, 0.0, 1.0);

    if (speedColor > 0.0 && amtColor >= 1.0) lerpingColor = false;
    if (speedColor < 0.0 && amtColor <= 0.0) lerpingColor = false;
  }
}

void concentration () {
  float concentration = muse.getConcentration();
  float segmentLen = map(concentration, 0, 100, 7.0, 4.0);
  RCommand.setSegmentLength(segmentLen);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
}

void mellow () {
  float alpha  = muse.getAlpha();
  float mellow = muse.getMellow();

  neuroFont.ampSin = map(mellow, 0, 100, 0.5, 4.0);
  neuroFont.ampCos = map(abs(alpha), 0, 1.0, 0.5, 8.0);
}

void stress () {
  float delta = muse.getDelta();
  float theta = muse.getTheta();
  float alpha = muse.getAlpha();
  float beta  = muse.getBeta();
  float gamma = muse.getGamma();

  float stress = muse.getStressLevel(alpha, beta);
  neuroFont.noiseStep  = map(abs(beta), 0.0, 1.0, 1.0, 16.0);
  neuroFont.noiseScale = map(stress, 0.0, 10.0, 1.0, 5.0);

  neuroFont.offsetX = map(abs(gamma), 0.0, 1.0, 0.03, 0.07);
  neuroFont.offsetY = map(abs(theta), 0.0, 1.0, 0.04, 0.06);
}

void switchColors () {
  lerpingColor = true;
  speedColor *= -1.0;
  amtColor = speedColor > 0.0 ? 0.0 : 1.0;
}

void keyPressed () {
  if (key == 's' || key == 'S') {
    saveFrame();
  }
}

public class MuseEvents implements MuseListener {

  void blinkEvent() {
    switchColors();
  }

  void jawClenchEvent() {
  }
}
