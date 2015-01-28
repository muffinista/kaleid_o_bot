/**
 * handles a single image request from twitter or elsewhere. generate/parse the variables we will use to output an image, etc
 */
class Request {
  String txt;
  PImage img;
  PApplet app;

  int spot;
  int slices;
  boolean animate;
  
  int width;
  int height;

  Request(PApplet a, PImage i, Status t) {
    this(a, i, t.getText());
  }
  
  Request(PApplet a, PImage i, String s) {
    app = a;
    txt = s.toLowerCase();
    img = i;

    setValues();
    preRenderTasks();
  }

  void setValues() {
    spot = tweetToAngle();
    slices = getTotalSlices();
    animate = tweetToAnimate();

    if ( animate ) {
      width = animated_output_width; 
      height = animated_output_height; 
    }
    else {
      width = output_width; 
      height = output_height;       
    }
  }

  int requiredSourceWidth() {
    return int(this.width * 1.25);
  }
  int requiredSourceHeight() {
    return int(this.height * 1.25);
  }

  private int getTotalSlices() {
    int total = 0;

    if ( txt.indexOf("#24slices") != -1 ) {
      total = 24;
    }
    else if ( txt.indexOf("#20slices") != -1 ) {
      total = 20;
    }
    else if ( txt.indexOf("#16slices") != -1 ) {
      total = 16;
    }
    else if ( txt.indexOf("#12slices") != -1 ) {
      total = 12;
    }
    else if ( txt.indexOf("#8slices") != -1 ) {
      total = 8;
    }
    else if ( txt.indexOf("#4slices") != -1 ) {
      total = 4;
    }
  
    if ( total == 0 ) {
      total = int(random(1, 6)) * 4;
    }

    return total; 
  }

  private boolean tweetToAnimate() {
    if ( txt.indexOf("#animate") != -1 ) {
      return true;
    }
    else if ( txt.indexOf("#noanimate") != -1 ) {
      return false;
    }

    if ( int(random(0, 10)) > 5 ) {
      return true;
    }

    return false;
  }

  int tweetToAngle() {
    // 789
    // 456
    // 123

    int spot = 0;

    if ( txt.indexOf("#northwest") != -1 ) {
      spot = 7;
    }
    else if ( txt.indexOf("#northeast") != -1 ) {
      spot = 9;
    }
    else if ( txt.indexOf("#north") != -1 ) {
      spot = 8;
    }
    else if ( txt.indexOf("#east") != -1 ) {
      spot = 6;
    }
    else if ( txt.indexOf("#southeast") != -1 ) {
      spot = 3;
    }
    else if ( txt.indexOf("#southwest") != -1 ) {
      spot = 1;
    }
    else if ( txt.indexOf("#south") != -1 ) {
      spot = 2;
    }
    else if ( txt.indexOf("#west") != -1 ) {
      spot = 4;
    }
    else if ( txt.indexOf("#center") != -1 ) {
      spot = 5;
    }

    if ( spot == 0 ) {
      spot = int(random(1, 9));
    }

    return spot;  
  }

  int spot() {
    return spot;
  }

  int slices() {
    return slices;
  }

  String angleToHash() {
    String s = "";
    switch(spot) {
    case 8:
      s = "#north"; 
      break;
    case 9:
      s = "#northeast"; 
      break;
    case 6:
      s = "#east"; 
      break;
    case 3:
      s = "#southeast"; 
      break;
    case 2:
      s = "#south"; 
      break;
    case 1:
      s = "#southwest"; 
      break;
    case 4:
      s = "#west"; 
      break;
    case 7:
      s = "#northwest"; 
      break;
    case 5:
      s = "#center"; 
      break;
    }
  
    return s;
  }

  PVector getTranslationPoint(int slice_w, int slice_h) {
    int spot = tweetToAngle();
    PImage src = img;

    PVector target = new PVector(0, 0); // = new PVector(src.width / 2, src.height / 2);


    int minorAxis = (int)((img.height - (slice_h * 2)) * AXIS_PADDING);
    int majorAxis = (int)((img.width - (slice_w * 2)) * AXIS_PADDING);
    PVector c = new PVector((img.width - slice_w) / 2, (img.height - slice_h) / 2);

    println("SLICE DIM: " + slice_w + "x" + slice_h);
    println("center: " + c.x + ", " + c.y);

    println("axis: " + majorAxis + " - " + minorAxis);
    float t = 0;

    // 789
    // 456
    // 123
    switch(spot) {
    case 8:
      t = PI / 2;
      break;
    case 9:
      t = PI / 4;
      break;
    case 6:
      t = 0;
      break;
    case 3:
      t = 7 / ( 4 * PI );
      break;
    case 2:
      t = 3 / ( 2 * PI );
      break;
    case 1:
      t = 5 / ( 4 * PI );
      break;
    case 4:
      t = PI;
      break;
    case 7:
      t = 3 / ( 4 * PI );
      break;      
    case 5:
    default:
      target = c;
      t = -1;
      break;
    }

    if ( t > -1 ) {
      target.x = (int)(c.x + majorAxis * cos(t));
      target.y = (int)(c.y + minorAxis * sin(t));      
    }

    // prevent clipping outside of the image
    // target.x = constrain(target.x, 0, img.width - slice_w);
    // target.y = constrain(target.y, 0, img.height - slice_h);


    println(target.x + ", " + target.y);
    return target;
  }


