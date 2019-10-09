
public class NeuroFont {

  private RFont fontSrc;
  private int fontSize = 10;
  private String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789¿?¡!+-";

  private RShape[] srcShapes;
  public RShape[] shapes;

  // Modifiers
  public float noiseStep = 0.5;
  public float noiseScale = 0.5;
  public float ampCos = 0.0;
  public float ampSin = 0.0;

  public float offsetX = 0.03;
  public float offsetY = 0.04;
  public float offsetZ = 0.04;

  public float ampNoiseSinus = 2.0;

  public NeuroFont (String fontName, int fontSize) {
    this.fontSize = fontSize;
    this.fontSrc = new RFont(fontName, this.fontSize, RFont.CENTER);
    this.resetShapes();
  }

  private void resetShapes () {
    int n = alphabet.length();

    srcShapes = new RShape[n];
    shapes = new RShape[n];

    for (int i = 0; i < n; i++) {
      RShape charShape = fontSrc.toShape("" + alphabet.charAt(i));
      srcShapes[i] = charShape.countChildren() > 0 ? charShape.children[0] : charShape;
    }
  }

  public void update () {
    RPath[] newPaths;

    RShape srcShape;
    for (int i = 0; i < srcShapes.length; i++) {
      srcShape = srcShapes[i];

      newPaths = new RPath[srcShape.countPaths()];
      for (int j = 0; j < newPaths.length; j++) {
        newPaths[j] = updatePath(srcShape.paths[j]);
      }

      shapes[i] = new RShape(newPaths);
    }
  }

  public RShape updateShape (RShape shape) {
    RShape newShape = new RShape();

    int len = shape.countChildren();
    for (int i = 0; i < len; i++) {
      RShape srcShape = shape.children[i];
      RPath[] newPaths = new RPath[ srcShape.countPaths() ];

      for (int j = 0; j < newPaths.length; j++) {
        newPaths[j] = updatePath(srcShape.paths[j]);
      }

      newShape.addChild(new RShape(newPaths));
    }

    return newShape;
  }
  
  public RShape updateShape (RShape shape, float charSize) {
    RShape newShape = updateShape(shape);
    newShape.scale(charSize / float(fontSize));
    
    return newShape;
  }

  RPath updatePath (RPath path) {

    RPoint center = path.getCentroid();
    RPoint[] points = path.getPoints();

    float angleResSin = (PI * 4.5) / path.getWidth();
    float angleResCos = (PI * 4.0) / float(points.length);

    RPoint p; 
    PVector v;
    for (int i = 0; i < points.length; i++) {
      p = points[i];
      v = new PVector(p.x - center.x, p.y - center.y);

      float noiseVal = noise(p.y * offsetX, p.x * offsetY, frameCount * offsetZ);
      noiseVal = Float.isInfinite(noiseVal) ? 0.5 : noiseVal;
      float s = map(noiseVal, 0.0, 1.0, -noiseStep * 1.5, noiseStep);

      v.normalize();
      v.mult(s * noiseScale);

      float offSin = sin(p.x * angleResSin) * ampSin;
      float offCos = cos(i * angleResCos) * ampCos;

      p.x += (v.x + offCos);
      p.y += (v.y + offSin);
    }

    return new RPath(points);
  }

  RShape getCharShape (char character) {
    int index = alphabet.lastIndexOf(character);
    if (index == -1) return null;

    return shapes[index];
  }

  void save (String folder, String prefix) {
    for (int i = 0; i < shapes.length; i++) {
      RShape shape = shapes[i];

      String fileName = folder + "/" + prefix + i + ".svg";
      shape.translate(shape.getWidth(), shape.getHeight() * 1.5);
      RG.saveShape(fileName, shape);
    }
  }
}
