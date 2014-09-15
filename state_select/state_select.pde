import controlP5.*;

ControlP5 controlP5;
DropdownList p1;
Table table;
StringList strings = new StringList();
int selectedState, pieX, pieY;
float totalWorkers;
float[] angles = new float[6];
boolean[] hovered = new boolean[6];
color c;

/////////////////////////////////////////////////////////////////////////////////////
ArrayList<DataElement> points = new ArrayList<DataElement>();
ArrayList<DataElement> bars = new ArrayList<DataElement>();

String[] stateLogo = {
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", 
  "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", 
  "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
};

String[][]data;
float[][]dataPrec;

int[][]maxValues;
int rows, columns;
int STATE=2;
int tempState=-1;
int scale;
ArrayList<Circle> circles = new ArrayList<Circle>();
int startPositionX = 100;
int startPositionY = 650;
int rangeMin;
int rangeMax;
int w = 600;
int[] range = {
  rangeMin, rangeMax
};
int selectedMode = 1;
int leftVal=rangeMin, rightVal=rangeMax;
boolean stateMouseOver = false;
Circle selectMode1Circle;
Circle selectMode2Circle;
int vis2Y = 580;
/////////////////////////////////////////////////////////////////////////////////////

void setup() {
  size(800, 700);
  noStroke();
  table = loadTable("CommuterData.csv", "header");
  selectedState = 0;
  pieX = 300;
  pieY = 200;

  for (TableRow row : table.rows ()) {    
    strings.append(row.getString("State"));
  }

  controlP5 = new ControlP5(this);
  p1 = controlP5.addDropdownList("State Select", 500, 120, 100, 120);
  customize(p1);

  totalWorkers = table.getRow(selectedState).getInt("Total Workers");
  for (int i = 0, j = 2; i < 6; i++, j++) {
    angles[i] = 360.00 * table.getRow(selectedState).getInt(j)/totalWorkers;
  }

  ////////////////
  scale=1;
  rangeMin=0;  
  if (selectedMode==0) {
    rangeMax=12236346;
  } else {
    rangeMax=100;
  }
  importCSV();
  calcMaxMin();
  setupBars(selectedMode);

  circles.add(new Circle(5, startPositionX, startPositionY));
  circles.add(new Circle(5, startPositionX+w, startPositionY));

  selectMode1Circle = new Circle(5, 750, 480, false, 0);

  selectMode2Circle = new Circle(5, 750, 510, false, 1);
  selectMode2Circle.select(750, 510);
  ////////////
}

void draw() {
  background(20, 82, 113);
  pieChart(300, angles);
  drawVis2();
  drawSlider();
}

void customize(DropdownList ddl) {
  int count = 0;
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set(strings.get(0));
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (String s : strings) {
    ddl.addItem(s, count);
    count++;
  }
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    if (theEvent.group().name().equals("State Select")) {
      selectedState = int(theEvent.group().value());
      totalWorkers = table.getRow(selectedState).getInt("Total Workers");
      for (int i = 0, j = 2; i < 6; i++, j++) {
        angles[i] = 360.00 * table.getRow(selectedState).getInt(j)/totalWorkers;
      }
    }
  }
}

