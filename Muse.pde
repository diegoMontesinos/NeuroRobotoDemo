
public class Muse {

  // OSC Spec from https://musemonitor.com/FAQ.php#oscspec
  String BATTERY    = "/muse/batt";
  String DELTA_ABS  = "/muse/elements/delta_absolute";
  String THETA_ABS  = "/muse/elements/theta_absolute";
  String ALHA_ABS   = "/muse/elements/alpha_absolute";
  String BETA_ABS   = "/muse/elements/beta_absolute";
  String GAMMA_ABS  = "/muse/elements/gamma_absolute";
  String MELLOW     = "/muse/algorithm/mellow";
  String CONCENTRA  = "/muse/algorithm/concentration";
  String HORSESHOE  = "/muse/elements/horseshoe";
  String TOUCHING   = "/muse/elements/touching_forehead";
  String BLINK      = "/muse/elements/blink";
  String JAW_CLENCH = "/muse/elements/jaw_clench";

  private OscP5 osc;

  public MuseStatus status;

  // Buffer and average
  private int BUFFER_SIZE = 120;

  // Signals
  public ArrayList<Float> delta;
  public ArrayList<Float> theta;
  public ArrayList<Float> alpha;
  public ArrayList<Float> beta;
  public ArrayList<Float> gamma;

  // Algorithm
  public ArrayList<Float> mellow;
  public ArrayList<Float> concentration;

  // Listeners
  private ArrayList<MuseListener> listeners;

  public Muse (int port) {
    osc = new OscP5(this, port);
    status = new MuseStatus();

    delta = new ArrayList<Float>();
    theta = new ArrayList<Float>();
    alpha = new ArrayList<Float>();
    beta  = new ArrayList<Float>();
    gamma = new ArrayList<Float>();

    mellow = new ArrayList<Float>();
    concentration = new ArrayList<Float>();

    listeners = new ArrayList<MuseListener>();
  }

  public void addListener(MuseListener toAdd) {
    listeners.add(toAdd);
  }

  private boolean isType (OscMessage message, String type) {
    return message.checkAddrPattern(type);
  }

  void oscEvent (OscMessage message) {

    // Check status
    if (isType(message, BATTERY)) this.handleBatteryMessage(message);
    if (isType(message, TOUCHING)) this.handleTouchingMessage(message);
    if (isType(message, HORSESHOE)) this.handleHorseshoeMessage(message);

    // Data
    if (isType(message, DELTA_ABS)) this.handleDataMessage(message, delta);
    if (isType(message, THETA_ABS)) this.handleDataMessage(message, theta);
    if (isType(message, ALHA_ABS))  this.handleDataMessage(message, alpha);
    if (isType(message, BETA_ABS))  this.handleDataMessage(message, beta);
    if (isType(message, GAMMA_ABS)) this.handleDataMessage(message, gamma);

    // Algorithms
    if (isType(message, MELLOW)) this.handleDataMessage(message, mellow);
    if (isType(message, CONCENTRA)) this.handleDataMessage(message, concentration);

    // Events
    if (isType(message, BLINK)) this.handleBlinkMessage(message);
    if (isType(message, JAW_CLENCH)) this.handleJawClenchMessage(message);
  }

  private void handleBatteryMessage (OscMessage message) {
    if (!message.checkTypetag("iiii")) return;

    int level = message.get(0).intValue();
    this.status.batteryLevel = level / 100.0;
  }

  private void handleHorseshoeMessage (OscMessage message) {
    if (!message.checkTypetag("ffff")) return;

    int tp9 = int(message.get(0).floatValue());
    int af7 = int(message.get(1).floatValue());
    int af8 = int(message.get(2).floatValue());
    int tp10 = int(message.get(3).floatValue());

    this.status.backLeft   = tp9;
    this.status.frontLeft  = af7;
    this.status.frontRight = af8;
    this.status.backRight  = tp10;
  }

  private void handleTouchingMessage (OscMessage message) {
    if (!message.checkTypetag("i")) return;

    int touching = message.get(0).intValue();
    this.status.isTouchingForehead = (touching == 1);
  }

