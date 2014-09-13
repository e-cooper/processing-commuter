import controlP5.*;

ControlP5 controlP5;
DropdownList p1;
Table table;
StringList strings = new StringList();
int selectedState;
float totalWorkers;
float[] angles = new float[6];

void setup() {
  size(800,600);
  table = loadTable("CommuterData.csv", "header");

  for (TableRow row : table.rows()) {    
    strings.append(row.getString("State"));
  }
  
  controlP5 = new ControlP5(this);
  p1 = controlP5.addDropdownList("State Select", 50, 50, 100, 120);
  customize(p1);
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
  ddl.captionLabel().set("Pulldown");
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
      ListBoxItem selectedStateItem = p1.getItem((int)theEvent.value());
      totalWorkers = table.getRow(selectedState).getInt("Total Workers");
      angles[0] = 360.00 * table.getRow(selectedState).getInt("Drove Alone")/totalWorkers;
      angles[1] = 360.00 * table.getRow(selectedState).getInt("Car-pooled")/totalWorkers;
      angles[2] = 360.00 * table.getRow(selectedState).getInt("Used Public Transportation")/totalWorkers;
      angles[3] = 360.00 * table.getRow(selectedState).getInt("Walked")/totalWorkers;
      angles[4] = 360.00 * table.getRow(selectedState).getInt("Other")/totalWorkers;
      angles[5] = 360.00 * table.getRow(selectedState).getInt("Worked at home")/totalWorkers;
    }
  }
}

void pieChart(float diameter, float[] data) {
  float lastAngle = 0;
  for (int i = 0; i < data.length; i++) {
    float gray = map(i, 0, data.length, 0, 255);
    fill(gray);
    arc(width/2, height/2, diameter, diameter, lastAngle, lastAngle + radians(angles[i]));
    lastAngle += radians(angles[i]);
  }
}