void pieChart(float diameter, float[] pieData) {
  float lastAngle = 0;
  color[] chooseColor = { 
    color(105, 210, 231), color(167, 219, 216), color(224, 228, 204), color(160, 162, 145), color(243, 134, 48), color(250, 105, 0)
  };
  for (int i = 0; i < pieData.length; i++) {
    color chosenColor = chooseColor[i];
    if (c == chosenColor) {
      fill(#FFB80D);
      hovered[i] = true;
    } else {
      fill(chosenColor);
      hovered[i] = false;
    }
    arc(pieX, pieY, diameter, diameter, lastAngle, lastAngle + radians(angles[i]));
    rect(pieX + 200, pieY - 60 + (i * 30), 10, 10);
    lastAngle += radians(angles[i]);
    fill(250);
    text(data[0][i + 2] + ": " + nfc(table.getRow(selectedState).getInt(i + 2), 0), pieX + 220, pieY - 50 + (i * 30));
    fill(20, 82, 113);
    ellipse(pieX, pieY, 150, 150);
  }
  checkHovered();
  fill(250);
  text(data[0][8] + ": " + nfc(table.getRow(selectedState).getInt(8)), pieX + 220, pieY + 130);
  text("Mode of Commuting to Work for Americans", pieX + 200, pieY - 130);
}

void checkHovered() {
  int count = 0;
  for (boolean b : hovered) {
    if (b == true) {
      fill(250);
      text(String.format("%.2f", 100 * angles[count]/360) + "%", 285, 205);
      for (DataElement d : bars) {
        if ((selectedState + 1 == d.id) && (count + 2 == d.column)) {
          d.highlight();
        }
      }
    } else {
      count++;
    }
  }
}

void mouseMoved() {
  color temp = get(mouseX, mouseY);
  if (temp != color(#FFB80D)) {
    c = temp;
  }
  stateMouseOver = false;
  for (DataElement b : bars) {
    b.highlight(mouseX, mouseY);
  }
  for (Circle c : circles) {
    c.highlight(mouseX, mouseY);
  }

  if (stateMouseOver) {
    for (DataElement b : bars) {
      b.highlight(mouseX, mouseY);
    }
  }
}

void importCSV() {
  String[]lines = loadStrings("CommuterData.csv");
  columns=0;
  rows=lines.length;
  for (int i=0; i<rows; i++) {
    String []chars=split(lines[i], ',');
    if (chars.length>columns) {
      columns=chars.length;
    }
  }

  data = new String[rows][columns];
  dataPrec = new float[rows][columns];
  for (int i=0; i < rows; i++) {
    String [] temp = new String [rows];
    temp= split(lines[i], ',');

    for (int j=0; j < temp.length; j++) {
      data[i][j]=temp[j];
    }
  }
  float tempPrec=0;
  for (int i=1; i<rows; i++) {
    for (int j=1; j<8; j++) {
      tempPrec=Float.parseFloat(data[i][j])/Float.parseFloat(data[i][1])*100;
      dataPrec[i][j]=tempPrec;
    }
  }
}

void calcMaxMin() {
  maxValues=new int[2][columns];
  int tempMax=0;
  int tempMin=999999;
  for (int i=1; i<columns-2; i++) {
    for (int j=2; j<rows; j++) {
      if (tempMax<Integer.parseInt(data[j][i])) {
        tempMax=Integer.parseInt(data[j][i]);
      } 
      if (tempMin>Integer.parseInt(data[j][i])) {
        tempMin=Integer.parseInt(data[j][i]);
      }
    }
    maxValues[0][i-1]=tempMax;
    maxValues[1][i-1]=tempMin;
    tempMax=0;
    tempMin=1000000;
  }
}

void drawSlider() {

  stroke(250);
  line(startPositionX, startPositionY, startPositionX + w, startPositionY);
  noStroke();
  for (Circle c : circles) {
    c.draw();
  }
  selectMode1Circle.draw();
  selectMode2Circle.draw();
  fill(250);
  text("Numbers", 680, 485);
  text("Percent", 680, 515);
}

void drawVis2() {

  fill(250);
  text("Top 3 States by Category", 300, 400);
  fill(0);
  for (int i=2; i<8; i++) {
    fill(250);
    pushMatrix();
    translate(100+((i-2)*100), vis2Y+10);
    text(data[0][i], 0, 0, 70, 30);
    popMatrix();
  }
  fill(0);
  for (DataElement d : bars) {
    d.drawPoint();
  }
}

int[] sortColumn(int column, float min, float max) {
  int[] top3 = new int[3];
  float tempVal=0; 
  int tempPos=-1;
  float currentValue=0;

  for (int i=0; i<3; i++) {
    for (int j=2; j<rows; j++) {

      if (selectedMode==1) {
        currentValue = dataPrec[j][column];
      } else {

        currentValue = Float.parseFloat(data[j][column]);
      }

      if (currentValue>min && currentValue<max) {
        if (currentValue>tempVal) {
          tempVal=currentValue;
          tempPos=j;
        }
      }
    }
    top3[i]=tempPos;
    max=tempVal;
    tempVal=0;
    tempPos=-1;
  }
  return top3;
}

String[] sortColumnState(int column, float min, float max) {
  String[] top3State = new String[3];
  float tempVal=0; 
  int tempPos=-1;
  float currentValue=0;

  for (int i=0; i<3; i++) {
    for (int j=2; j<rows; j++) {

      if (selectedMode==1) {
        currentValue = dataPrec[j][column];
      } else {

        currentValue = Float.parseFloat(data[j][column]);
      }

      if (currentValue>min && currentValue<max) {
        if (currentValue>tempVal) {
          tempVal=currentValue;
          tempPos=j;
        }
      }
    }
    println(tempPos);
    top3State[i]= data[tempPos][1];
    max=tempVal;
    tempVal=0;
    tempPos=-1;
  }
  return top3State;
}


void setupBars(int mode) {
  float yCoord;
  float value=0;
  for (int i=2; i<8; i++) { 
    int[] top3=sortColumn(i, leftVal, rightVal);
    for (int j=0; j<3; j++) {
      if (top3[j]>0) {
        if (mode==1) {
          value=dataPrec[top3[j]][i];
          yCoord = 1-(value/100*150);
        } else {
          value=Float.parseFloat(data[top3[j]][i]);
          value = value/11503746;
          yCoord = 1-(value*150); 
          value=Float.parseFloat(data[top3[j]][i]);
        } 
        bars.add(new DataElement(100+((i-2)*100)+(j*21), yCoord+vis2Y, top3[j], value, 1, yCoord, i, j));
      }
    }
  }
}

void mousePressed() {
  for (Circle c : circles) {
    c.select(mouseX, mouseY);
  }
  selectMode1Circle.select(mouseX, mouseY);
  selectMode2Circle.select(mouseX, mouseY);
}
void mouseDragged() {
  for (Circle c : circles) {
    c.move(mouseX, mouseY);
  }

  int tempVal1=circles.get(0).getValue();
  int tempVal2=circles.get(1).getValue();
  leftVal=min(tempVal1, tempVal2);
  rightVal=max(tempVal1, tempVal2);

  bars.clear();
  setupBars(selectedMode);
}


class DataElement {
  float x;
  float y;
  int id;
  float value;
  int type;

  boolean highlighted;
  boolean selected;


  int highlightedColor = #FFB80D;
  int c;
  int borderColor = #AAAAAA;
  float radius;
  float h;
  int column;
  DataElement(float x, float y, int id, float value, int type, float radius, int column) {
    this.x=x;
    this.y=y;
    this.id=id; 
    this.value=value;
    this.type=type;
    this.radius=radius;
    this.column=column;
    this.c = #0CCAE8;
  }

  DataElement(float x, float y, int id, float value, int type, float radius, int column, int place) {
    this.x=x;
    this.y=y;
    this.id=id; 
    this.value=value;
    this.type=type;
    this.radius=radius;
    this.column=column;
    if (place == 0) {
      c = #69D2E6;
    } else if (place == 1) {
      c = #E0E4CB;
    } else {
      c = #F38631;
    }
  }
  void highlight() {
    highlighted=true;
  }
  void deHighlight() {
    highlighted=false;
  }
  void highlight(float mx, float my) {
    if (contains(mx, my)) {
      highlighted=true;
      if (type==1) {
        stateMouseOver = true;
        tempState=STATE;
        STATE=id;
        points.clear();
        for (DataElement d : points) {
          if (d.column==this.column) {
            d.highlight();
          }
        }
      } else if (type == 0) {
        for (DataElement d : bars) {
          if ((d.id == this.id) && (d.value == this.value)) {
            stateMouseOver = true;
            tempState = STATE;
            STATE = id;
            d.highlight();
            this.highlight();
          }
        }
      }
    } else {
      if (stateMouseOver && type == 1 && id == STATE) {
        highlighted = true;
      } else {
        highlighted=false;
      }
    }
  }
  void displayValue() {
    fill(250);
    if (type==0) {
      text(String.format("%.2f", value), x-15, 45);
    } else {
      text(String.format("%.2f", value), x-10, y-5);
    }
  }
  boolean contains(float mx, float my) {
    if (type==0) {
      if (abs(x-mx) <= radius && abs(y-my) <= radius) {
        return true;
      }
    } else {
      if ( mx >= x  &&  mx <= x+10 &&
        my >= y  &&  my <= y+(vis2Y-y)) { 
        return true;
      }
    }
    return false;
  }
  void drawPoint() {

    if (highlighted) {
      fill(0);
      displayValue();
      fill(highlightedColor);
    } else {
      fill(c);
    }
    if (type==0) {
      ellipse(x, y, radius*2, radius*2);
    } else if (type==1) {
      rect(x, y, 10, vis2Y-y);
      text(stateLogo[id - 2], x - 2, y - 20);
    }
  }
}

class Circle {
  float radius, x, y;
  boolean highlighted = false;
  int highlightedColor = #FFB80D;
  int c = 250;
  int accentColor = #AAAAAA;
  boolean selected = false;
  boolean movable = true;
  int ID;
  Circle(float r, float x, float y) {
    radius = r;
    this.x = x;
    this.y = y;
  }

  Circle(float r, float x, float y, boolean movable, int id) {
    radius = r;
    this.x = x;
    this.y = y;
    this.movable = movable;
    c = #FFFFFF;
    this.ID = id;
  }

  void highlight(float mx, float my) {
    if ( abs(x-mx) <= radius && abs(y-my) <= radius && movable) {
      highlighted = true;
    } else {
      highlighted = false;
    }
  }

  void move(float mx, float my) {
    if ( selected && mx >= startPositionX && mx <= startPositionX+w && movable) {

      x = mx;
      draw();
    }
  }

  void select(float mx, float my) {
    if (movable) {
      if ( abs(x-mx) <= radius && abs(y-my) <= radius) {
        selected = true;
      } else {
        selected = false;
      }
    } else {
      if ( abs(x-mx) <= radius && abs(y-my) <= radius) {
        selectedMode = ID;
        rangeMin=0;
        if (selectedMode==1) {
          rangeMax=100;
        } else {
          rangeMax=12236346;
        }
        leftVal=circles.get(0).getValue();
        rightVal=circles.get(1).getValue();
        bars.clear();
        setupBars(ID);
      }
    }
  }

  void draw() {
    if (highlighted) {
      fill(highlightedColor);
    } else {
      if (!movable && selectedMode == ID) {
        fill(highlightedColor);
      } else if (!movable) {
        fill(250);
      } else {
        fill(c);
      }
    }

    ellipse(x, y, radius*2, radius*2); 
    if (movable)
      text(str(getValue()), x-15, y+20);
  }

  int getValue() {
    return int((x-startPositionX)/w * rangeMax);
  }
}

