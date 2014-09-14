import controlP5.*;

ControlP5 controlP5;
DropdownList p1;
Table table;
StringList strings = new StringList();
int selectedState, pieX, pieY;
float totalWorkers;
float[] angles = new float[6];
color c;

void setup() {
  size(800,600);
  noStroke();
  table = loadTable("CommuterData.csv", "header");
  selectedState = 0;
  pieX = width/2;
  pieY = height/2;

  for (TableRow row : table.rows()) {    
    strings.append(row.getString("State"));
  }
  
  controlP5 = new ControlP5(this);
  p1 = controlP5.addDropdownList("State Select", 50, 50, 100, 120);
  customize(p1);
  
  totalWorkers = table.getRow(selectedState).getInt("Total Workers");
  for (int i = 0, j = 2; i < 6; i++, j++) {
    angles[i] = 360.00 * table.getRow(selectedState).getInt(j)/totalWorkers;
  }
}

void draw(){
  background(200);
  pieChart(300, angles);
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
  ddl.setColorActive(color(255,128));
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    println(theEvent.group().value() + " from " + theEvent.group());
    if (theEvent.group().name().equals("State Select")) {
      selectedState = int(theEvent.group().value());
      totalWorkers = table.getRow(selectedState).getInt("Total Workers");
      for (int i = 0, j = 2; i < 6; i++, j++) {
        angles[i] = 360.00 * table.getRow(selectedState).getInt(j)/totalWorkers;
      }
    }
  }
}

void pieChart(float diameter, float[] data) {
  float lastAngle = 0;
  for (int i = 0; i < data.length; i++) {
    float gray = map(i, 0, data.length, 0, 255);
    fill(gray);
    ellipse(pieX, pieY, 150, 150);
    println(c + " " + color(gray));
    if (c == color(gray)) {
      fill(255, 0, 0);
    }
    arc(pieX, pieY, diameter, diameter, lastAngle, lastAngle + radians(angles[i]));
    lastAngle += radians(angles[i]);
  }
}

void mouseMoved() {
  c = get(mouseX, mouseY);
}
