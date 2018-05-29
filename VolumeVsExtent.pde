import com.hamoid.*;
VideoExport videoExport;
ArrayList<VolumeAndExtent> data = new ArrayList<VolumeAndExtent>();
int days;

float xScale;
float yScale;

color _coolColour = color(12, 182, 190);//color(75, 104, 166);
color _mediColour = color(252, 211, 127);
color _warmColour = color(221, 21, 58);
color _lowColour = color(12, 182, 190);
color _highColour = color(193,97,9);

int animWidth = 500;
int margin = 50;

void settings()
{
  size(animWidth + margin * 2, animWidth + margin * 2);
}

void setup()
{
  loadData();
  
  xScale = float(animWidth)/34.0;
  yScale = float(animWidth)/17.0;
  
  stroke(255);
  strokeWeight(2);
  textSize(30);
  textAlign(CENTER);
  
    videoExport = new VideoExport(this);
    videoExport.setFrameRate(30);
    videoExport.startMovie();
}


int dayCount = 0;
int daysPerFrame = 20;
int currentYear = 1979;
float lastX;
float lastY;
int frameToPauseFrom;
boolean pausing = false;
void draw()
{
  background(25, 41, 64);
  
  drawAxis();
   
  
  for(int day = 0; day < dayCount + daysPerFrame; day++)
  {
    if(day >= days) continue;
    
    VolumeAndExtent vne = data.get(day);
    
    
    
    float x = vne.Volume * xScale;
    float y = vne.Extent * yScale;
    
    if(frameCount == 1)
    {
      lastX = x;
      lastY = y;
    }
    
    float proportion = float(day) / float(days);
    int colour = 0;
    if(proportion < 0.5) colour = lerpColor(_coolColour, _mediColour, proportion / 0.5);
    if(proportion >= 0.5) colour = lerpColor(_mediColour, _warmColour, (proportion-0.5) / 0.5);
        
    stroke(colour);
    
    line(margin + lastX, height - margin - lastY, margin + x, height - margin - y);
    
    lastX = x;
    lastY = y;
    currentYear = vne.Year;
  }
  
  videoExport.saveFrame();
  dayCount += daysPerFrame;
  
  if(dayCount >= days)
  {
    if(!pausing)
      frameToPauseFrom = frameCount;
    
    pausing = true;
  }
  
  if(pausing && (frameCount - frameToPauseFrom) > 180)
  {
    videoExport.endMovie();
    exit();
  }
  
}

void drawAxis()
{
  pushStyle();
    stroke(255);
    //max extent 16 ², volume 33
    textSize(30);
    textAlign(CENTER);
    text(currentYear , margin + animWidth / 2, 60);
    textSize(20);
    text("Arctic Sea Ice Volume and Extent", animWidth/2 + margin, 20);
    text("@kevpluck\nPixelMoversAndMakers.com", margin + animWidth / 2, 450);
    
    line(margin,margin,margin,height-margin);
    line(margin,height-margin,width-margin,height-margin);
    
    textSize(15);
    
    text("Volume (×1,000 km³) PIOMAS", margin + animWidth / 2, height - 15);
    pushMatrix();
      translate(margin, height - margin);
      rotate(-PI/2.0);
      text("Extent (×1,000,000 km²) NSIDC", margin + animWidth / 2, -30);
    popMatrix();
    textAlign(RIGHT);
    for(int extent = 2; extent <= 16; extent += 2)
      text(extent, margin - 3, height - margin - extent * yScale);
      
    for(int volume = 5; volume <= 33; volume += 5)
      text(volume, margin + volume * xScale, height - margin + 16);
    
    text("0", margin - 5, height - margin + 16);
    
  popStyle();
}

void loadData()
{
  String[] strings = loadStrings("VolumeVsExtent.csv");
  
  for(String row: strings)
  {
    String[] items = row.split(",");
    int year = int(items[0]);
    float volume = float(items[2]);
    float extent = float(items[3]);
    
    data.add(new VolumeAndExtent(year, volume, extent));
  }
  
  days = data.size();
}

class VolumeAndExtent
{
  VolumeAndExtent(int year, float volume, float extent)
  {
    Year = year;
    Volume = volume;
    Extent = extent;
  }
  
  public int Year;
  public float Volume;
  public float Extent;
  
  public String toString() {
        return Year + ", " + Volume + ", " + Extent;
    }
  
}