  private void handleDataMessage (OscMessage message, ArrayList<Float> list) {
    if (!message.checkTypetag("f")) return;
    if (message.get(0) == null) return;

    float data = message.get(0).floatValue();
    if (list.size() >= BUFFER_SIZE) {
      list.remove(0);
    }

    list.add(data);
  }

  private void handleBlinkMessage (OscMessage message) {
    if (!message.checkTypetag("i")) return;

    for (MuseListener ml : listeners) {
      ml.blinkEvent();
    }
  }

  private void handleJawClenchMessage (OscMessage message) {
    if (!message.checkTypetag("i")) return;

    for (MuseListener ml : listeners) {
      ml.jawClenchEvent();
    }
  }

  private float getSignalValue (ArrayList<Float> signal, float defaultVal) {
    int count = signal.size();
    if (count <= 0) return defaultVal;
    if (signal.get(count - 1) == null) return defaultVal;

    return signal.get(count - 1);
  }

  public float getConcentration () {
    return this.getSignalValue(this.concentration, 100.0);
  }

  public float getMellow () {
    return this.getSignalValue(this.mellow, 0.0);
  }

  public float getAlpha () {
    return this.getSignalValue(this.alpha, 0.0);
  }

  public float getBeta () {
    return this.getSignalValue(this.beta, 0.0);
  }

  public float getDelta () {
    return this.getSignalValue(this.delta, 0.0);
  }

  public float getTheta () {
    return this.getSignalValue(this.theta, 0.0);
  }

  public float getGamma () {
    return this.getSignalValue(this.gamma, 0.0);
  }

  public float getStressLevel (float alpha, float beta) {
    float diff = abs(beta - alpha);

    if (Float.isInfinite(diff)) return 0.0;

    float stress = 0.0;
    if (alpha < beta) {
      stress = map(diff, 0.0, 0.5, 4.0, 7.0);
    } else {
      stress = map(diff, 0.0, 1.0, 4.0, 0.0);
    }

    return stress;
  }

  public void drawSignals (float x, float y, float w, float h) {
    this.drawSignal(this.delta, -1, 1, x, y, w, h, color(255, 0, 0));
    this.drawSignal(this.theta, -1, 1, x, y, w, h, color(242, 26, 206));
    this.drawSignal(this.alpha, -1, 1, x, y, w, h, color(29, 231, 249));
    this.drawSignal(this.beta, -1, 1, x, y, w, h, color(22, 224, 42));
    this.drawSignal(this.gamma, -1, 1, x, y, w, h, color(255, 155, 33));
    this.drawSignal(this.mellow, 0, 100, x, y, w, h, color(22, 67, 249));
    this.drawSignal(this.concentration, 0, 100, x, y, w, h, color(255, 230, 0));
  }

  private void drawSignal (ArrayList<Float> signal, float min, float max, float x, float y, float w, float h, int c) {
    int count = signal.size();

    push();

    stroke(c);
    strokeWeight(4.0);
    noFill();

    beginShape();

    float value;
    float signalX, signalY;
    for (int i = 0; i < count; i++) {
      value = signal.get(i);

      signalX = i * (w / float(count - 1));
      signalY = constrain(map(value, min, max, h, 0), 0, h);

      vertex(x + signalX, y + signalY);
    }
    endShape();

    pop();
  }
}

public class MuseStatus {

  // Quality for horseshoe
  int GOOD_QUALITY   = 1;
  int MEDIUM_QUALITY = 2;
  int BAD_QUALITY    = 4;

  float batteryLevel;
  boolean isTouchingForehead;

  int frontLeft;
  int frontRight;
  int backLeft;
  int backRight;

  public MuseStatus () {
    batteryLevel = 0.0;
    isTouchingForehead = false;

    frontLeft  = BAD_QUALITY;
    frontRight = BAD_QUALITY;
    backLeft   = BAD_QUALITY;
    backRight  = BAD_QUALITY;
  }

  public boolean badConnection () {
    if (!isTouchingForehead) return true;
    return (frontLeft == BAD_QUALITY  ||
      frontRight == BAD_QUALITY ||
      backLeft == BAD_QUALITY   ||
      backRight == BAD_QUALITY);
  }
}

interface MuseListener {
  void blinkEvent();
  void jawClenchEvent();
}
