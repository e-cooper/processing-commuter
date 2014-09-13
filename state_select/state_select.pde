import controlP5.*;

ControlP5 controlP5;
DropdownList p1;
Table table;
StringList strings = new StringList();

void setup() {
  size(800,600);
  table = loadTable("CommuterData.csv", "header");

  for (TableRow row : table.rows()) {    
    strings.append(row.getString("State"));
  }
  
  controlP5 = new ControlP5(this);
  p1 = controlP5.addDropdownList("State Select", width/2 - 50, 100, 100, 120);
  customize(p1);
}

void draw(){
  background(50);
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
  }
}
