
class Demo {

  // Measures
  float marginLeft = 380;
  float marginTop = 180;

  // Info
  RGroup infoGroup;
  String[] infoTxt = {
    "Intervención experimental de la", 
    "tipografía Roboto (Google).", 
    "", 
    "Un algoritmo modifica la", 
    "anatomía de cada glifo, usando", 
    "los niveles de concentración,", 
    "tranquilidad y estrés de una", 
    "persona en tiempo real.", 
    "", 
    "Las medidas son obtenidas por", 
    "una diadema con sensores de", 
    "electroencefalografía", 
    "", 
    "Siguiente activación:", 
    "9/10 13:15hrs"
  };

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

  RShape footerSpecimen, footerData;
  RShape concen, stress, mellow;

  Demo () {
    RFont infoFont = new RFont("RobotoMono-Regular.ttf", 66, RFont.LEFT);
    createInfoGroup(infoFont);

    footerSpecimen = infoFont.toShape("Espécimen");
    footerData = infoFont.toShape("Datos");
    
    RFont dataFont = new RFont("RobotoMono-Regular.ttf", 50, RFont.LEFT);
    concen = dataFont.toShape("Concentracion");
    stress = dataFont.toShape("Estrés");
    mellow = dataFont.toShape("Tranquilidad");
  }

  void createInfoGroup (RFont infoFont) {
    infoGroup = new RGroup();

    RShape shape;
    for (int i = 0; i < infoTxt.length; i++) {
      shape = infoFont.toShape(infoTxt[i]);
      shape.translate(0, i * 72);
      infoGroup.addElement(shape);
    }
  }

  void draw () {
    background(backColor);

    scale(width / 5120.0);

    pushMatrix();
    translate(marginLeft, marginTop);

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

    translate(520, 490);
    fill(frontColor);
    noStroke();

    RShape neuro = neuroFont.toShape("Neuro", 380);
    RShape roboto = neuroFont.toShape("Roboto", 380);

    neuro.draw();
    translate(100, 330);
    roboto.draw();

    popMatrix();
  }

  void info () {
    pushMatrix();

    translate(70, 1150);
    fill(frontColor);
    noStroke();
    infoGroup.draw();

    popMatrix();
  }


  /* Specimen */

  void displaySpecimen () {

    // Box
    noFill();
    stroke(frontColor);
    strokeWeight(3.0);
    rect(1600, 45, 2820, 1550);

    // Footer
    pushMatrix();
    translate(1600, 15);
    fill(frontColor);
    noStroke();
    footerSpecimen.draw();
    popMatrix();

    // Specimen
    pushMatrix();
    translate(3025, 260);

    RShape row;
    for (int i = 0; i < specimenTxt.length; i++) {
      row = neuroFont.toShape(specimenTxt[i], 200);
      row.draw();

      translate(0, 175);
    }

    popMatrix();
  }

  /* Data */

  void displayMuseData () {

    // Box
    noFill();
    stroke(frontColor);
    strokeWeight(3.0);
    rect(1600, 1720, 2820, 728);

    // Footer
    pushMatrix();
    noStroke();
    fill(frontColor);
    translate(1600, 1695);
    footerData.draw();
    popMatrix();

    // Signals
    fill(frontColor);
    noStroke();
    rect(1705, 1780, 1883, 608);
    muse.drawSignals(1735, 1810, 1823, 548);

    // Levels
    pushMatrix();
    translate(3658, 1780);

    // Stress
    float alpha = muse.getAlpha();
    float beta  = muse.getBeta();
    float stressLvl = muse.getStressLevel(alpha, beta);
    level(0, 30, stressLvl, 2, 7, stress);
    
    // Mellow
    level(0, 230, muse.getMellow(), 0, 100, mellow);
    
    // Concentration
    level(0, 440, muse.getConcentration(), 0, 100, concen);

    popMatrix();
  }

  void level (float x, float y, float val, float min, float max, RShape txt) {

    float w = map(val, min, max, 10, 656);
    
    stroke(frontColor);
    strokeWeight(3.0);
    noFill();
    rect(x, y, 656, 70);

    fill(frontColor);
    noStroke();
    rect(x, y, w, 70);

    pushMatrix();
    translate(x, y + 130);
    txt.draw();
    popMatrix();
  }
}
