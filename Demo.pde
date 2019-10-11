
class Demo {

  // Measures
  float left = 190;
  float top = 90;

  // Info
  PFont infoFont, labelFont;
  String infoTxt =
    "Intervención experimental de la\n" +
    "tipografía Roboto (Google).\n" +
    "\n" +
    "Un algoritmo modifica la\n" + 
    "anatomía de cada glifo, usando\n" + 
    "los niveles de concentración,\n" +
    "tranquilidad y estrés de una\n" + 
    "persona en tiempo real.\n" +
    "\n" +
    "Las medidas son obtenidas por\n" + 
    "una diadema con sensores de\n" +
    "electroencefalografía\n" +
    "\n" +
    "Siguiente activación:\n" + 
    "12/Octubre 13:00hrs";

  // Specimen alphabet
  String[] specimenTxt = {
    "A  B  C  D  E  F  G  H  I  J", 
    "K  L  M  N  O  P  Q  R  S  T", 
    "U  V  W  X  Y  Z", 
    "a  b  c  d  e  f  g  h  i  j", 
    "k  l  m  n  o  p  q  r  s  t", 
    "u  v  w  x  y  z", 
    "0  1  2  3  4  5  6  7  8  9", 
    "@  #  *  +  -  ¿  ?  ¡  !"
  };

  // Neuro shapes
  RShape neuroSrc, robotoSrc;
  RShape[] specimenRows;

  Demo (NeuroFont neuroFont) {

    // Load PFont
    infoFont  = createFont("RobotoMono-Regular.ttf", 33);
    labelFont = createFont("RobotoMono-Regular.ttf", 25);

    // Load neuro shapes
    neuroSrc  = neuroFont.fontSrc.toShape("Neuro");
    robotoSrc = neuroFont.fontSrc.toShape("Roboto");

    initSpecimenRows(neuroFont.fontSrc);
  }

  void initSpecimenRows (RFont fontSrc) {
    specimenRows = new RShape[ specimenTxt.length ];
    for (int i = 0; i < specimenTxt.length; i++) {
      specimenRows[i] = fontSrc.toShape(specimenTxt[i]);
    }
  }

  void draw () {
    background(backColor);

    pushMatrix();
    translate(left, top);

    displayInfo();
    displaySpecimen();
    displayMuseData();

    popMatrix();
  }

  /* Info */

  void displayInfo () {
    title();
    info();
  }

  void title () {
    pushMatrix();

    RShape neuro = neuroFont.updateShape(neuroSrc, 190);
    RShape roboto = neuroFont.updateShape(robotoSrc, 190);

    translate(260, 245);
    fill(frontColor);
    noStroke();

    neuro.draw();
    translate(50, 165);
    roboto.draw();

    popMatrix();
  }

  void info () {
    fill(frontColor);
    noStroke();

    textFont(infoFont);
    textAlign(LEFT);
    textLeading(33);
    text(infoTxt, 35, 575);
  }

  /* Specimen */

  void displaySpecimen () {

    // Box
    noFill();
    stroke(frontColor);
    strokeWeight(3.0);
    rect(800, 22, 1410, 775);

    // Header
    textFont(infoFont);
    textAlign(LEFT);
    fill(frontColor);
    noStroke();
    text("Espécimen", 800, 8);

    // Specimen
    pushMatrix();
    translate(1512, 130);

    RShape row;
    for (int i = 0; i < specimenRows.length; i++) {
      row = neuroFont.updateShape(specimenRows[i], 100);
      row.draw();

      translate(0, 88);
    }

    popMatrix();
  }

  /* Data */

  void displayMuseData () {

    // Box
    noFill();
    stroke(frontColor);
    strokeWeight(3.0);
    rect(800, 860, 1410, 364);

    // Header
    textFont(infoFont);
    textAlign(LEFT);
    fill(frontColor);
    noStroke();
    text("Data", 800, 848);

    // Signals
    fill(frontColor);
    noStroke();
    rect(852, 890, 942, 304);
    muse.drawSignals(868, 905, 912, 274);

    // Levels
    pushMatrix();
    translate(1829, 890);

    // Stress
    float alpha = muse.getAlpha();
    float beta  = muse.getBeta();
    float stressLvl = muse.getStressLevel(alpha, beta);
    level(0, 15, stressLvl, 1, 8, "Estrés");

    // Mellow
    level(0, 115, muse.getMellow(), 0, 100, "Tranquilidad");

    // Concentration
    level(0, 220, muse.getConcentration(), 0, 100, "Concentracion");

    popMatrix();
  }

  void level (float x, float y, float val, float min, float max, String txt) {

    stroke(frontColor);
    strokeWeight(3.0);
    noFill();
    rect(x, y, 328, 35);

    float w = map(val, min, max, 10, 328);
    fill(frontColor);
    noStroke();
    rect(x, y, w, 35);
    
    fill(frontColor);
    noStroke();
    textFont(labelFont);
    textAlign(LEFT);
    text(txt, x, y + 65);
  }
}