  //
  // 
  //
  PImage getImageChunk(int output_width, int output_height, PVector p) {
    //the width and height parameters for the mask
    int w =int(output_width / MASK_SCALE); 
    int h = int(output_height / MASK_SCALE); 

    //create a mask of a slice of the original image.
    PGraphics selection_mask; 
    selection_mask = createGraphics(w, h, JAVA2D); 
    selection_mask.beginDraw(); 
    selection_mask.smooth();

    // make an arc/slice of the source image just a little bit wider than what we need
    float e = radians(360/slices + .1);
    selection_mask.arc(0, 0, 2*w, 2*h, 0, e);
    selection_mask.endDraw(); 

    println("IMG DIM: " + img.width + " x " + img.height);

    println("copy from " + p.x + ", " + p.y);

    //
    // make a copy of the image with copies of the image on all sides, for wrapping
    //
    PGraphics foo = createGraphics(img.width * 3, img.height * 3);
    foo.beginDraw();
    for ( int x = 0; x < 3; x++ ) {
      for ( int y = 0; y < 3; y++ ) {
        foo.image(img, x * img.width, y * img.height);
      }
    }
    //foo.get(0, 0);
    foo.translate(img.width, img.height);
    foo.endDraw();

    PImage slice = createImage(w, h, RGB); 
    //    slice = img.get(int((p.x)), int((p.y)), w, h);
    slice = foo.get(int((p.x)), int((p.y)), w, h);
    slice.mask(selection_mask); 
//    slice.save("foo.png");

    return slice;
  }

  PImage cropImage(PImage img) {
    PImage cropped;
    int x, y, w, h;

    if ( img.width > img.height ) {
      w = img.height;
      h = img.height;

      x = (img.width / 2) - (img.height / 2);
      y = 0;
    }
    else {
      w = img.width;
      h = img.width;

      x = 0;
      y = (img.height / 2) - (img.width / 2);
    }


    println("crop to " + x + ", " + y + ": " + w + "x" + h);
    cropped = img.get(x, y, w, h);
    return cropped;
  }

  void preRenderTasks() {
    if ( this.img.height < requiredSourceHeight() ) {
      println("resizing h from " + img.height + " to " + requiredSourceHeight());
      this.img.resize(0, requiredSourceHeight());
    }

    if ( this.img.width < requiredSourceWidth() ) {
      println("resizing w from " + img.width + " to " + requiredSourceWidth());
      this.img.resize(requiredSourceWidth(), 0);
    }

    // make sure the image is square
    if ( this.img.height != this.img.width ) {
      println("cropping image square");
      this.img = cropImage(this.img);
    }    

    println("new img dims: " + this.img.width + "x" + this.img.height);
  }


  File renderAnimated(int frames) {
    File temp = null;

    //the width and height parameters for the mask
    int w = int(this.width / MASK_SCALE); 
    int h = int(this.height / MASK_SCALE); 

    PVector c = new PVector(this.img.width / 2, this.img.height / 2);

    int minorAxis = (int)((this.img.height - (h * 1)) * AXIS_PADDING);
    int majorAxis = (int)((this.img.width - (w * 1)) * AXIS_PADDING);

    println("minorAxis: "+minorAxis + ", " + this.img.height + ", " + h*2);
    println("majorAxis: "+majorAxis + ", " + this.img.width + ", " + w*2);

    String dest = "kaleidoscope.gif";
    try {
      temp = File.createTempFile("kaleidoscope", ".gif"); 
      System.out.println("Temp file : " + temp.getAbsolutePath());
      dest = temp.getAbsolutePath();
    } 
    catch(IOException ex) { 
      ex.printStackTrace();
    }
    
    GifMaker gifExport = new GifMaker(app, dest);
    //  gifExport.setTransparent(0, 0, 0);
    gifExport.setDispose( GifMaker.DISPOSE_KEEP );
    gifExport.setRepeat(0);
    gifExport.setDelay(350);

  //  PVector target;

    Tween ani = new Tween(app, frames, Tween.FRAMES, Shaper.LINEAR);
    float step = TWO_PI / frames;
    for ( int i = 0; i < frames; i++ ) {
      PVector target = new PVector();
      float t = ani.position();
      target.x = (int)(c.x + majorAxis * cos(t * TWO_PI));
      target.y = (int)(c.y + minorAxis * sin(t * TWO_PI));

      PGraphics pg = renderSingleFrame(target);
      gifExport.addFrame(pg);
      ani.tick();
    }

    gifExport.finish();
    System.out.println("Temp file : " + temp.getAbsolutePath());

    return temp;
  }

  PGraphics renderSingleFrame() {
    //the width and height parameters for the mask
    int w = int(this.width / MASK_SCALE); 
    int h = int(this.height / MASK_SCALE); 

    PVector p = this.getTranslationPoint(w, h);

    return renderSingleFrame(p);
  }

  PGraphics renderSingleFrame(PVector p) {
    int totalSlices = this.slices();
    println("SLICES: " + totalSlices);
    println("w: " + this.img.width + ", h: " + this.img.height);

    PImage slice = getImageChunk(this.width, this.height, p);

    PGraphics pg = createGraphics(this.width, this.height);
    pg.beginDraw();
    pg.background(0,0,0);
    pg.smooth();

    pg.translate(pg.width/2, pg.height/2); 

    pg.scale(SLICE_SCALE_AMOUNT);

    for(int k = 0; k <= totalSlices ;k++){ 
      pg.rotate( k * radians(360/(totalSlices/2)) ); 
      pg.image(slice, 0, 0); 
      pg.scale(-1.0, 1.0);
      pg.image(slice,0,0);
    } 
    
    pg.endDraw();

    println("done!");
    return pg;
  }

}